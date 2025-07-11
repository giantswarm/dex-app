# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.1] - 2025-07-09

### Changed

- Increased `oidc.expiry.refreshTokens.validIfNotUsedFor` to 30 days, according to `oidc.expiry.refreshTokens.absoluteLifetime`

## [2.1.0] - 2025-07-03

### Changed

- Fixed Ingress fields for workload clusters
- Increased `oidc.expiry.refreshTokens.absoluteLifetime` to 30 days

### Removed

- Removed support for deprecated Ingress versions

## [2.0.2] - 2025-06-25

### Changed

- Allow for `managementCluster` value to be a `string` or `object`.

## [2.0.1] - 2025-06-25

### Changed

- Allow for additionalProperties in the Chart values schema.

## [2.0.0] - 2025-06-18

### Changed
- Added sync workflow to sync from upstream
- Refactored chart to align with upstream

## [1.42.15] - 2025-05-08

## Added

- Added `largeHeaderBuffers` to ingress for large request header size.

## [1.42.14] - 2025-05-06

### Added

- Added renovate configuration
- Make Ingress annotations configurable via values (`.Values.ingress.annotations`)
- Increased request header size limit in NGINX ingress controller annotations

### Removed

- Removed dependabot configuration

## [1.42.13] - 2024-11-13

### Changed

- Changed ownership to Team Shield
- Prepare for Backstage service

## [1.42.12] - 2024-07-25

### Fixed

