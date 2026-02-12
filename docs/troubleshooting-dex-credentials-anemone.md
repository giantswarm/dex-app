# Troubleshooting: Dex credentials and Flux / dex-operator (anemone)

**Cluster:** anemone (via `tsh kube login anemone`)  
**Date:** 2026-02-06

## Your assumptions — validated

1. **Credentials are applied into the secret via dex-operator** — **Yes.**  
   Dex-operator owns the secret `dex-app-default-dex-config` (label `giantswarm.io/managed-by: dex-operator`, finalizer `dex-operator.finalizers.giantswarm.io/app-controller`). It contains default connector config (including client secrets) and is used as **extraConfig** for the dex-app App.

2. **Dex-operator renews its own credentials** — **Yes.**  
   Dex-operator runs with `--enable-self-renewal=true` and logs show it checking "dex-operator service credentials need rotation" and "Azure credential expiry" (e.g. expiry 2026-05-18). It can rotate credentials and write them into the config that feeds Dex.

3. **Flux overrode the credentials** — **Yes, via config merge order.**  
   The dex-app App is driven by Flux (App CR has labels `kustomize.toolkit.fluxcd.io/name: collection`, `kustomize.toolkit.fluxcd.io/namespace: flux-giantswarm`). User/cluster config comes from `dex-app-konfiguration` (Konfiguration / Flux). In app-operator’s merge order:
   - **extraConfig** (dex-app-default-dex-config, dex-operator) has **priority 25**
   - **Cluster config** (dex-app-konfiguration, Flux/Konfiguration) has **priority 50**
   So **cluster config overrides extraConfig**. The Flux-managed `dex-app-konfiguration` therefore overwrites the credentials that dex-operator writes into `dex-app-default-dex-config`. The final `dex` Secret is rendered by Helm from this merged values; it therefore contains the config-layer credentials, not the latest rotated ones from dex-operator.

4. **So it can’t (e.g. authenticate)** — **Plausible.**  
   If dex-operator rotated credentials (e.g. Azure AD client secret) and wrote them into `dex-app-default-dex-config`, but the rendered Dex config is dominated by `dex-app-konfiguration`, Dex will still see the old secrets from the Konfiguration, and authentication can fail (e.g. "invalid client secret").

## What we saw on the cluster

| Resource | Namespace | Owner / Notes |
|----------|-----------|----------------|
| Secret `dex` | giantswarm | Helm (dex-app). Rendered from chart + merged values. |
| Secret `dex-app-default-dex-config` | giantswarm | **dex-operator** (label, finalizer). Priority 25 extraConfig. |
| Secret `dex-app-konfiguration` | giantswarm | Konfiguration (Flux). Priority 50 config. Contains connector and static client secrets. |
| App `dex-app` | giantswarm | Flux (Kustomize) + app-operator. Last deployed 2026-02-03. |
| Deployment `dex-operator` | giantswarm | Runs with `--enable-self-renewal=true`. |

- **resourceVersion:** `dex` (779514725) > `dex-app-default-dex-config` (779267873) — the rendered secret is “newer” than the dex-operator default config in terms of object updates, consistent with Helm re-rendering from merged values where config (50) overrides extraConfig (25).

## Root cause (summary)

- Dex-operator writes (and rotates) credentials into **extraConfig** at priority **25**.
- Flux/Konfiguration provides **cluster config** at priority **50**, which **overrides** that extraConfig.
- The Dex config Secret is therefore driven by the Flux-managed config, so rotated credentials from dex-operator are not what Dex actually uses.

## Next steps (no app code changes)

1. **Confirm the exact failure**  
   e.g. Dex login error, “invalid client secret”, or Azure AD errors. That confirms we’re looking at the right credentials.

2. **Fix merge order so dex-operator wins for connector credentials**  
   - Give dex-operator’s extraConfig a **higher** priority than the Flux/Konfiguration config (e.g. extraConfig priority **> 50**), or  
   - Remove connector/client secrets from the Flux-managed Konfiguration and let dex-operator be the single source for those via extraConfig (keeping only non-secret settings in Konfiguration if needed).

3. **Optional: verify who updates what**  
   - After a credential rotation by dex-operator, check that `dex-app-default-dex-config` changed and that the merged values used by the chart actually use that secret (e.g. by checking the values passed to Helm or the rendered `dex` secret content for the connector in question).

## Commands used

```bash
tsh kube login anemone
kubectl get secret -n giantswarm | grep dex
kubectl get secret dex -n giantswarm -o yaml
kubectl get secret dex-app-default-dex-config -n giantswarm -o yaml
kubectl get app dex-app -n giantswarm -o yaml
kubectl get deployment dex-operator -n giantswarm -o yaml
kubectl logs deployment/dex-operator -n giantswarm --tail=100
helm list -n giantswarm | grep dex
```
