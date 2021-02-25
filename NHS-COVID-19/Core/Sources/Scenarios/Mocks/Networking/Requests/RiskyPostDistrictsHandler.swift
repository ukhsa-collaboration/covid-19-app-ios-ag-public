//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct RiskyPostDistrictsHandler: RequestHandler {
    var paths = ["/distribution/risky-post-districts-v2"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let blackRiskIndicator = "black"
        let maroonRiskIndicator = "maroon"
        let redRiskIndicator = "red"
        let amberRiskIndicator = "amber"
        let yellowRiskIndicator = "yellow"
        let greenRiskIndicator = "green"
        let neutralRiskIndicator = "neutral"
        
        let blackPostcodes = dataProvider.blackPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(blackRiskIndicator)\"," }
            .joined(separator: "")
        
        let maroonPostcodes = dataProvider.maroonPostcodes.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(maroonRiskIndicator)\"," }
            .joined(separator: "")
        
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
        
        let blackLocalAuthorities = dataProvider.blackLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(blackRiskIndicator)\"," }
            .joined(separator: "")
        
        let maroonLocalAuthorities = dataProvider.maroonLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(maroonRiskIndicator)\"," }
            .joined(separator: "")
        
        let redLocalAuthorities = dataProvider.redLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(redRiskIndicator)\"," }
            .joined(separator: "")
        
        let amberLocalAuthorities = dataProvider.amberLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(amberRiskIndicator)\"," }
            .joined(separator: "")
        
        let yellowLocalAuthorities = dataProvider.yellowLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(yellowRiskIndicator)\"," }
            .joined(separator: "")
        
        let greenLocalAuthorities = dataProvider.greenLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(greenRiskIndicator)\"," }
            .joined(separator: "")
        
        let neutralLocalAuthorities = dataProvider.neutralLocalAuthorities.components(separatedBy: ",")
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"\(neutralRiskIndicator)\"," }
            .joined(separator: "")
        
        func policyData(alertLevel: Int) -> String {
            """
            {
                "localAuthorityRiskTitle": {
                    "en": "[local authority] ([postcode]) is in Local Alert Level 1"
                },
                "heading": {
                    "en": "Coronavirus cases are very high in your area"
                },
                "content": {
                    "en": "The restrictions placed on areas with a very high level of infections can vary and are based on discussions between central and local government. You should check the specific rules in your area."
                },
                "footer": {
                    "en": "Find out what rules apply in your area to help reduce the spread of coronavirus."
                },
                "policies": [
                    {
                        "policyIcon": "default-icon",
                        "policyHeading": {
                            "en": "Default"
                        },
                        "policyContent": {
                            "en": "Venues must close…"
                        }
                    },
                    {
                        "policyIcon": "meeting-people",
                        "policyHeading": {
                            "en": "Meeting people"
                        },
                        "policyContent": {
                            "en": "No household mixing indoors or outdoors in venues or private gardens. Rule of six applies in outdoor public spaces like parks."
                        }
                    },
                    {
                        "policyIcon": "bars-and-pubs",
                        "policyHeading": {
                            "en": "Bars and pubs"
                        },
                        "policyContent": {
                            "en": "Venues not serving meals will be closed."
                        }
                    },
                    {
                        "policyIcon": "worship",
                        "policyHeading": {
                            "en": "Worship"
                        },
                        "policyContent": {
                            "en": "These remain open, subject to indoor or outdoor venue restrictions."
                        }
                    },
                    {
                        "policyIcon": "overnight-stays",
                        "policyHeading": {
                            "en": "Overnight Stays"
                        },
                        "policyContent": {
                            "en": "If you have to travel, avoid staying overnight."
                        }
                    },
                    {
                        "policyIcon": "education",
                        "policyHeading": {
                            "en": "Education"
                        },
                        "policyContent": {
                            "en": "Schools, colleges and universities remain open, with restrictions."
                        }
                    },
                    {
                        "policyIcon": "travelling",
                        "policyHeading": {
                            "en": "Travelling"
                        },
                        "policyContent": {
                            "en": "Avoid travelling around or leaving the area, other than for work, education, youth services or because of caring responsibilities."
                        }
                    },
                    {
                        "policyIcon": "exercise",
                        "policyHeading": {
                            "en": "Exercise"
                        },
                        "policyContent": {
                            "en": "Classes and organised adult sport are allowed outdoors and only allowed indoors if no household mixing. Sports for the youth and disabled is allowed indoors and outdoors."
                        }
                    },
                    {
                        "policyIcon": "weddings-and-funerals",
                        "policyHeading": {
                            "en": "Weddings and Funerals"
                        },
                        "policyContent": {
                            "en": "Up to 15 guests for weddings, 30 for funerals and 15 for wakes. Wedding receptions not permitted."
                        }
                    },
                    {
                        "policyIcon": "businesses",
                        "policyHeading": {
                            "en": "Businesses"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "retail",
                        "policyHeading": {
                            "en": "Retail"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "entertainment",
                        "policyHeading": {
                            "en": "Entertainment"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "personal-care",
                        "policyHeading": {
                            "en": "Personal Care"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "large-events",
                        "policyHeading": {
                            "en": "Large Events"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "clinically-extremely-vulnerable",
                        "policyHeading": {
                            "en": "Clinically Extremely Vulnerable"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "social-distancing",
                        "policyHeading": {
                            "en": "Social Distancing"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "face-coverings",
                        "policyHeading": {
                            "en": "Face Coverings"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "meeting-outdoors",
                        "policyHeading": {
                            "en": "Meeting Outdoors"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "meeting-indoors",
                        "policyHeading": {
                            "en": "Meeting Indoors"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "work",
                        "policyHeading": {
                            "en": "Work"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    },
                    {
                        "policyIcon": "international-travel",
                        "policyHeading": {
                            "en": "International Travel"
                        },
                        "policyContent": {
                            "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                        }
                    }
                ]
            }
            """
        }
        
        let json = """
        {
            "postDistricts" : {
                \(neutralPostcodes)
                \(greenPostcodes)
                \(yellowPostcodes)
                \(amberPostcodes)
                \(redPostcodes)
                \(maroonPostcodes)
                \(blackPostcodes)
            },
            "localAuthorities": {
                \(neutralLocalAuthorities)
                \(greenLocalAuthorities)
                \(yellowLocalAuthorities)
                \(amberLocalAuthorities)
                \(redLocalAuthorities)
                \(maroonLocalAuthorities)
                \(blackLocalAuthorities)
            },
            "riskLevels" : {
                "\(neutralRiskIndicator)": {
                    "colorScheme": "neutral",
                    "colorSchemeV2": "neutral",
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
                    },
                    "policyData": \(policyData(alertLevel: 1))
                },
                "\(greenRiskIndicator)": {
                    "colorScheme": "green",
                    "colorSchemeV2": "green",
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
                    },
                    "policyData": \(policyData(alertLevel: 1))
                },
                "\(yellowRiskIndicator)": {
                    "colorScheme": "yellow",
                    "colorSchemeV2": "yellow",
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
                    },
                    "policyData": \(policyData(alertLevel: 2))
                },
                "\(amberRiskIndicator)": {
                    "colorScheme": "amber",
                    "colorSchemeV2": "amber",
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
                    },
                    "policyData": \(policyData(alertLevel: 3))
                },
                "\(redRiskIndicator)": {
                    "colorScheme": "red",
                    "colorSchemeV2": "red",
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
                    },
                    "policyData": \(policyData(alertLevel: 3))
                },
                "\(maroonRiskIndicator)": {
                    "colorScheme": "neutral",
                    "colorSchemeV2": "maroon",
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
                    },
                    "policyData": \(policyData(alertLevel: 3))
                },
                "\(blackRiskIndicator)": {
                    "colorScheme": "neutral",
                    "colorSchemeV2": "black",
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
                    },
                    "policyData": \(policyData(alertLevel: 3))
                },
            }
        }
        """
        
        return Result.success(.ok(with: .json(json)))
    }
}
