# Dependencies

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Retrieving dependencies](#retrieving-dependencies)
- [List of dependencies](#list-of-dependencies)
  - [Used in production](#used-in-production)
  - [Used internally](#used-internally)
  - [Used on CI](#used-on-ci)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Retrieving dependencies

All dependencies are retrieved via Swift Package Manager and compiled from source. You can see these imports in:

* [Package file for app modules](../NHS-COVID-19/Core/Package.swift)
* [Package file for CI scripts](../Reporting/Package.swift)

## List of dependencies

### Used in production

| Dependency | Purpose | Licence |
|-|-|-|
| [`ZIPFoundation`](https://github.com/weichsel/ZIPFoundation) | Unpack zip files | [MIT](https://github.com/weichsel/ZIPFoundation/blob/development/LICENSE) |
| [`swift-log`](https://github.com/apple/swift-log) | Interface for logging (note: logging is fully disabled in production) | [Apache 2.0](https://github.com/apple/swift-log/blob/master/LICENSE.txt) |
| [`AppConfiguration`](https://github.com/nhsx/covid-19-app-configuration-public.git) | Contains application configuration, such as endpoints | N/A (Internal) |

### Used internally

| Dependency | Purpose | Licence |
|-|-|-|
| [`SwiftProtobuf`](https://github.com/apple/swift-protobuf) | Create exposure key bundles for testing | [Apache 2.0](https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt) |

### Used on CI

| Dependency | Purpose | Licence |
|-|-|-|
| [`swift-argument-parser`](https://github.com/apple/swift-argument-parser) | Create command line interface for CI tasks | [Apache 2.0](https://github.com/apple/swift-argument-parser/blob/master/LICENSE.txt) |
