//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import SwiftUI
import XCTest
@testable import Interface

class HomeAnimationsViewModelTests: XCTestCase {
    
    private var subscriptions = Set<AnyCancellable>()
    
    func testHomeAnimationsViewModelInitWithStoredValueSetToFalseAndReduceMotionEnabled() {
        
        var valueToBeStored = false
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: Just(true).eraseToAnyPublisher()
        )
        
        // Toggle state should be off
        XCTAssertFalse(vm.toggleState)
        
        // Reduce motion should be enabled
        XCTAssertTrue(vm.isReducedMotionEnabled)
        
        // Value to be sent to store should not change
        XCTAssertFalse(valueToBeStored)
    }
    
    func testHomeAnimationsViewModelInitWithStoredValueSetToFalseAndReduceMotionDisabled() {
        
        var valueToBeStored = false
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: Just(false).eraseToAnyPublisher()
        )
        
        // Toggle state should be off
        XCTAssertFalse(vm.toggleState)
        
        // Reduce motion should be disabled
        XCTAssertFalse(vm.isReducedMotionEnabled)
        
        // Value to be sent to store should not change
        XCTAssertFalse(valueToBeStored)
    }
    
    func testHomeAnimationsViewModelInitWithStoredValueSetToTrueAndReduceMotionEnabled() {
        
        var valueStored = true
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueStored),
            homeAnimationEnabledAction: { enabled in
                valueStored = enabled
            },
            reduceMotionPublisher: Just(true).eraseToAnyPublisher()
        )
        
        // Toggle state should be off
        XCTAssertFalse(vm.toggleState)
        
        // Value to be saved should not change
        XCTAssertTrue(valueStored)
        
        // Reduce motion should be enabled
        XCTAssertTrue(vm.isReducedMotionEnabled)
    }
    
    func testTogglingWhenReduceMotionIsEnabled() {
        var valueToBeStored = true
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: Just(true).eraseToAnyPublisher()
        )
        
        // Initial toggle state should be false
        XCTAssertFalse(vm.toggleState)
        
        // Reduce motion should be enabled
        XCTAssertTrue(vm.isReducedMotionEnabled)
        
        // Toggling the switch
        vm.toggleState.toggle()
        
        // reduce motion should still be enabled
        vm.$isReducedMotionEnabled.sink {
            XCTAssertTrue($0)
        }.store(in: &subscriptions)
        
        #warning("Figure out a way to test this")
        // Even though the toggle state will be changed in this particular case,
        // in practice it's not possible since toggle is disabled if reduce motion is on
        
        // Store should not be updated
        XCTAssertTrue(valueToBeStored)
    }
    
    /// Given that store value is true and reduceMotion is false, when toggling the switch, value to be saved in the store should be changed
    /// and isReducedMotionEnabled be false
    func testTogglingWhenReduceMotionIsDisabled() {
        var valueToBeStored = true
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: Just(false).eraseToAnyPublisher()
        )
        
        // Initial toggle state should be true
        XCTAssertTrue(vm.toggleState)
        
        // Reduce motion should be disabled
        XCTAssertFalse(vm.isReducedMotionEnabled)
        
        // Toggling the switch
        
        vm.toggleState.toggle()
        
        // reduce motion should still be disabled
        vm.$isReducedMotionEnabled.sink {
            XCTAssertFalse($0)
        }.store(in: &subscriptions)
        
        // Toggle state should change
        XCTAssertFalse(vm.toggleState)
        
        // Store should be updated
        XCTAssertFalse(valueToBeStored)
    }
    
    func testEnablingReduceMotion() {
        var valueToBeStored = true
        
        let reduceMotionSubject = PassthroughSubject<Bool, Never>()
        let reduceMotionPublisher = reduceMotionSubject.prepend(false).eraseToAnyPublisher()
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: reduceMotionPublisher
        )
        
        // Initial toggle state should be true
        XCTAssertTrue(vm.toggleState)
        
        // Reduce motion should be disabled
        XCTAssertFalse(vm.isReducedMotionEnabled)
        
        // Enabling reduce Motion
        reduceMotionSubject.send(true)
        vm.$isReducedMotionEnabled.sink {
            XCTAssertTrue($0)
        }.store(in: &subscriptions)
        
        // Toggle state should be false
        vm.$toggleState.sink(receiveValue: {
            XCTAssertFalse($0)
        }).store(in: &subscriptions)
        
        // Store should not be updated
        XCTAssertTrue(valueToBeStored)
    }
    
    func testEnablingThenDisablingReduceMotion() {
        var valueToBeStored = true
        
        let reduceMotionSubject = PassthroughSubject<Bool, Never>()
        let reduceMotionPublisher = reduceMotionSubject.prepend(false).eraseToAnyPublisher()
        
        let vm = HomeAnimationsViewModel(
            homeAnimationEnabled: InterfaceProperty.constant(valueToBeStored),
            homeAnimationEnabledAction: { enabled in
                valueToBeStored = enabled
            },
            reduceMotionPublisher: reduceMotionPublisher
        )
        
        // Initial toggle state should be true
        XCTAssertTrue(vm.toggleState)
        
        // Reduce motion should be disabled
        XCTAssertFalse(vm.isReducedMotionEnabled)
        
        // Enabling reduce motion
        reduceMotionSubject.send(true)
        vm.$isReducedMotionEnabled
            .first()
            .sink {
                XCTAssertTrue($0)
            }.store(in: &subscriptions)
        
        // Toggle state should be false
        vm.$toggleState
            .first()
            .sink(receiveValue: {
                XCTAssertFalse($0)
            }).store(in: &subscriptions)
        
        // Store should not be updated
        XCTAssertTrue(valueToBeStored)
        
        // Disable reduce motion
        reduceMotionSubject.send(false)
        vm.$isReducedMotionEnabled
            .last()
            .sink {
                XCTAssertFalse($0)
            }.store(in: &subscriptions)
        
        // Toggle state should be true
        vm.$toggleState
            .last()
            .sink(receiveValue: {
                XCTAssertTrue($0)
            }).store(in: &subscriptions)
        
        // Value to be stored hasn't changed
        XCTAssertTrue(valueToBeStored)
    }
    
}
