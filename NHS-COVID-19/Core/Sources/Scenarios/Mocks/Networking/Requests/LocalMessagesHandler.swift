//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LocalMessagesHandler: RequestHandler {
    var dataProvider: MockDataProvider

    var paths: [String] = ["/distribution/local-messages"]

    var response: Result<HTTPResponse, HTTPRequestError> {
        Self.response(
            for: dataProvider.vocLocalAuthorities.commaSeparatedComponents,
            messageId: dataProvider.vocMessageId,
            contentVersion: dataProvider.vocContentVersion,
            notificationHead: dataProvider.vocMessageNotificationTitle,
            notificationBody: dataProvider.vocMessageNotificationBody
        )
    }

    static func response(for localAuthorities: Set<String>,
                         messageId: String,
                         contentVersion: Int,
                         notificationHead: String,
                         notificationBody: String) -> Result<HTTPResponse, HTTPRequestError> {
        let localAuthorityMappings = "{" +
            localAuthorities.map {
                "\"\($0)\": [\"\(messageId)\"]"
            }.joined(separator: ", ")
            + "}"

        let dateString = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])

        return Result.success(HTTPResponse.ok(with: .json(#"""
        {
            "las" : \#(localAuthorityMappings),
            "messages": {
              "\#(messageId)": {
                "type": "notification",
                "updated": "\#(dateString)",
                "contentVersion": \#(contentVersion),
                "translations": {
                  "en": {
                    "head": "\#(notificationHead)",
                    "body": "\#(notificationBody)",
                    "content": [
                        {
                            "type": "para",
                            "text": "There have been reported cases of a new variant in [local authority]. Here are some key pieces of information to help you stay safe in [postcode]",
                            "link": "http://example.com",
                            "linkText": "Click me"
                        }
                     ]
                   }
                }
            }
           }
        }
        """#)))
    }
}

private extension String {

    var commaSeparatedComponents: Set<String> {
        Set(
            components(separatedBy: ",")
                .lazy
                .filter { !$0.isEmpty }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        )
    }

}
