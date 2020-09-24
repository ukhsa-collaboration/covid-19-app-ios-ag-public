//
// Copyright © 2020 NHSX. All rights reserved.
//

protocol VoidTestResultFlowInteracting {
    var acknowledge: () -> Void { get }
}

struct VoidTestResultFlowInteractor: VoidTestResultFlowInteracting {
    var acknowledge: () -> Void
}
