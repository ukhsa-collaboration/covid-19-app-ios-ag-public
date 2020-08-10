# Using the Domain Module

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Role of `Domain`](#role-of-domain)
- [Application Coordinator](#application-coordinator)
- [Deriving the Application State](#deriving-the-application-state)
  - [`RawState`](#rawstate)
  - [`LogicalState`](#logicalstate)
  - [`ApplicationState`](#applicationstate)
- [Using the Application State](#using-the-application-state)
- [Best Practices](#best-practices)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Role of `Domain`

The `Domain` module is the “brain” of the app. All logic like what state the app is in, how to talk to services, what to store is in the `Domain` module.

On the other hand, `Domain` should not do anything on its own that has a side effect directly. It should instead delegate that action to other parts of the app.

Broadly speaking, this delegation happens with two different patterns.

* Interactions with the _operating system_, like IO, asking for permissions, or sending notifications is done by interfaces that are injected into `Domain` when its types are constructed.
* Interactions with the _user_, like asking for postal district, or starting a self-diagnosis flow are done by providing types that the app’s GUI can call at the right time.

## Application Coordinator

`ApplicationCoordinator` is the entry point to `Domain` module. When creating an `ApplicationCoordinator`, you need to inject conformances to protocols that represents interactions with the system. In a “real” app, these conformances follow one of these two patterns:

In some cases, directly inject an instance of a system type (such as `UIApplication` or `ENManager`). This is primarily so that we can provide mocks for these during tests that simulate the operating system’s behaviour.

In other cases, we inject a custom type that implement an abstracts of lower-level operations (such as `HTTPClient` or `EncryptedStoring`). This provides us a central place where we can apply implementation policies.

For example, our implementation of `HTTPClient` will include all of our networking security policities, and we can have the confidence that if we change those policies in future, it will automatically apply to all features.

At the same time, these APIs also allow us to inject mocks during testing that are more convienent to use. For example, in an acceptance test that the postal district is stored, we do not need to fiddle with how the data is encrypted.

## Deriving the Application State

After creating `ApplicationCoordinator`, majority of interactions with it is by inspecting its `state` property. This is a published property that updates itself automatically.

The rest of this section describes _how_ the `ApplicationCoordinator` derives its state.

### `RawState`

This type purely collects the types from the application’s sub-systems, like exposure notification, postcode, etc. . `RawState` is a data type. This allows us to have unit tests for the next step without expensive test set up.

### `LogicalState`

This represents the logical state of the application, such as “we should do postcode onboarding”.

`LogicalState` is also a data type, and is calculated from `RawState` with a pure function.

`LogicalState` is also `Equatable`. This is important, since we need to deduplicate transitions from one state to _itself_ before we recreate all the types and associated UI.

### `ApplicationState`

Finally, `ApplicationState` is the facade that is publicly exposed from the `Domain` module to the rest of the app. Each case in There’s a one-to-one correspondence between cases of `LogicalState` and `ApplicationState`.

However, the latter injects the functionality that the rest of the app (such as the UI) is allowed to perform _only if_ we’re in that state. This way, `Domain` can control its internal invariants.

For example, we can enforce that no one can trigger a key upload flow unless we are in the right state.

## Using the Application State

The payload for `ApplicationState`’s cases are designed to work with the assumption that the app _is_ in that state. With that in mind, you should take care to use these _only_ as long as the application state hasn’t changed.

`ApplicationCoordinator` doesn’t provide any guarantees on which thread the state changes are reported. It’s the responsibility of the integration / interface logic to ensure UI changes are applied on the main thread. See [Updating Interface](UpdatingInterface.md) on how we achieve this.

## Best Practices

Try to minimise the `public` API exposed from `Domain`. This could lead to confusing around _which_ API should be used in which context. Instead, there should be single source of truth for performing any action supported by `Domain`.

Think of `Domain` as an API contract. Just like the contract between the app and backend services. It’s often possible to implement the “frontend” of a feature completely independantly of its “backend” if the correct API contract is defined on `Domain`.

In fact, `Domain` and `Interface` do not depend on each other exactly to avoid unexpected coupling of logic, and doing logic as part of UI.

Be especially careful with code that performs serialisation. It’s tempting to just make a type that is passed around as `Codable` to derive serialisation. This is fragile. Ensure you have separate tests for _each_ use case. For example, if a type is downloaded from backend, but is also persisted on this, these should have separate tests to make sure evolving one doesn’t break the other.    
