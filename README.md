[![CircleCI](https://circleci.com/gh/giantswarm/dex-app.svg?style=shield&circle-token=7552290f91277c20801ee5bf7ff8c754a9f59d6d)](https://circleci.com/gh/giantswarm/dex-app)

# dex-app chart

Giant Swarm dex Managed App is installed in control-plane.
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

Deployment to Control-Plane is handled by [app-operator](https://github.com/giantswarm/app-operator).

## Release Process

* Ensure CHANGELOG.md is up to date.
* Create a branch `master#release#v<major.minor.patch>`, wait for the according release PR to be created, approve it, merge it.
* This will push a new git tag and trigger a new tarball to be pushed to the
[control-plane-catalog](https://github.com/giantswarm/control-plane-catalog).

## Links

- [dex](https://github.com/dexidp/dex)
- [dex-k8s-authenticator](https://github.com/mintel/dex-k8s-authenticator)
