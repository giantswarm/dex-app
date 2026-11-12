# Connector values

`oidc.giantswarm.connectors` accepts a map keyed by connector id. Entries from
different Flux values sources merge by key. A list with an `id` per entry is
also accepted. A list and a map in different sources replace one another;
upgrade every writer to maps before relying on merging.

Map entries render in id order. The map key determines the id even when an
entry also contains an `id` field. `connectorType` and `connectorName` set the
Dex connector type and display name. `connectorConfig` carries a YAML string,
or `config` carries a map and takes precedence when both are present.

```yaml
oidc:
  giantswarm:
    connectors:
      federation:
        connectorType: oidc
        connectorName: Federation
        config:
          issuer: https://hub.example.test
          clientID: dex-spoke
          redirectURI: https://dex.spoke.example.test/callback
        clientSecretRef:
          name: dex-connector-federation
          key: client-secret
```

`clientSecretRef` requires `config` as a map and supplies its `clientSecret`,
overriding any inline value. Dex expands the environment variable in that field
at startup. The Secret must be in Dex's namespace. Both the environment reference
and the projected volume are optional, so a missing Secret leaves that connector
without a client secret while Dex starts. Browser login through it fails until
the Secret arrives. The liveness probe restarts Dex when the projected secret
changes, including when a missing Secret first appears. No restart is required
while both the file and the initial environment value are absent.
