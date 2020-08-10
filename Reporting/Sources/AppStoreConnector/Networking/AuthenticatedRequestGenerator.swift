//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

final class AuthenticatedRequestGenerator: RequestGenerator {
    
    private let baseURLComponents: URLComponents
    private let makeBearerToken: () -> String
    
    init(host: String, path: String, makeBearerToken: @escaping () -> String) {
        self.makeBearerToken = makeBearerToken
        
        baseURLComponents = mutating(URLComponents()) {
            $0.scheme = "https"
            $0.host = host
            $0.path = path
        }
    }
    
    func request(for path: String) -> URLRequest {
        let urlComponents = mutating(baseURLComponents) {
            $0.path += path
        }
        
        let token = makeBearerToken()
        return mutating(URLRequest(url: urlComponents.url!)) {
            $0.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
}
