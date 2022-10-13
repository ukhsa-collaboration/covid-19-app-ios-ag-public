# Dependencies

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Retrieving dependencies](#retrieving-dependencies)
- [List of dependencies](#list-of-dependencies)
  - [Used in the production app](#used-in-the-production-app)
  - [Used in the internal app](#used-in-the-internal-app)
  - [Used during development](#used-during-development)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Retrieving dependencies

All dependencies are retrieved via Swift Package Manager and compiled from source. You can see these imports in:

* [Package file for app modules](../NHS-COVID-19/Core/Package.swift)
* [Package file for CI scripts](../Reporting/Package.swift)

## List of dependencies

### Used in the production app

| Dependency | Purpose | Licence |
|-|-|-|
| [`ZIPFoundation`](https://github.com/weichsel/ZIPFoundation) | Unpack zip files | [MIT](https://github.com/weichsel/ZIPFoundation/blob/development/LICENSE) |
| [`swift-log`](https://github.com/apple/swift-log) | Interface for logging (note: logging is fully disabled in production) | [Apache 2.0](https://github.com/apple/swift-log/blob/master/LICENSE.txt) |
| [`AppConfiguration`](https://github.com/nihp-public/covid-19-app-configuration.git) | Contains application configuration, such as endpoints | N/A (Internal) |
| [`RiskScore`](https://github.com/nihp-public/riskscore-swift) | Contains the implementation of the risk score algorithm for v2 EN API | N/A (Internal) |
| [`BoostSwift`](https://github.com/nihp-public/BoostSwift) |  A dependency of `RiskScore`. It provides a Swift interface to the Boost C++ function [`gamma_p_inv`](https://www.boost.org/doc/libs/1_74_0/libs/math/doc/html/math_toolkit/sf_gamma/igamma_inv.html) |  The library itself is internal, the wrapped function is covered by the [Boost license](https://www.boost.org/users/license.html) |

### Used in the internal app

| Dependency | Purpose | Licence |
|-|-|-|
| [`SwiftProtobuf`](https://github.com/apple/swift-protobuf) | Create exposure key bundles for testing | [Apache 2.0](https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt) |

### Used during development

| Dependency | Purpose | Licence |
|-|-|-|
| [`swift-argument-parser`](https://github.com/apple/swift-argument-parser) | Create command line interface for CI tasks | [Apache 2.0](https://github.com/apple/swift-argument-parser/blob/master/LICENSE.txt) |
| [`SwiftCheck`](https://github.com/typelift/SwiftCheck) | Used for test generation and assertions in `RiskScore` | [MIT](https://github.com/typelift/SwiftCheck/blob/master/LICENSE) |
| [`FileCheck`](https://github.com/llvm-swift/FileCheck) | Used internally by `SwiftCheck` | [MIT](https://github.com/llvm-swift/FileCheck/blob/master/LICENSE) |
| [`Files`](https://github.com/JohnSundell/Files) | A wrapper around `FileManager`. Used internally by `RiskScore` for verification and generation of test data | [MIT](https://github.com/JohnSundell/Files/blob/master/LICENSE) |
| [`swift-tools-support-core`](https://github.com/apple/swift-tools-support-core) | Used internally by `FileCheck` | [Apache 2.0](https://github.com/apple/swift-tools-support-core/blob/main/LICENSE.txt) |
| [`Chalk`](https://github.com/mxcl/Chalk) | Used internally by `FileCheck`. It provides terminal colour definitions | [Public Domain](https://github.com/mxcl/Chalk/blob/master/LICENSE) |
