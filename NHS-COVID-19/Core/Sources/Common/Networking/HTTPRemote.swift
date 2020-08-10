//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct HTTPRemote {
    
    public struct HeadersMergePolicy {
        
        var merge: (_ remoteHeaders: HTTPHeaders, _ requestHeaders: HTTPHeaders) throws -> HTTPHeaders
        
    }
    
    public struct QueryParametersMergePolicy {
        
        var merge: (_ remoteHeaders: [String: String], _ requestHeaders: [String: String]) throws -> [String: String]
        
    }
    
    public let host: String
    public let path: String
    public let port: Int?
    public let user: String?
    public let password: String?
    public let queryParameters: [String: String]
    public let headers: HTTPHeaders
    
    /// Determines how headers from an `HTTPRequest` must be processed when creating a `URLRequest`.
    ///
    /// Defaults to `.disallowOverrides`.
    public var headersMergePolicy = HeadersMergePolicy.disallowOverrides
    
    /// Determines how query paramteres from an `HTTPRequest` must be processed when creating a `URLRequest`.
    ///
    /// Defaults to `.disallowOverridesCaseInsensitive`.
    public var queryParametersMergePolicy = QueryParametersMergePolicy.disallowOverridesCaseInsensitive
    
    public init(
        host: String,
        path: String,
        port: Int? = nil,
        user: String? = nil,
        password: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        
        guard path.isEmpty || path.starts(with: "/") else {
            Thread.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        for disallowedHeader in HTTPHeaderFieldName.bodyHeaders {
            guard !headers.hasValue(for: disallowedHeader) else {
                Thread.fatalError("\(disallowedHeader.lowercaseName) header must not be set on a remote. Provide this value for each request.")
            }
        }
        
        self.host = host
        self.path = path
        self.port = port
        self.user = user
        self.password = password
        self.queryParameters = queryParameters
        self.headers = headers
    }
    
}

extension HTTPRemote: URLRequestProviding {
    
    public func urlRequest(from request: HTTPRequest) throws -> URLRequest {
        let queryParameters = try queryParametersMergePolicy.merge(self.queryParameters, request.queryParameters)
        let headers = try headersMergePolicy.merge(self.headers, request.headers)
        
        let url = mutating(URLComponents()) {
            $0.scheme = "https"
            $0.host = host
            $0.path = "\(path)\(request.path)"
            $0.fragment = request.fragment
            $0.port = port
            $0.user = user
            $0.password = password
            if !queryParameters.isEmpty {
                $0.queryItems = queryParameters
                    .map { URLQueryItem(name: $0.key, value: $0.value) }
            }
        }.url!
        
        return mutating(URLRequest(url: url)) { urlRequest in
            headers.fields.forEach {
                urlRequest.addValue($0.value, forHTTPHeaderField: $0.key.lowercaseName)
            }
            
            urlRequest.httpMethod = request.method.rawValue
            if let body = request.body {
                urlRequest.httpBody = body.content
                urlRequest.addValue(body.type, forHTTPHeaderField: HTTPHeaderFieldName.contentType.lowercaseName)
                urlRequest.addValue("\(body.content.count)", forHTTPHeaderField: HTTPHeaderFieldName.contentLength.lowercaseName)
            }
        }
    }
    
}

extension HTTPRemote.HeadersMergePolicy {
    
    private enum Errors: Error {
        case requestOverridesHeaders(Set<HTTPHeaderFieldName>)
    }
    
    /// A header policy that throws an error if a request tries to set headers already present in the remote.
    public static let disallowOverrides: HTTPRemote.HeadersMergePolicy = HTTPRemote.HeadersMergePolicy { remoteHeaders, requestHeaders -> HTTPHeaders in
        let overriddenHeaders = Set(remoteHeaders.fields.keys)
            .intersection(requestHeaders.fields.keys)
        guard overriddenHeaders.isEmpty else {
            throw Errors.requestOverridesHeaders(overriddenHeaders)
        }
        
        return mutating(remoteHeaders) { remoteHeaders in
            requestHeaders.fields.forEach {
                remoteHeaders.fields[$0.key] = $0.value
            }
        }
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    public static func custom(merge: @escaping (_ remoteHeaders: HTTPHeaders, _ requestHeaders: HTTPHeaders) throws -> HTTPHeaders) -> HTTPRemote.HeadersMergePolicy {
        HTTPRemote.HeadersMergePolicy(merge: merge)
    }
    
}

extension HTTPRemote.QueryParametersMergePolicy {
    
    private enum Errors: Error {
        case requestOverridesQueryParameters(Set<String>)
    }
    
    /// A policy that throws an error if a request tries to set a quert parameter already present in the remote, even if they have different cases.
    public static let disallowOverridesCaseInsensitive: HTTPRemote.QueryParametersMergePolicy = HTTPRemote.QueryParametersMergePolicy { remoteParameters, requestParameters in
        let overriddenParameters = Set(remoteParameters.keys.map { $0.lowercased() })
            .intersection(requestParameters.keys.map { $0.lowercased() })
        guard overriddenParameters.isEmpty else {
            throw Errors.requestOverridesQueryParameters(overriddenParameters)
        }
        
        return Dictionary(uniqueKeysWithValues: [remoteParameters, requestParameters].lazy.flatMap { $0 }.map { $0 })
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    public static func custom(merge: @escaping (_ remoteHeaders: [String: String], _ requestHeaders: [String: String]) throws -> [String: String]) -> HTTPRemote.QueryParametersMergePolicy {
        HTTPRemote.QueryParametersMergePolicy(merge: merge)
    }
    
}
