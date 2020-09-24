//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

extension Publisher {
    
    func ensureFinishes(placeholder output: Self.Output) -> Publishers.ReplaceError<Publishers.Concatenate<Publishers.Sequence<[Self.Output], Self.Failure>, Self>> {
        // Workaround for possible OS issue (last tested on iOS 14.0):
        //
        // There seem to be a situations where an empty publisher finishes in a way that its downstreams do not receive
        // a `finished` event – Possible a bug in `Publishers.Sequence`?
        //
        // However, we rely on these publishers to finish correctly even if the value doesn’t exist – specifically,
        // we may be relying on the finished event as a signal to end background tasks.
        //
        // * The prepend seems to be solving this issue.
        // * The replaceError is added here as we usually do these together _and_ it’s important to put prepend before
        //   `replaceError`.
        prepend(output)
            .replaceError(with: output)
    }
    
}
