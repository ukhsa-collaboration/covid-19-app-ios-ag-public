//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

/*
 
 {
  "postcodes": {
   "AB1": ["S0002"],
   "AB2": ["S0002", "S0003"]
  }
  "localAuthorities": {
    "S0002": {
      "name": "Aberdeenshire",
      "country": "Scotland"
    }
  }
 }
 
 */
typealias PostcodeID = String
typealias LocalAuthorityID = String

let path = Bundle.main.url(forResource: "postcode", withExtension: "csv")
let content = try String(contentsOf: path!)

// Remove metadata and split
let result = content.split(separator: "\r\n").map { String($0) }.dropFirst()

let arr = result.map { line -> (PostcodeID, LocalAuthorityID, String) in
    let arr = line.split(separator: ";")
    return (String(arr[0]), String(arr[1]), String(arr[2]))
}

/// Local Authority
struct LA: Hashable, Codable {
    let name: String
    let country: String
}

struct PostcodeLA: Codable {
    /// Postcode ID with a Set of Local Authorities IDs
    var postcodes: [String: Set<String>]
    let localAuthorities: [String: LA]
}

let localAuthorities = arr.map { _, id, name -> (String, LA) in
    let country: String = {
        switch String(id.first!) {
        case "E": return "England"
        case "S": return "Scotland"
        case "N": return "Nothern Island"
        case "W": return "Wales"
        default: fatalError()
        }
    }()
    
    let la = LA(name: name, country: country)
    return (id, la)
}

let postcodes = arr.map { postcodeID, id, _ -> (String, Set<String>) in
    
    (postcodeID, [id])
}

// Bound postcode id with it's ocal authorities id's
let newpcs = postcodes.reduce([(String, Set<String>)]()) { ini, next -> [(String, Set<String>)] in
    var ini = ini
    let keys = next.0.split(separator: "_").map { String($0) }
    keys.forEach { ini.append(($0, next.1)) }
    return ini
}

let postcodesDict = Dictionary(newpcs) { $0.union($1) }

let authoritiesDict = Dictionary(localAuthorities) { _, value in
    value
}

let postcodeLA = PostcodeLA(postcodes: postcodesDict, localAuthorities: authoritiesDict)

let encodedPostcodeLA = try! JSONEncoder().encode(postcodeLA)

print(String(data: encodedPostcodeLA, encoding: .utf8)!)
