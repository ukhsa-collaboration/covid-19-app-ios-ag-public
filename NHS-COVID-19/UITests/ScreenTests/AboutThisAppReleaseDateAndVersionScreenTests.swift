//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

// this test purely exists to generate a screen shot of the About screen with the release date and verison number visible
class AboutThisAppReleaseDateAndVersionScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<AboutThisAppReleaseDateAndVersionScenario>
    
    func testCaptureReleaseDateAndVersion() throws {
        $runner.report(scenario: "About this app", "Release date and version number") {
            """
            Show version number of the app.
            """
        }
        
        let configuration = Set(arrayLiteral: DeviceConfiguration(language: "en", orientation: .portrait, contentSize: .medium, interfaceStyle: .light))
        try runner.run(deviceConfigurations: configuration, work: { app in
            let screen = AboutThisAppScreen(app: app)
            app.scrollTo(element: screen.dateOfRelease)
            
            runner.step("Display release date and version number")
        })
    }
}
