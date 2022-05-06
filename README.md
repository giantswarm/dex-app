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
