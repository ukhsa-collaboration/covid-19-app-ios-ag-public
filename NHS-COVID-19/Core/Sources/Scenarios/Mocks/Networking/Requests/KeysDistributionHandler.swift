//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct KeysDistributionHandler: RequestHandler {
    enum Variant {
        case withBinAndSigFile
    }
    
    var paths = ["/distribution/daily/", "/distribution/two-hourly/"]
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        return Self.response()
    }
    
    static func response(variant: Variant = .withBinAndSigFile) -> Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: zip(variant: variant))
        return Result.success(response)
    }
    
    private static func zip(variant: Variant) -> Data {
        switch variant {
        case .withBinAndSigFile:
            return Data(base64Encoded: "UEsDBBQACAAIAAAAAAAAAAAAAAAAAAAAAAAKAAAAZXhwb3J0LmJpbnL1VnCtKMgvKlEoM1RQUFDg/PDieBwDAwODYIHVSTBDiik0WIFRg9FIUYrRUIm9OD83NT4zRUvYUM9Iz8LEQM/QwMDEVM9Ez1jPyEqaS0Bc/0jD0xmePCbiZSzGs0WdBTgk/txbyKjACJLUTma1OtKs3PuwTGxem7ztWQFGiS6QZBEgAAD//1BLBwhQGAPXhwAAAIcAAABQSwMEFAAIAAgAAAAAAAAAAAAAAAAAAAAAAAoAAABleHBvcnQuc2ln4irkUpRiNFRiL87PTY3PTNESNtQz0rMwMdAzNDAwMdUz0TPWMxJglGBU8jBwY1JkmLft5dW1WRn9Kws2PKvhaDOJe39XQjJS725LgpfMeV8mdyZFhgm59Wc/CR4X+OGlVSnOwFq878N79SXTHTXvaZStyZD8lgUIAAD//1BLBwhEY4HtfAAAAHMAAABQSwECFAAUAAgACAAAAAAAUBgD14cAAACHAAAACgAAAAAAAAAAAAAAAAAAAAAAZXhwb3J0LmJpblBLAQIUABQACAAIAAAAAABEY4HtfAAAAHMAAAAKAAAAAAAAAAAAAAAAAL8AAABleHBvcnQuc2lnUEsFBgAAAAACAAIAcAAAAHMBAAAAAA=="
            )!
        }
    }
}
