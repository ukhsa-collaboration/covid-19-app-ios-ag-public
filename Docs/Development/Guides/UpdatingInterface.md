# Updating Interface

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Context](#context)
- [`InterfaceProperty`](#interfaceproperty)
  - [Updating `SwiftUI` Views](#updating-swiftui-views)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Context

Changes from `Domain` that can change over time are exposed as a `Combine` publishers. Using publishers is a very good way of broadcasting changes. Unfortunately, currently there is a mismatch between how publishers are provided, and how `UIKit` and `SwiftUI` expect to consume them.

Using publishers in `UIKit` is somewhat awkward, as we need to add a sink, manage cancellable, and make sure we pass the data to the main thread.

Using publishers in `SwiftUI` is inconvenient in a different way: In order for `SwiftUI` to be notified of changes, publishers need to be wrapped into an `ObservableObject`. Also, we still need to make sure the updates happen on the main thread.

## `InterfaceProperty`

`InterfaceProperty` type is here to help with these issues. Currently, this focuses on integration with `SwiftUI`. We will add more ergonomic way of using `InterfaceProperty` from `UIKit` in the future.

### Updating `SwiftUI` Views

`InterfaceProperty` type conforms to `ObservableObject` protocol. This means we can pass it and use it from a `SwiftUI.View` as is:

```swift
public struct RiskView: View {
    @ObservedProperty private var isRisky: InterfaceProperty<Bool>

    public init(isRisky: InterfaceProperty<Bool>) {
        self.isRisky = isRisky
    }

    public var body: some View {
        Text(isRisky.wrappedValue ? "Risky" : "Not risky")
    }
}
```

You can create an `InterfaceProperty` from a publisher:

```swift
var isRisky: AnyPublisher<Bool, Never> = ...
RiskView(isRisky: isRisky.property(initialValue: false))
```

Or (usually in Scenarios) from a constant value:

```swift
RiskView(isRisky: .constant(false))
```

Internally, `InterfaceProperty` ensures its value only changes on the main thread. So there’s no need for manual thread configuration.

Unfortunately, there is still some boilerplate when using `InterfaceProperty` types inside view models – in particular, to make sure the `objectWillChange` publisher is passed along correctly. For an example of how this is done, see `RiskLevelBanner.ViewModel`.
