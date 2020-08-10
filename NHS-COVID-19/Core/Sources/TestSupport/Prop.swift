//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest

public protocol TestPropConfiguration {
    init()
}

public protocol TestProp {
    associatedtype Configuration = Void
    
    static func prepare(_ test: XCTestCase)
    static var defaultConfiguration: Configuration { get }
    init(configuration: Configuration) throws
}

public extension TestProp {
    
    static func prepare(_ test: XCTestCase) {}
    
}

public extension TestProp where Configuration: TestPropConfiguration {
    
    static var defaultConfiguration: Configuration { Configuration() }
    
}

public extension TestProp where Configuration == Void {
    
    static var defaultConfiguration: Void { () }
    
}

@propertyWrapper
public class Propped<Prop: TestProp> {
    
    private enum State {
        case notInitialized
        case initialized(Prop)
    }
    
    private var configuration = Prop.defaultConfiguration
    private var state = State.notInitialized
    private weak var instance: XCTestCase?
    
    public init() {}
    
    public var wrappedValue: Prop {
        guard let instance = self.instance else {
            preconditionFailure("Wrapped property called when we do not have an instance")
        }
        switch state {
        case .notInitialized:
            do {
                Prop.prepare(instance)
                let value = try Prop(configuration: configuration)
                state = .initialized(value)
                instance.addTeardownBlock {
                    self.state = .notInitialized
                }
                return value
            } catch {
                preconditionFailure("Failed to create prop: \(error)")
            }
        case .initialized(let value):
            return value
        }
    }
    
    public var projectedValue: Prop.Configuration {
        get {
            configuration
        }
        set {
            switch state {
            case .notInitialized:
                configuration = newValue
            case .initialized:
                preconditionFailure("Mutating configuration after prop is initialized is not suppored")
            }
        }
    }
    
    public func reset() {
        configuration = Prop.defaultConfiguration
        state = .notInitialized
    }
    
    public static subscript<Instance: XCTestCase, Prop: TestProp>(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: KeyPath<Instance, Prop>,
        storage storageKeyPath: KeyPath<Instance, Propped<Prop>>
    ) -> Prop? {
        instance[keyPath: storageKeyPath].instance = instance
        return instance[keyPath: storageKeyPath].wrappedValue
    }
    
}
