//
// Copyright © 2020 NHSX. All rights reserved.
//

enum EpidemiologicalEventType {
    case exposureWindow
    case exposureWindowPositiveTest(testKitType: TestKitType?, requiresConfirmatoryTest: Bool)
}
