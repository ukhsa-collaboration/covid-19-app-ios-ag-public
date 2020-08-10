//
// Copyright © 2020 NHSX. All rights reserved.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

public enum Comparison<Diff> {
    case equal
    case notEqual(_ diff: Diff)
    
    public func map<NewDiff>(_ transform: (Diff) throws -> NewDiff) rethrows -> Comparison<NewDiff> {
        switch self {
        case .notEqual(let diff):
            return .notEqual(try transform(diff))
        case .equal:
            return .equal
        }
    }
}

extension CIImage {
    public static func diff(_ imageA: CIImage?, with imageB: CIImage?) -> CIImage? {
        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.backgroundImage = imageA
        diffFilter.inputImage = imageB
        return diffFilter.outputImage
    }
    
    private struct ComparisonError: Error {
        let reason: String
    }
    
    public static func compare(_ imageA: CIImage?, with imageB: CIImage?) throws -> Comparison<CIImage> {
        guard let diff = diff(imageA, with: imageB) else {
            throw ComparisonError(reason: "Unable to diff images")
        }
        
        let maxComponentFilter = CIFilter(name: "CIAreaMaximum")
        maxComponentFilter?.setValue(diff, forKey: kCIInputImageKey)
        maxComponentFilter?.setValue(diff.extent, forKey: kCIInputExtentKey)
        
        guard let output = maxComponentFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            throw ComparisonError(reason: "Unabe to determine maximum component")
        }
        
        let colorInfoError = ComparisonError(reason: "Unable to extract color information from maximum component")
        guard let cgImage = CIContext().createCGImage(output, from: output.extent) else { throw colorInfoError }
        guard let pixelData = cgImage.dataProvider?.data as Data? else { throw colorInfoError }
        
        // Ensure alpha is ignored
        return pixelData[0 ..< 3].reduce(0, max) == 0 ? .equal : .notEqual(diff)
    }
}

public extension Optional where Wrapped == UIImage {
    func createCIImage() -> CIImage? {
        map { CIImage(image: $0) } ?? nil
    }
}
