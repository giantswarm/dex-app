[![CircleCI](https://circleci.com/gh/giantswarm/dex-app.svg?style=shield&circle-token=7552290f91277c20801ee5bf7ff8c754a9f59d6d)](https://circleci.com/gh/giantswarm/dex-app)

# dex-app chart

Giant Swarm dex Managed App is installed in management clusters by default and ready to be deployed in workload clusters too.
It provides customer authentication into control-plane Kubernetes.

`dex-app` consists of two components:
  - `dex` - cluster issuer
  - `dex-k8s-authenticator` - dex client, which simplifies token generation towards `dex` connectors.

## Installing the Chart

To install the chart locally:

```bash
$ git clone https://github.com/giantswarm/dex-app.git
$ cd dex-app
$ helm install helm/dex-app -f values.yaml # values provided explicitly
```

Provide a custom `values.yaml`:

```bash
$ helm install dex-app -f values.yaml
```

Deployment to Management Cluster is handled by [app-operator](https://github.com/giantswarm/app-operator).

### Installing the Chart in Giant Swarm workload clusters

In Giant Swarm we allow the customers to install Apps using our [App Platform](https://docs.giantswarm.io/app-platform/). You need to define the configuration (`values.yaml`) in a configmap upfront

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dex-app-user-values
  namespace: <CLUSTERID>
data:
  values: |
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
        ## For Keyclock
        - id: customer
          connectorName: test
          connectorType: oidc
          connectorConfig: >-
            clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
            clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
            insecureEnableGroups: true
            scopes:
            - email
            - groups
            - profile
            issuer: https://<IDP_ENDPOINT>/auth/realms/master
            redirectURI: https://dex.<CLUSTERID>.<BASEDOMAIN>/callback
        ## For Active Directory
        - id: customer
          connectorName: test
          connectorType: microsoft
          connectorConfig: >-
            clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
            clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
            tenant: <TENANT-SET-SET-IN--YOUR-IdP>
            redirectURI: https://dex.<CLUSTERID>.<BASEDOMAIN>/callback
        ## For Github  
        - id: customer
          connectorName: test
          connectorType: github
          connectorConfig: >-
            clientID: <CLIENT-ID-SET-IN-YOUR-IdP>
            clientSecret: <CLIENT-SECRET-SET-IN--YOUR-IdP>
            loadAllGroups: false
            orgs:
            - name: <GITHUB_ORG_NAME>
              teams:
              - <GITHUB_TEAM_NAME>
            redirectURI: https://dex.<CLUSTERID>.<BASEDOMAIN>/callback
```

__Note__: In the above snippet you have to replace the `<CLUSTERID>` variable and add the Kubernetes Certificate Authority to ensure Dex can trust the API endpoint. Finally you have to use a connector. Here we show three example values.
You can use more than one connector, but they need to have a different `id` value.
We advice to use `- id: customer` for your primary connector.

Later you create an App Custom Resource (CR) that points to our catalog with the values defined before

```yaml
apiVersion: application.giantswarm.io/v1alpha1

kind: App
metadata:
  labels:
    app.kubernetes.io/name: dex-app
  name: dex-app
  namespace: <CLUSTERID>
spec:
  catalog: giantswarm-playground
  name: dex-app
  namespace: dex
  userConfig:
    configMap:
      name: dex-app-user-values
      namespace: <CLUSTERID>
```
__Note__: When applying the example in the snippet above, please change the `<CLUSTERID>` variable to the cluster ID of the workload cluster you are configuring.

Now submitting both resources to the management API our automation will make sure your dex app is deployed and configured correctly.

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

* Ensure CHANGELOG.md is up to date.
* In case of changes to `values.yaml`, ensure that `values.schema.json` is updated to reflect all values and their types correctly.
* Create a branch `master#release#v<major.minor.patch>`, wait for the according release PR to be created, approve it, merge it.
* This will push a new git tag and trigger a new tarball to be pushed to the
[control-plane-catalog](https://github.com/giantswarm/control-plane-catalog).

## Links

- [dex](https://github.com/dexidp/dex)
- [dex-k8s-authenticator](https://github.com/mintel/dex-k8s-authenticator)
