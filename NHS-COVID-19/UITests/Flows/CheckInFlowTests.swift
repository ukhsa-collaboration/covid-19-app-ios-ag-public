//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class CheckInFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.cameraAuthorized = false
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
        $runner.initialState.qrCodeScanTime = 0.5
    }
    
    func testHappyPath() throws {
        $runner.report(scenario: "Venue check-in", "Happy path") {
            """
            Users can check into venues by scanning a qr-code
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            XCTAssert(homeScreen.checkInButton.exists)
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Venue check-in'
                """
            }
            
            homeScreen.checkInButton.tap()
            
            let simulatedCameraAuthorizationScreen = SimulatedCameraAuthorizationScreen(app: app)
            runner.step("Permissions - Camera") {
                """
                The user is asked for permission to enable the camera
                The user allows.
                """
            }
            
            simulatedCameraAuthorizationScreen.allowButton.tap()
            
            runner.step("QR Scanner") {
                """
                The user is presented the qr scanner screen
                """
            }
            
            usleep(500_00)
            
            runner.step("Scan code to check-in") {
                """
                The user scans a QR Code to check into a venue
                """
            }
            
            let checkInConfirmationScreen = CheckInConfirmationScreen(app: app)
            
            checkInConfirmationScreen.homeButton.tap()
            
            runner.step("Successful check-in - Back to home") {
                """
                The user can tap on 'Back to home'
                """
            }
        }
    }
    
    func testInfoScreen() throws {
        $runner.initialState.shouldScanQRCode = false
        $runner.initialState.cameraAuthorized = true
        
        $runner.report(scenario: "Venue check-in", "Show More info") {
            """
            Users scans an invalid qr-code
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            XCTAssert(homeScreen.checkInButton.exists)
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Venue check-in'
                """
            }
            
            homeScreen.checkInButton.tap()
            
            let qrscannerScreen = QRCodeScannerScreen(app: app)
            
            qrscannerScreen.helpButton.tap()
            
            runner.step("More info about venue check-in") {
                """
                The user can tap on 'More info about venue check-in'
                """
            }
            
            let checkInInformationScreen = VenueCheckInInformationScreen(app: app)
            checkInInformationScreen.cancelButton.tap()
        }
        
    }
    
    func testInvalidQRCode() throws {
        $runner.initialState.scannedQRCode = "INVALID"
        
        $runner.report(scenario: "Venue check-in", "Invalid QRCode") {
            """
            Users scans an invalid qr-code
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            XCTAssert(homeScreen.checkInButton.exists)
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Venue check-in'
                """
            }
            
            homeScreen.checkInButton.tap()
            
            let simulatedCameraAuthorizationScreen = SimulatedCameraAuthorizationScreen(app: app)
            runner.step("Permissions - Camera") {
                """
                The user is asked for permission to enable the camera
                The user allows.
                """
            }
            
            simulatedCameraAuthorizationScreen.allowButton.tap()
            
            usleep(500_000)
            
            runner.step("QR Scanner") {
                """
                The user is presented the qr scanner screen.
                The user scans an invalid QR Code to check into a venue
                """
            }
            
            let scanningFailureScreen = ScanningFailureScreen(app: app)
            
            scanningFailureScreen.backToHomeButton.tap()
            
            runner.step("Scanning Failure") {
                """
                The user is presented a scanning failure screen.
                The user can tap on 'Back to home'
                """
            }
        }
    }
    
    func testDenyCameraAccess() throws {
        $runner.report(scenario: "Venue check-in", "Deny Camera Access") {
            """
            Users denies camera access for venue check-in
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            XCTAssert(homeScreen.checkInButton.exists)
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Venue check-in'
                """
            }
            
            homeScreen.checkInButton.tap()
            
            let simulatedCameraAuthorizationScreen = SimulatedCameraAuthorizationScreen(app: app)
            runner.step("Permissions - Camera") {
                """
                The user is asked for permission to enable the camera
                The user does not allow.
                """
            }
            
            simulatedCameraAuthorizationScreen.dontAllowButton.tap()
            
            let cameraAccessDenied = CameraAccessDeniedScreen(app: app)
            
            cameraAccessDenied.openSettingsButton.tap()
            
            runner.step("Camera Access Denied Screen") {
                """
                The user is presented the camera access denied screen
                """
            }
            
        }
    }
    
    func testCameraUnavailable() throws {
        $runner.initialState.cameraUnavailable = true
        
        $runner.report(scenario: "Venue check-in", "Unsupported Phone") {
            """
            The camera is not available to load or start
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            XCTAssert(homeScreen.checkInButton.exists)
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Venue check-in'
                """
            }
            
            homeScreen.checkInButton.tap()
            
            let simulatedCameraAuthorizationScreen = SimulatedCameraAuthorizationScreen(app: app)
            runner.step("Permissions - Camera") {
                """
                The user is asked for permission to enable the camera
                The user does not allow.
                """
            }
            
            simulatedCameraAuthorizationScreen.allowButton.tap()
            
            runner.step("Unsupported phone for venue check-in") {
                """
                The user is presented an error screen that tells him his phone is not supported for venue check-in
                """
            }
            
            let cameraFailureScreen = CameraFailureScreen(app: app)
            
            cameraFailureScreen.backToHomeButton.tap()
            
        }
    }
}
