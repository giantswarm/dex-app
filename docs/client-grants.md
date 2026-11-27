# Client grant restrictions

The Dex image must carry [per-client grant restrictions](https://github.com/giantswarm/dex/pull/106)
before enabling `client_credentials`. The chart's release pin must include that change.

`oidc.staticClients.<name>.grantTypes` restricts a built-in client. An empty list
preserves all server-enabled grants except `client_credentials`. The schema rejects
`client_credentials` on built-in clients, including `dexK8SAuthenticator`.
`allowedConnectors` on the same client restricts its authentication connectors;
an empty list leaves connector selection unrestricted.

An extra client's `grantTypes` is passed to Dex in both map and list form.
Omitted or empty lists preserve Dex's legacy policy, so give every confidential
extra client an explicit list before enabling application grants server-wide.

```yaml
oidc:
  grantTypes:
  - authorization_code
  - refresh_token
  - urn:ietf:params:oauth:grant-type:token-exchange
  - client_credentials
  staticClients:
    muster:
      grantTypes: [authorization_code, refresh_token]
      allowedConnectors: [staff]
  extraStaticClients:
    application:
      name: Application
      secretRef:
        name: dex-client-application
        key: secret
      grantTypes: [client_credentials]
```

`client_credentials` represents an application, with resource permissions decided
by RBAC. It supplies no end-user identity. Session references and request metadata
are not authorization evidence.
