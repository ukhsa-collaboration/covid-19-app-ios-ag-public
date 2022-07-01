//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

extension XCUIElement {

    #warning("Must have a scroll view")
    public func fullScreenshot() -> UIImage? {

        guard descendants(matching: .scrollView).count > 0 else { return nil }

        #warning("Handle landscape screenshots")
        guard frame.size.height > frame.size.width else { return nil }

        let scrollView = descendants(matching: .scrollView).firstMatch // this will fail the test
        let scrollViewContentView = scrollView.children(matching: .other).firstMatch

        let numberOfPages = Int(ceil(scrollViewContentView.frame.size.height / scrollView.frame.size.height))
        guard numberOfPages > 1 else { return screenshot().image }

        let topPadding = scrollView.frame.origin.y // header
        let contentOffset = Int(scrollView.frame.size.height + topPadding - scrollViewContentView.frame.size.height)

        var currentContentOffset: Int { Int(scrollViewContentView.frame.origin.y) }

        var images: [UIImage] = []

        let paddingCalculator = ScreenshotOffsetCalculator(
            scrollableViewHeight: scrollView.frame.size.height,
            scrollableContentViewHeight: scrollViewContentView.frame.size.height,
            topPadding: topPadding,
            bottomPadding: frame.height - topPadding - scrollView.frame.size.height
        )

        // if scroll view is currently scrolled (dynamic views), scroll all the way to top.
        if currentContentOffset != Int(scrollView.frame.minY) {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02)).tap()
            usleep(1500000)
        }

        var previousOffset = currentContentOffset
        while currentContentOffset > contentOffset {

            let paddings = paddingCalculator.calculateScreenshotPaddings(
                currentOffset: scrollViewContentView.frame.origin.y
            )

            if let screenshot = takeScreenshot(of: self, paddings: paddings) {
                images.append(screenshot)
            }

            scrollView.scroll()

            // In case scroll view content is clipped, it will never reach max scroll content height
            // but it will be scrolled 100%
            if currentContentOffset == previousOffset {
                break
            } else {
                previousOffset = currentContentOffset
            }
        }

        // take last image
        let paddings = paddingCalculator.calculateScreenshotPaddings(
            currentOffset: scrollViewContentView.frame.origin.y,
            isLastImage: true
        )

        if let screenshot = takeScreenshot(of: self, paddings: paddings) {
            images.append(screenshot)
        }

        return UIImage.combineTopToBottom(imagesArray: images)
    }

    private func takeScreenshot(of screen: XCUIElement, paddings: ScreenshotPaddings) -> UIImage? {
        let fullImage = screen.screenshot().image
        return fullImage.crop(top: CGFloat(paddings.top), bottom: CGFloat(paddings.bottom))
    }

    func scroll() {
        // swipeUp()
        gentleSwipe(.up)
    }
}

extension XCUIElement {
    enum direction: Int {
        case up, down, left, right
    }

    func gentleSwipe(_ direction: direction) {
        let half: CGFloat = 0.5
        let adjustment: CGFloat = 0.25
        let pressDuration: TimeInterval = 0.05

        let lessThanHalf = half - adjustment
        let moreThanHalf = half + adjustment

        let centre = coordinate(withNormalizedOffset: CGVector(dx: half, dy: half))
        let aboveCentre = coordinate(withNormalizedOffset: CGVector(dx: half, dy: lessThanHalf))
        let belowCentre = coordinate(withNormalizedOffset: CGVector(dx: half, dy: moreThanHalf))
        let leftOfCentre = coordinate(withNormalizedOffset: CGVector(dx: lessThanHalf, dy: half))
        let rightOfCentre = coordinate(withNormalizedOffset: CGVector(dx: moreThanHalf, dy: half))

        switch direction {
        case .up:
            centre.press(forDuration: pressDuration, thenDragTo: aboveCentre)
        case .down:
            centre.press(forDuration: pressDuration, thenDragTo: belowCentre)
        case .left:
            centre.press(forDuration: pressDuration, thenDragTo: leftOfCentre)
        case .right:
            centre.press(forDuration: pressDuration, thenDragTo: rightOfCentre)
        }
    }
}

extension UIImage {
    // Maybe use builder pattern? E.g. image.appendVertically(image1).appendVertically(image2)
    static func combineTopToBottom(imagesArray: [UIImage]) -> UIImage? {
        guard !imagesArray.isEmpty else { return nil }
        let totalHeight = imagesArray.reduce(CGFloat(0)) { result, image in
            result + image.size.height
        }
        let dimensions = CGSize(width: imagesArray.first!.size.width, height: totalHeight)

        UIGraphicsBeginImageContext(dimensions)

        var lastY = CGFloat(0.0)
        for image in imagesArray {
            image.draw(in: CGRect(x: 0, y: lastY, width: dimensions.width, height: image.size.height))
            lastY += image.size.height
        }

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }

    func crop(top: CGFloat, bottom: CGFloat) -> UIImage? {

        guard let cgImage = cgImage else {
            return nil
        }

        let topOffset = Int(top * scale)
        let bottomOffset = Int(bottom * scale)

        let rect = CGRect(
            x: 0,
            y: topOffset,
            width: cgImage.width,
            height: cgImage.height - topOffset - bottomOffset
        )

        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
        }

        return nil
    }
}

struct ScreenshotPaddings: Equatable {
    let top: Int
    let bottom: Int
}

class ScreenshotOffsetCalculator {
    private let scrollableViewHeight: CGFloat
    private let maximumContentOffset: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    private var previousOffset: CGFloat

    init(
        scrollableViewHeight: CGFloat,
        scrollableContentViewHeight: CGFloat,
        topPadding: CGFloat,
        bottomPadding: CGFloat
    ) {
        self.scrollableViewHeight = scrollableViewHeight
        // must be <= topPadding
        maximumContentOffset = scrollableViewHeight + topPadding - scrollableContentViewHeight
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        previousOffset = topPadding
    }

    func calculateScreenshotPaddings(currentOffset: CGFloat, isLastImage: Bool? = nil) -> ScreenshotPaddings {
        // guard previous - currentOffset <= scrollableViewHeight
        defer { previousOffset = currentOffset }
        let isFirstImage = currentOffset >= topPadding
        let isLastImage = isLastImage != nil ? true : Int(currentOffset) == Int(maximumContentOffset)

        // Covers the case when scroll view is behind the iPhone dock — not constrained to safe layout area
        var bottomPadding: Int {
            self.bottomPadding == 0 ? 34 : Int(self.bottomPadding)
        }

        var minY = isFirstImage ? 0 : Int(round(scrollableViewHeight + topPadding - abs(previousOffset - currentOffset)))
        let maxY = isLastImage ? 0 : bottomPadding

        if self.bottomPadding == 0 {
            minY -= 34
        }

        return ScreenshotPaddings(top: minY, bottom: maxY)
    }
}
