//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

@available(iOS 13, *)
struct CombinedDifference<Element: Equatable>: Equatable {
    enum Change: Equatable {
        case none
        case added
        case removed
    }
    
    var element: Element
    var change: Change
}

@available(iOS 13, *)
extension BidirectionalCollection where Element: Equatable {
    /// Returns an array of all elements from receiver and another collection, along with how they have changed from one to another.
    func combinedDifference<C>(from other: C) -> [CombinedDifference<Element>] where C: BidirectionalCollection, C.Element == Self.Element {
        let difference = self.difference(from: other)
        
        var lines = other.map { CombinedDifference(element: $0, change: .none) }
        
        var indexes = (0 ..< lines.count).map { $0 }
        difference.removals.reversed().forEach {
            indexes.remove(at: $0.offset)
            lines[$0.offset].change = .removed
        }
        
        difference.insertions.forEach { change in
            let indexToInsert = (change.offset < indexes.count) ? indexes[change.offset] : lines.count
            lines.insert(CombinedDifference(element: change.element, change: .added), at: indexToInsert)
            for i in 0 ..< indexes.count {
                if indexes[i] >= indexToInsert {
                    indexes[i] += 1
                }
            }
            indexes.insert(indexToInsert, at: change.offset)
        }
        return lines
    }
}

@available(iOS 13, *)
private extension CollectionDifference.Change {
    var offset: Int {
        switch self {
        case .insert(let offset, _, _), .remove(let offset, _, _):
            return offset
        }
    }
    
    var element: ChangeElement {
        switch self {
        case .insert(_, let element, _), .remove(_, let element, _):
            return element
        }
    }
    
}
