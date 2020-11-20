# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fix helm template to always install required `dex`/`dex-k8s-authenticator` workloads.

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

[Unreleased]: https://github.com/giantswarm/dex-app/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/giantswarm/dex-app/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/giantswarm/dex-app/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/giantswarm/dex-app/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/giantswarm/dex-app/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/giantswarm/dex-app/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/giantswarm/dex-app/tag/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/giantswarm/dex-app/tag/v0.1.0
