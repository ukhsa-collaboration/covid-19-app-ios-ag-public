//
// Copyright © 2020 NHSX. All rights reserved.
//

@propertyWrapper
public struct TestInjected<Value> {
    private let key: String
    private var userDefault: UserDefault<Value>
    
    init(_ key: String, defaultValue: Value) {
        self.key = key
        userDefault = UserDefault(key, defaultValue: defaultValue)
    }
    
    init<T>(_ key: String) where Value == T? {
        self.key = key
        userDefault = UserDefault(key)
    }
    
    public var wrappedValue: Value {
        get {
            userDefault.wrappedValue
        } set {
            userDefault.wrappedValue = newValue
        }
    }
    
    public var projectedValue: TestInjected<Value> {
        self
    }
    
    public static subscript<Instance: Sandbox.InitialState, Value>(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, TestInjected<Value>>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].wrappedValue
        } set {
            instance[keyPath: storageKeyPath].wrappedValue = newValue
            let testInjected = instance[keyPath: storageKeyPath]
            instance.modifiedLaunchArguments[testInjected.key] = testInjected.launchArgumentValue
        }
    }
}

extension TestInjected {
    private var launchArgumentValue: String {
        switch wrappedValue {
        case let value as Bool:
            return value ? "<true/>" : "<false/>"
        case let value as String:
            return value
        case let value as Int:
            return "<integer>\(value)</integer>"
        case let value as Double:
            return "<real>\(value)</real>"
        default:
            preconditionFailure("""
                Attempting to pass an invalid type through launch arguments.
                If the property being set is optional, it cannot be set to nil
            """)
        }
    }
    
    var launchArgument: [String] {
        ["-\(key)", "\(launchArgumentValue)"]
    }
}
