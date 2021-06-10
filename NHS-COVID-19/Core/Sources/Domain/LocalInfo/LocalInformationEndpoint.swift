//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LocalInformationEndpoint: HTTPEndpoint {
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/local-messages")
    }
    
    func parse(_ response: HTTPResponse) throws -> LocalInformation {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking
        return try decoder.decode(LocalInformation.self, from: response.body.content)
    }
}

extension LocalInformation {
    
    public struct MessageBlock: Decodable {
        
        // type is the only mandatory field
        public enum BlockType: String, Decodable {
            case para
        }
        
        public let type: String
        
        // these are the optional fields we know about, more will get added here with
        // additional content blocks at which point we may want to add optional decoding
        // based on the type field
        public let text: String?
        let link: String?
        let linkText: String?
        
        public var url: (url: URL, title: String)? {
            if let link = link,
                let url = URL(string: link),
                let title = linkText,
                !title.isEmpty {
                return (url: url, title: title)
            }
            return nil
        }
    }
    
    public struct MessageContent: Decodable {
        public let head: String?
        public let body: String?
        let content: [MessageBlock]?
        
        func blocks(of type: MessageBlock.BlockType = .para) -> [MessageBlock]? {
            content?.filter {
                MessageBlock.BlockType(rawValue: $0.type) == type
            }
        }
        
        // return all blocks of type .para *or* have a non-nil text or link
        public func renderable() -> [MessageBlock]? {
            content?.filter {
                MessageBlock.BlockType(rawValue: $0.type) == .para || $0.text != nil || $0.url != nil
            }
        }
    }
    
    public struct MessageContentContainer: Decodable {
        enum ContentType: String, Decodable {
            case notification
        }
        
        let type: String
        let updated: Date
        let contentVersion: Int
        let translations: [String: MessageContent] // language id to content block(s)
        
        var isNotification: Bool {
            ContentType(rawValue: type) == .notification
        }
        
        public func translations(for language: String?) -> MessageContent? {
            let code = language ?? "en"
            return translations[code] ?? translations["en"]
        }
    }
}

public struct LocalInformation: Decodable {
    typealias LocalAuthorityIdValue = String
    let las: [LocalAuthorityIdValue: [String]] // map LA to message ids
    let messages: [String: MessageContentContainer] // map message id to message content
    
    private func first(for localAuthority: String) -> (message: MessageContentContainer, id: String)? {
        let firstNotification = las[localAuthority]?.compactMap { messageId -> (MessageContentContainer, String)? in
            if let message = messages[messageId], message.isNotification {
                return (message, messageId)
            }
            return nil
        }.first
        return firstNotification
    }
    
    func message(for localAuthority: LocalAuthorityId) -> (message: MessageContentContainer, id: String)? {
        
        let firstNotification = first(for: localAuthority.value)
        if let firstNotification = firstNotification {
            return (message: firstNotification.0, id: firstNotification.1)
        }
        
        let genericNotification = first(for: "*")
        if let genericNotification = genericNotification {
            return (message: genericNotification.0, id: genericNotification.1)
        }
        
        return nil
    }
    
    var isEmpty: Bool {
        las.isEmpty || messages.isEmpty
    }
}