- Bump dex to [v2.37.1-gs1](https://github.com/giantswarm/dex/releases/tag/v2.37.1-gs1) to fix critical CVEs.

## [1.42.11] - 2024-07-18

### Changed

- Default `ingress.tls.clusterIssuer` values to `letsencrypt-giantswarm`
- Update `cert-manager.io/cluster-issuer` annotation to use default.

## [1.42.10] - 2024-05-28

### Removed

- Remove `write_all_group` from values and schema.

## [1.42.9] - 2024-03-06

### Removed

- Remove deprecated giant swarm monitoring annotations and labels.

## [1.42.8] - 2024-02-05

### Changed

- Disables `dex-k8s-authenticator` to be installed by default by setting `deployDexK8SAuthenticator` to `false`.

## [1.42.7] - 2024-01-15

## [1.42.6] - 2024-01-15

## [1.42.5] - 2024-01-12

### Changed

- Removes `app.kubernetes.io/instance` from `podSelector` as it exists in common labels.

## [1.42.4] - 2023-12-20

## [1.42.3] - 2023-12-06

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.

## [1.42.2] - 2023-11-30

### Changed

- Don't use `oidc.customer.enabled` value since it is redundant.

## [1.42.1] - 2023-11-24

### Added

- Adding new properties to configure trusted peers in pre-defined static clients

## [1.42.0] - 2023-11-15

### Added

- Added `deployDexK8SAuthenticator` option to disable the deployment of dex-k8s-authenticator.
- Added `ingress.tls.externalSecret.enabled` option to disable tls secret creation and allow usage of an external secret.

## [1.41.0] - 2023-10-03

### Added

- Added `seccompProfile` for PSS compliance.

## [1.40.0] - 2023-10-02

### Changed
- Update deployment to be PSS compliant and PSP toggle.

## [1.39.0] - 2023-08-09

### Changed

- Reorder connectors in login screen.
- Update app-test-suite dependencies.

## [1.38.0] - 2023-08-08

- Update layout of selector screen.

## [1.37.0] - 2023-07-13

### Changed

- Make `ingressClassName` configurable

### Added

- Add support for custom static clients

## [1.36.0] - 2023-07-11

### Changed

- Update Dex to v2.37.0

## [1.35.0] - 2023-06-19

### Changed

- Change format for proxy configuration to automatically use proxy settings from cluster-values secret.

## [1.34.3] - 2023-06-13

### Added

- Add utility function to determine whether the app is installed on a workload cluster

### Removed

- Remove unused dex-k8s-authenticator-giantswarm resources
- Stop pushing to `openstack-app-collection`.

## [1.34.2] - 2023-05-05

### Changed

- Changed log level to `info`

## [1.34.1] - 2023-05-03

### Changed

- Remove shared app collection from circle CI
- Define pod disruption budget as percentage

## [1.34.0] - 2023-03-22

### Added

- Add circle ci job to push to `capz-app-collection` on new release.
- Static client for GitOps Server.

## [1.33.0] - 2023-03-02

### Added

- Add additional annotations on all `ingress` objects to support DNS record creation via `external-dns`

## [1.32.3] - 2023-02-22

### Added

- Add a possibility to configure a custom trusted root CA
- Add support for manual configuration of private workload cluster proxy

## [1.32.2] - 2023-01-13

### Changed
- Improve connector selection (login) and error page UI.

## [1.32.1] - 2022-12-22

### Changed

- Use inline schema for 'image', avoid external schema.

## [1.32.0] - 2022-12-20

### Added

- Add support for filtering connectors with `connector_filter` query parameter on connector selection (login) page.

### Changed

- Use external [image](https://schema.giantswarm.io/image/v0.0.1) schema.
- Allowed null values of OIDC connectors in the values schema

## [1.31.2] - 2022-12-01

### Added

- Add annotation to dex deployment template to roll pods whenever secret changes.

## [1.31.1] - 2022-12-01

### Changed

- If more connectors are specified in `Values.oidc.customer.connectors` in addition to an existing one in `Values.oidc.customer.connectorConfig`, include both in the dex secret.

### Fixed

- Fix deployment template securityContext.

## [1.31.0] - 2022-11-29

### Added

- Add option to configure custom clusterIssuer for certificate generation.

## [1.30.2] - 2022-11-24

## Added

- Add circle ci job to push to `gcp-app-collection` on new release.

## [1.30.1] - 2022-11-07

## [1.30.0] - 2022-10-13

### Changed

- Update Dex to v2.35.3

## [1.29.0] - 2022-09-26

### Changed

- Pull kubernetes CA cert for k8s-authenticator from environment variable.

## [1.28.0] - 2022-09-22

### Changed

- Update Dex to v2.34.0

## [1.27.0] - 2022-09-06

### Added

- Add giant swarm monitoring annotations for alerting in workload clusters.

### Changed

- Update Dex to v2.33.0

## [1.25.2] - 2022-08-02

### Added

- Add default value for giantswarm CLIAuth client ID.

## [1.25.1] - 2022-05-24

### Changed

- Changed YAML multiline from `>-` to `|-`

### Added

- Support gs admin callback URI and gs cli trusted peer in WC templating.

## [1.25.0] - 2022-05-02

### Removed

- Remove Job that allowed recreation of certificate secrets when upgrading and disabled lets encrypt.

### Changed

- Update Dex to `v2.31.1`.
- Increase detail in token refresh logs for debugging purposes.
- Support GS specific OIDC group prefixing for password connector types (e.g. LDAP)

## [1.24.2] - 2022-04-27

### Added

- Push to OCI registry on build.

### Changed

- Remove public kubernetes api port in k8s-authenticator configmap template for MCs since the port is already included in the address.
- Add team annotation

## [1.24.1] - 2022-03-30

### Added

- Add default port to Kubernetes API values to make it configurable.

## [1.24.0] - 2022-03-17

### Changed

- Update Dex to `v2.31.0`

## [1.23.1] - 2022-03-10

### Added

- Add annotation `app.giantswarm.io/secret-checksum` to dex deployment for automatic restarts of the dex pods on config changes.

### Changed

- Enable upgrade tests again, now that there are two releases in the catalog.

## [1.23.0] - 2022-03-08

### Added

- Add PodDisruptionBudget with `minAvailable: 1`

## [1.22.2] - 2022-02-24

### Changed

- Push to `giantswarm` app catalog.

## [1.22.1] - 2022-02-23


### Changed

- Use user id 1000.

## [1.22.0] - 2022-02-23


### Added

- Added `securityContext` attribute to all deployments.
- Add `application.giantswarm.io/values-schema` and `application.giantswarm.io/readme` annotations to Chart.yaml; use `app-build-suite` to generate `application.giantswarm.io/metadata`.

### Changed

- Run two replicas of `dex`.
- Update README for clarity.

## [1.21.1] - 2022-01-27

### Added

- Add `clusterCA` in dex authenticator configmap from cluster values.
- Add `smoke` test scenario to check if the chart can be deployed.
- Add schema validation for the `dex-app` helm chart.

## [1.21.0] - 2021-12-09

### Fixed

- Update `dex` to `v2.30.2-gs3` patch. This fixes a bug in `v2.30.2-gs2` which caused redundant group name prefixing to occur on token refresh.

## [1.20.0] - 2021-12-07

### Changed

- Roll back to version 2.30.0

## [1.19.1] - 2021-12-07

### Fixed

- Remove kubernetes version requirement from helm chart.

## [1.19.0] - 2021-12-07

### Changed

- Add `cluster_id` label to telemetry metrics to allow filtering by workload clusters.
- Update `dex` to v2.30.2.
- Add Job allowing recreation of certificate secrets when upgrading and disabled lets encrypt.

## [1.18.0] - 2021-11-25

### Added

- Enable telemetry under `/metrics` on port 5558.

## [1.17.0] - 2021-11-24

### Added

- Add support for more than one customer connector.

## [1.16.0] - 2021-10-25

### Changed

- Change dex image to fix refreshing token

## [1.15.0] - 2021-10-22

### Changed

- Make easier the configuration for Workload Clusters.
- Bring the changes needed to run in Kubernetes 1.21.

## [1.14.1] - 2021-10-18

### Changed

- Use SVG icon from our own server

## [1.14.0] - 2021-10-05

### Changed

- Adapt it to be run in a Giant Swarm Workload Cluster too.
- Bring new dex 2.30.0 version to be compatible with Kuberentes 1.21.x.

## [1.13.0] - 2021-08-13

### Fixed

- Fix Kubernetes API address in `dex-k8s-authenticator`.

## [1.12.1] - 2021-08-09

### Fixed

- Fix certificate secret for dex-k8s-authenticator.

## [1.12.0] - 2021-08-09

### Changed

- Wording update: change "control plane" to "management cluster"
- Make customer connector descriptions more user friendly
- Prepare helm values to configuration management.
- Update architect-orb to v4.0.0.

## [1.11.2] - 2021-06-17

### Changed

- Change ingress API version to `networking.k8s.io/v1` (falling back to `networking.k8s.io/v1beta1` where the first is not available).

## [1.11.1] - 2021-06-14

- New release after updating architect-orb

## [1.11.0] - 2021-06-14

### Changed

- Set more explicit name for the Giant Swarm staff connector, to make it easy to distinguish it from a customer's connector
- Update architect-orb to v2.11.0

## [1.10.0] - 2021-05-05

### Added

- Add Grafana as static client.

## [1.9.1] - 2021-04-29

### Changed

- Add group name prefix also when refreshing a token.

## [1.9.0] - 2021-04-26

### Changed

- Start using forked `dex` version with connector IDs as OIDC groups prefixes.

## [1.8.1] - 2021-03-25

### Changed

- Update `dex` to v2.28.1.
- Add annotation for owning team
- Update devctl and architect version
- Add pushing to VMware app collection
- Fix Giant Swarm logo URL

## [1.8.0] - 2021-03-10

## [1.7.0] - 2021-03-04

## [1.6.0] - 2021-02-17

### Changed

- Update `dex` to `v2.27.0`.
- Update `dex-k8s-authenticator` to `v1.4.0`.

## [1.5.0] - 2020-12-03

### Added

- Add root CA for `dex-k8s-authenticator`, installed into environments with disabled Letsencrypt.

## [1.4.0] - 2020-11-20

### Changed

- Replace Google connector with Github connector for GiantSwarm staff.

## [1.3.1] - 2020-11-20

### Fixed

- Fix helm template to always install required `dex`/`dex-k8s-authenticator` workloads.
- Route `dex-k8s-authenticator` to proper `/callback` endpoint.

## [1.3.0] - 2020-11-20

### Added

- Add separate instance of `dex-k8s-authenticator` to handle GiantSwarm staff access.

## [1.2.2] - 2020-07-28

### Fixed

- Fix github release workflow.

## [1.2.1] - 2020-07-28

### Added

- Add github release workflows.

## [1.2.0] - 2020-07-28

### Added

- Add support for ingress raw tls certificates.

## [1.1.0] - 2020-07-08

### Added

- Add github release workflows.

### Changed

- Use `dex` `v2.24.0-giantswarm` tag, which includes Microsoft OIDC connector `offline_scope` fix (https://github.com/dexidp/dex/pull/1441).

## [1.0.0] - 2020-05-05

### Added

- Add condition for ingress resource installation.
- Add support for internal Control Plane API access.

## [0.1.0] - 2020-02-13

### Added

- Add helm chart for dex.


[Unreleased]: https://github.com/giantswarm/dex-app/compare/v2.1.1...HEAD
[2.1.1]: https://github.com/giantswarm/dex-app/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/giantswarm/dex-app/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/giantswarm/dex-app/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/giantswarm/dex-app/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/giantswarm/dex-app/compare/v1.42.15...v2.0.0
[1.42.15]: https://github.com/giantswarm/dex-app/compare/v1.42.14...v1.42.15
[1.42.14]: https://github.com/giantswarm/dex-app/compare/v1.42.13...v1.42.14
[1.42.13]: https://github.com/giantswarm/dex-app/compare/v1.42.12...v1.42.13
[1.42.12]: https://github.com/giantswarm/dex-app/compare/v1.42.11...v1.42.12
[1.42.11]: https://github.com/giantswarm/dex-app/compare/v1.42.10...v1.42.11
[1.42.10]: https://github.com/giantswarm/dex-app/compare/v1.42.9...v1.42.10
[1.42.9]: https://github.com/giantswarm/dex-app/compare/v1.42.8...v1.42.9
[1.42.8]: https://github.com/giantswarm/dex-app/compare/v1.42.7...v1.42.8
[1.42.7]: https://github.com/giantswarm/dex-app/compare/v1.42.6...v1.42.7
[1.42.6]: https://github.com/giantswarm/dex-app/compare/v1.42.5...v1.42.6
[1.42.5]: https://github.com/giantswarm/dex-app/compare/v1.42.4...v1.42.5
[1.42.4]: https://github.com/giantswarm/dex-app/compare/v1.42.3...v1.42.4
[1.42.3]: https://github.com/giantswarm/dex-app/compare/v1.42.2...v1.42.3
[1.42.2]: https://github.com/giantswarm/dex-app/compare/v1.42.1...v1.42.2
[1.42.1]: https://github.com/giantswarm/dex-app/compare/v1.42.0...v1.42.1
[1.42.0]: https://github.com/giantswarm/dex-app/compare/v1.41.0...v1.42.0
[1.41.0]: https://github.com/giantswarm/dex-app/compare/v1.40.0...v1.41.0
[1.40.0]: https://github.com/giantswarm/dex-app/compare/v1.39.0...v1.40.0
[1.39.0]: https://github.com/giantswarm/dex-app/compare/v1.38.0...v1.39.0
[1.38.0]: https://github.com/giantswarm/dex-app/compare/v1.37.0...v1.38.0
[1.37.0]: https://github.com/giantswarm/dex-app/compare/v1.36.0...v1.37.0
[1.36.0]: https://github.com/giantswarm/dex-app/compare/v1.35.0...v1.36.0
[1.35.0]: https://github.com/giantswarm/dex-app/compare/v1.34.3...v1.35.0
[1.34.3]: https://github.com/giantswarm/dex-app/compare/v1.34.2...v1.34.3
[1.34.2]: https://github.com/giantswarm/dex-app/compare/v1.34.1...v1.34.2
[1.34.1]: https://github.com/giantswarm/dex-app/compare/v1.34.0...v1.34.1
[1.34.0]: https://github.com/giantswarm/dex-app/compare/v1.33.0...v1.34.0
[1.33.0]: https://github.com/giantswarm/dex-app/compare/v1.32.3...v1.33.0
[1.32.3]: https://github.com/giantswarm/dex-app/compare/v1.32.2...v1.32.3
[1.32.2]: https://github.com/giantswarm/dex-app/compare/v1.32.1...v1.32.2
[1.32.1]: https://github.com/giantswarm/dex-app/compare/v1.32.0...v1.32.1
[1.32.0]: https://github.com/giantswarm/dex-app/compare/v1.31.2...v1.32.0
[1.31.2]: https://github.com/giantswarm/dex-app/compare/v1.31.1...v1.31.2
[1.31.1]: https://github.com/giantswarm/dex-app/compare/v1.31.0...v1.31.1
[1.31.0]: https://github.com/giantswarm/dex-app/compare/v1.30.2...v1.31.0
[1.30.2]: https://github.com/giantswarm/dex-app/compare/v1.30.1...v1.30.2
[1.30.1]: https://github.com/giantswarm/dex-app/compare/v1.30.0...v1.30.1
[1.30.0]: https://github.com/giantswarm/dex-app/compare/v1.29.0...v1.30.0
[1.29.0]: https://github.com/giantswarm/dex-app/compare/v1.28.0...v1.29.0
[1.28.0]: https://github.com/giantswarm/dex-app/compare/v1.27.0...v1.28.0
[1.27.0]: https://github.com/giantswarm/dex-app/compare/v1.25.2...v1.27.0
[1.25.2]: https://github.com/giantswarm/dex-app/compare/v1.25.1...v1.25.2
[1.25.1]: https://github.com/giantswarm/dex-app/compare/v1.25.0...v1.25.1
[1.25.0]: https://github.com/giantswarm/dex-app/compare/v1.24.2...v1.25.0
[1.24.2]: https://github.com/giantswarm/dex-app/compare/v1.24.1...v1.24.2
[1.24.1]: https://github.com/giantswarm/dex-app/compare/v1.24.0...v1.24.1
[1.24.0]: https://github.com/giantswarm/dex-app/compare/v1.23.1...v1.24.0
[1.23.1]: https://github.com/giantswarm/dex-app/compare/v1.23.0...v1.23.1
[1.23.0]: https://github.com/giantswarm/dex-app/compare/v1.22.2...v1.23.0
[1.22.2]: https://github.com/giantswarm/dex-app/compare/v1.22.1...v1.22.2
[1.22.1]: https://github.com/giantswarm/dex-app/compare/v1.22.0...v1.22.1
[1.22.0]: https://github.com/giantswarm/dex-app/compare/v1.21.1...v1.22.0
[1.21.1]: https://github.com/giantswarm/dex-app/compare/v1.21.0...v1.21.1
[1.21.0]: https://github.com/giantswarm/dex-app/compare/v1.20.0...v1.21.0
[1.20.0]: https://github.com/giantswarm/dex-app/compare/v1.19.1...v1.20.0
[1.19.1]: https://github.com/giantswarm/dex-app/compare/v1.19.0...v1.19.1
[1.19.0]: https://github.com/giantswarm/dex-app/compare/v1.18.0...v1.19.0
[1.18.0]: https://github.com/giantswarm/dex-app/compare/v1.17.0...v1.18.0
[1.17.0]: https://github.com/giantswarm/dex-app/compare/v1.16.0...v1.17.0
[1.16.0]: https://github.com/giantswarm/dex-app/compare/v1.15.0...v1.16.0
[1.15.0]: https://github.com/giantswarm/dex-app/compare/v1.14.1...v1.15.0
[1.14.1]: https://github.com/giantswarm/dex-app/compare/v1.14.0...v1.14.1
[1.14.0]: https://github.com/giantswarm/dex-app/compare/v1.13.0...v1.14.0
[1.13.0]: https://github.com/giantswarm/dex-app/compare/v1.12.1...v1.13.0
[1.12.1]: https://github.com/giantswarm/dex-app/compare/v1.12.0...v1.12.1
[1.12.0]: https://github.com/giantswarm/dex-app/compare/v1.11.2...v1.12.0
[1.11.2]: https://github.com/giantswarm/dex-app/compare/v1.11.1...v1.11.2
[1.11.1]: https://github.com/giantswarm/dex-app/compare/v1.11.0...v1.11.1
[1.11.0]: https://github.com/giantswarm/dex-app/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/giantswarm/dex-app/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/giantswarm/dex-app/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/giantswarm/dex-app/compare/v1.8.1...v1.9.0
[1.8.1]: https://github.com/giantswarm/dex-app/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/giantswarm/dex-app/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/giantswarm/dex-app/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/giantswarm/dex-app/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/giantswarm/dex-app/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/giantswarm/dex-app/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/giantswarm/dex-app/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/giantswarm/dex-app/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/giantswarm/dex-app/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/giantswarm/dex-app/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/giantswarm/dex-app/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/giantswarm/dex-app/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/giantswarm/dex-app/tag/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/giantswarm/dex-app/tag/v0.1.0
