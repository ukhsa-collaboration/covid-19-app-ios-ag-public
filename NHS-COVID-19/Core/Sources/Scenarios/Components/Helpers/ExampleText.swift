//
// Copyright © 2020 NHSX. All rights reserved.
//

enum ExampleText: String, CaseIterable {
    case veryShort = "Short"
    case short = "Relatively short text"
    case normal = "Text that is starting to get a bit long."
    case long = """
    This one is longer still, and it probably doesn’t fit on one line, and really, why should it \
    fit on one line, when I’m trying hard to make it not fit.
    """
}
