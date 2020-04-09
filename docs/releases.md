---
hero: Releases
---

!!! note
    Starting with Synse v3, Synse components have a compatibility matrix in their project
    README describing which version(s) of the project work with which versions of the Synse
    platform.

!!! warning
    With the v3 release of Synse, previous versions of Synse will no longer be supported.

Synse components use [semantic versioning](https://semver.org/) for their releases.
Releases are driven by a CI workflow that is kicked off from a GitHub tag. See the releases
page on a project's GitHub repository for release notes and any build artifacts for that
component.

## Major Version

A major release will include breaking changes. When a new major release
is cut, it will be versioned as ``X.0.0``. For example, if the previous
release version was ``1.4.2``, the next version would be ``2.0.0``.

Breaking changes are changes which break backwards compatibility with previous
versions. Typically, this would mean major changes to the API, the request scheme, or
the response scheme. A new major release should only be done if there are breaking
API changes; it should not occur for standard bug fixes, feature additions, dependency
updates, etc.

## Minor Version

A minor release will not include breaking changes to the API or scheme, but may
otherwise include additions, updates, or bug fixes. If the previous release
version was ``1.4.2``, the next minor release would be ``1.5.0``.

Minor version releases are backwards compatible with releases of the same major
version number, and should strive to be backwards compatible with releases of
lesser minor version.

## Micro Version

A micro release will not include any breaking changes and will typically only
include minor changes, bug fixes, dependency updates, etc. If the previous release
version was ``1.4.2``, the next micro release would be ``1.4.3``.
