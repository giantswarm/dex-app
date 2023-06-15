[![CircleCI](https://circleci.com/gh/giantswarm/dex-app.svg?style=shield&circle-token=7552290f91277c20801ee5bf7ff8c754a9f59d6d)](https://circleci.com/gh/giantswarm/dex-app)

# Dex

[Dex](https://dexidp.io/) is an identity service that uses OpenID Connect to handle authentication for Kubernetes. It connects to third party identity providers like Active Directory, LDAP, and GitHub. While the Kubernetes API server only supports a single identity provider and OIDC token issuer, the use of Dex allows to use identities from various providers when authenticating for Kubernetes.

This app is installed in Giant Swarm management clusters by default and is also ready to be deployed in workload clusters.

In addition to Dex itself, this app provides [Dex K8s Authenticator](https://github.com/mintel/dex-k8s-authenticator), which helps to configure `kubectl` for clusters authenticated to via Dex.

## Installing

There are several ways to install this app.

1. [Using our web interface](https://docs.giantswarm.io/ui-api/web/app-platform/#installing-an-app)
2. Creating the [App resource](https://docs.giantswarm.io/ui-api/management-api/crd/apps.application.giantswarm.io/) in the management cluster. Check the [getting started with app platform](https://docs.giantswarm.io/app-platform/getting-started/) guide for details.

## Configuring

You provide your configration via a custom `values.yaml` file. Here is an example using the connector for Azure Active Directory. More connector examples can be found below.

```yaml
isWorkloadCluster: true
services:
  kubernetes:
    api:
      caPem: |
        -----BEGIN CERTIFICATE-----
        M...=
        -----END CERTIFICATE-----
oidc:
  expiry:
    signingKeys: 6h
    idTokens: 30m
  customer:
    enabled: true
    connectors:
    - id: customer
      connectorName: test
      connectorType: microsoft
      connectorConfig: |-
        clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
        clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
        tenant: <TENANT-SET-SET-IN--YOUR-IdP>
        redirectURI: https://dex.<CLUSTER>.<BASEDOMAIN>/callback
```

Some notes:

- `.service.kubernetes.api.caPem` is the CA certificate of your workload cluster in PEM format. At Giant Swarm, you can retrieve this certificate via the [kubectl gs login](https://docs.giantswarm.io/ui-api/kubectl-gs/login/) command, when creating a client certificate for the workload cluster. It ends up in Base46-encoded form in your kubectl config file. The CA certificate is required by Dex K8s Authenticator.

- The `redirectURI` in your connector configuration must contain the proper host name for Dex's own ingress. In the default form, it contains the workload cluster name (replace `<CLUSTER>` with the actual name) and a base domain (replace `<BASEDOMAIN>` with the proper base domain).

- If you configure more than one connector, make sure to set a unique `id` for each one. Be aware that this version of Dex is configured to prefix all user group names with the connector ID. So if your connector's `id` is `customer`, a membership in group `devops` will appear as `customer:devops`.

### Other connector types

Example connector configuration for Keycloak:

```yaml
    - id: customer
      connectorName: test
      connectorType: oidc
      connectorConfig: |-
        clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
        clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
        insecureEnableGroups: true
        scopes:
        - email
        - groups
        - profile
        issuer: https://<IDP_ENDPOINT>/auth/realms/master
        redirectURI: https://dex.<CLUSTERID>.<BASEDOMAIN>/callback
```

Example connector configuration for GitHub:

```yaml
    - id: customer
      connectorName: test
      connectorType: github
      connectorConfig: |-
        clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
        clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
        loadAllGroups: false
        teamNameField: slug
        orgs:
        - name: <GITHUB_ORG_NAME>
          teams:
          - <GITHUB_TEAM_SLUG>
        redirectURI: https://dex.<CLUSTERID>.<BASEDOMAIN>/callback
```

Note:

- `<GITHUB_ORG_NAME>` is your GitHub organization name. For example, the part `myorg` in `https://github.com/myorg`.
- `<GITHUB_TEAM_SLUG>` is the part of the team's URL representing the team name. For example, the part `my-team` in `https://github.com/orgs/myorg/teams/my-team`.

### Installing the Chart in Giant Swarm workload clusters

The app is installed in workload clusters, via our [app platform](https://docs.giantswarm.io/app-platform/). 
Before doing so, please create the following `ConfigMap` resource in the namespace named after that workload cluster to provide the contents of your `values.yaml` file.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dex-app-user-values
  namespace: <CLUSTER>
data:
  values: |
    <content of values.yaml>
```

Then you either install the app via our web UI, or you'll create an App resource in the following format:

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  labels:
    app.kubernetes.io/name: dex-app
  name: dex-app
  namespace: <CLUSTER>
spec:
  catalog: giantswarm-playground
  name: dex-app
  namespace: dex
  userConfig:
    configMap:
      name: <CONFIGMAPNAME>
      namespace: <CLUSTER>
```

Notes:

- `<CONFIGMAPNAME>` must be replaced with the name of the ConfigMap resource shown above.
- `<CLUSTER>` is replaced with the name of your workload cluster.

As a result, you should see Dex deployed in your workload cluster.

### Ingress, TLS and custom certification authorities

Dex app exposes a web interface, which is accessible over https. Therefore, it creates an ingress, which needs to be configured with a TLS certificate signed by a certification authority, which needs to be trusted by the browsers. 
The app consists of several components, which also need to be able to communicate with each other internally over https. So the certification authority signing the certificates needs to be trusted by the individual app components as well.

In case a custom certification authority is used, it needs to be exposed to the individual app components and set as trusted, otherwise the components will not be able to communicate with each other and the app may not work as expected.
Based on the cluster setup, this can be achieved by providing an additional set of values to the app configuration:

1. Add a base64-encoded certificate of the certification authority to the User Values configmap or secret. This option is useful when using custom, self-signed certificates in a cluster:

```yaml
ingress:
  tls:
    letsencrypt: false
    caPemB64: "base64-encoded CA certificate"
```

2. Provide a reference to an existing Secret resource, which contains the custom certification authority. This option is useful for cluster setup, where TLS certificates signed by a custom certification authority are provided by an external service:

```yaml
ingress:
  tls:
    letsencrypt: false

trustedRootCA:
  name: "name-of-the property-in-the-secret"
  secretName: "name-of-the-custom-ca-secret"
```

### Proxy configuration

In case the traffic to Dex needs to go through a proxy (for example when the app is installed in a private cluster), the individual components of the app need to be set up to use the proxy.

The proxy setup can be provided to the app in a specific section of the user values configmap or secret with the app configuration:

```yaml
cluster:
  proxy:
    http: "https://proxy.host:4040" # hostname of the proxy for HTTP traffic
    https: "https://proxy.host:4040" # hostname of the proxy for HTTPS traffic
    noProxy: "kubernetes-api-ip-range" # comma-separated list of hostnames and IP ranges, whose traffic should not go through the proxy. # Kubernetes API IP range needs to be defined here in order for Dex to work correctly
```

## Update Process

Giant Swarm is currently building the `dex` app from [a fork](https://github.com/giantswarm/dex) of the [original project](https://github.com/dexidp/dex).
We implement additional logic which adds the connector id as prefix to user groups.
In order to update the image used in this chart it is currently needed to to do the following steps in our fork repo:

- Fetch upstream changes.
- Ensure that our commits with prefixing logic on token creation _and_ refresh are present on the branch we want to release from.
- Ensure CircleCI builds are green
- Create the version tag with -gs suffix to push the image to our registry

Then in this repo:

- Update the image version tag
- Test the new version before releasing. Make sure to test token refresh as well.

## Release Process

- Ensure CHANGELOG.md is up to date.
- In case of changes to `values.yaml`, ensure that `values.schema.json` is updated to reflect all values and their types correctly.
- Create a branch `master#release#v<major.minor.patch>`, wait for the according release PR to be created, approve it, merge it.
- This will push a new git tag and trigger a new tarball to be pushed to the
[control-plane-catalog](https://github.com/giantswarm/control-plane-catalog).
