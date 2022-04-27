# Kaptain Catalog Application

Manifests for integration Kaptain into DKP catalog.

## Development workflow

To switch to the next development version:
```sh
make prepare-dev SOURCE_VERSION=2.0.0 TARGET_VERSION=2.1.0-dev
```

`SOURCE_VERSION` will be used as a base, `TARGET_VERSION` should match Kaptain chart version.

To switch to the release version of the manifests:

```sh
make prepare-release SOURCE_VERSION=2.1.0-dev TARGET_VERSION=2.1.0
```
