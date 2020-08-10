//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CachedResponseTests: XCTestCase {
    
    struct Instance: TestProp {
        
        struct Configuration: TestPropConfiguration {
            var httpClient = MockHTTPClient()
            fileprivate var endpoint = TestEndpoint()
            var storage: FileStorage
            var stored: FileStored<Data>
            var name = String.random()
            var initialValue = HTTPResponse.ok(with: .untyped(.random()))
            
            public init() {
                let fileManager = FileManager()
                let documentFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let folder = try! fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: documentFolder, create: true)
                storage = FileStorage(directory: folder)
                stored = FileStored(storage: storage, name: name)
                stored.wrappedValue = nil
            }
        }
        
        var cached: CachedResponse<HTTPResponse>
        
        init(configuration: Configuration) {
            cached = CachedResponse(
                httpClient: configuration.httpClient,
                endpoint: configuration.endpoint,
                storage: configuration.storage,
                name: configuration.name,
                initialValue: configuration.initialValue
            )
        }
    }
    
    @Propped
    private var instance: Instance
    
    private var cached: CachedResponse<HTTPResponse> {
        instance.cached
    }
    
    func testGettingInitialValue() {
        TS.assert(cached.value, equals: $instance.initialValue)
        XCTAssertNil($instance.stored.wrappedValue)
    }
    
    func testTheStoredValueIsLoadedImmediately() {
        let storedValue = HTTPResponse.ok(with: .untyped(.random()))
        $instance.stored.wrappedValue = storedValue.body.content
        TS.assert(cached.value, equals: storedValue)
    }
    
    func testUpdating() throws {
        let response = HTTPResponse.ok(with: .untyped(.random()))
        $instance.httpClient.response = .success(response)
        _ = try cached.update().await()
        
        TS.assert($instance.httpClient.lastRequest, equals: $instance.endpoint._request)
        TS.assert(cached.value, equals: response)
        TS.assert($instance.stored.wrappedValue, equals: response.body.content)
    }
    
}

private struct TestEndpoint: HTTPEndpoint {
    var _request = HTTPRequest.get("/\(String.random())")
    
    func request(for input: Void) throws -> HTTPRequest {
        _request
    }
    
    func parse(_ response: HTTPResponse) throws -> HTTPResponse {
        response
    }
    
}
