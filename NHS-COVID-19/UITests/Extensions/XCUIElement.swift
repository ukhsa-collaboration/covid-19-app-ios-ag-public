//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

extension XCUIElement {
    
    var hasKeyboardFocus: Bool {
        value(forKey: "hasKeyboardFocus") as! Bool
    }
    
    var loosingFocus: XCTestExpectation {
        let lostFocus = NSPredicate(format: "hasKeyboardFocus == false")
        return XCTNSPredicateExpectation(predicate: lostFocus, object: self)
    }
    
    func waitForDisappearance(timeout: TimeInterval = 0.5, file: StaticString = #file, line: UInt = #line) {
        let deadline = CACurrentMediaTime() + timeout
        while CACurrentMediaTime() < deadline, exists {
            usleep(100)
        }
        if exists {
            _ = try? snapshot()
        }
        XCTAssert(!exists, file: file, line: line)
    }
    
    // Note: Exists doesn't guarantee that the element is visible in the viewport.
    var displayed: Bool {
        guard exists, !frame.isEmpty else { return false }
        return exists && XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
    
    func scrollTo(element: XCUIElement) {
        var counter = 0
        while !element.displayed, counter < 10 {
            swipeUp()
            usleep(200_000) // wait for 200ms to finish scrolling animation
            counter += 1
        }
    }
    
    func scrollToHittable(element: XCUIElement) {
        var counter = 0
        while !element.isHittable, counter < 10 {
            swipeUp()
            usleep(200_000) // wait for 200ms to finish scrolling animation
            counter += 1
        }
    }
}
