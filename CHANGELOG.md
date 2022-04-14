# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Remove wildcards from RBAC rules
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


[Unreleased]: https://github.com/giantswarm/dex-app/compare/v1.24.1...HEAD
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
