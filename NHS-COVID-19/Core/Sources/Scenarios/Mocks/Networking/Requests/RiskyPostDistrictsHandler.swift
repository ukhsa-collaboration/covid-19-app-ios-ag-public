//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyPostDistrictsHandler: RequestHandler {
    var paths = ["/distribution/risky-post-districts-v2"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let redRiskIndicator = "red"
        let amberRiskIndicator = "amber"
        let yellowRiskIndicator = "yellow"
        let greenRiskIndicator = "green"
        let neutralRiskIndicator = "neutral"
        
        let redPostcodes = dataProvider.redPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(redRiskIndicator)\"," }
            .joined(separator: "")
        
        let amberPostcodes = dataProvider.amberPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(amberRiskIndicator)\"," }
            .joined(separator: "")
        
        let yellowPostcodes = dataProvider.yellowPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(yellowRiskIndicator)\"," }
            .joined(separator: "")
        
        let greenPostcodes = dataProvider.greenPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(greenRiskIndicator)\"," }
            .joined(separator: "")
        
        let neutralPostcodes = dataProvider.neutralPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(neutralRiskIndicator)\"," }
            .joined(separator: "")
        
        let json = """
        {
            "postDistricts" : {
                \(neutralPostcodes)
                \(greenPostcodes)
                \(yellowPostcodes)
                \(amberPostcodes)
                \(redPostcodes)
            },
            "riskLevels" : {
                "\(neutralRiskIndicator)": {
                    "colorScheme": "neutral",
                    "name": {
                        "en": "[postcode] is in Local Alert Level 1"
                    },
                    "heading": {
                        "en": "Data from the NHS shows that the spread of coronavirus in your area is low."
                    },
                    "content": {
                        "en": "Your local authority has normal measures for coronavirus in place. It’s important that you continue to follow the latest official government guidance to help control the virus.\\n\\nFind out the restrictions for your local area to help reduce the spread of coronavirus."
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://example.com"
                    }
                },
                "\(greenRiskIndicator)": {
                    "colorScheme": "green",
                    "name": {
                        "en": "[postcode] is in Local Alert Level 1"
                    },
                    "heading": {
                        "en": "Data from the NHS shows that the spread of coronavirus in your area is low."
                    },
                    "content": {
                        "en": "Your local authority has normal measures for coronavirus in place. It’s important that you continue to follow the latest official government guidance to help control the virus.\\n\\nFind out the restrictions for your local area to help reduce the spread of coronavirus."
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://example.com"
                    }
                },
                "\(yellowRiskIndicator)": {
                    "colorScheme": "yellow",
                    "name": {
                        "en": "[postcode] is in Local Alert Level 2"
                    },
                    "heading": {
                        "en": "Data from the NHS shows that the spread of coronavirus in your area is rising."
                    },
                    "content": {
                        "en": "Your local authority is using additional measures to those in place for the rest of the country because of rising infections in your area.\\n\\nFind out the restrictions for your local area to help reduce the spread of coronavirus."
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://example.com"
                    }
                },
                "\(amberRiskIndicator)": {
                    "colorScheme": "amber",
                    "name": {
                        "en": "[postcode] is in Local Alert Level 3"
                    },
                    "heading": {
                        "en": "Data from the NHS shows that the spread of coronavirus in your area is high."
                    },
                    "content": {
                        "en": "Your local authority is using additional measures to those in place for the rest of the country because of high levels of infection in your local area.\\n\\nFind out the restrictions for your local area to help reduce the spread of coronavirus."
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://example.com"
                    }
                },
                "\(redRiskIndicator)": {
                    "colorScheme": "red",
                    "name": {
                        "en": "[postcode] is in Local Alert Level 3"
                    },
                    "heading": {
                        "en": "Data from the NHS shows that the spread of coronavirus in your area is high."
                    },
                    "content": {
                        "en": "Your local authority is using additional measures to those in place for the rest of the country because of high levels of infection in your local area.\\n\\nFind out the restrictions for your local area to help reduce the spread of coronavirus."
                    },
                    "linkTitle": {
                        "en": "Restrictions in your area"
                    },
                    "linkUrl": {
                        "en": "https://example.com"
                    }
                },
            }
        }
        """
        
        return Result.success(.ok(with: .json(json)))
    }
}
