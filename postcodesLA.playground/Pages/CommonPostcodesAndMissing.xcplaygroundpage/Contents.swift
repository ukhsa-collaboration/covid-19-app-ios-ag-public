//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import PlaygroundSupport

// Common postcodes and missing postcodes form the old file

let path = Bundle.main.url(forResource: "postcode", withExtension: "csv")

let content = try String(contentsOf: path!)
let result = content.split(separator: "\r\n").map { String($0) }.dropFirst()

let arr = result.map { line -> (String, Set<String>) in
    let arr = line.split(separator: ";")
    return (String(arr[1].first!), Set(String(arr[0]).split(separator: "_").map { String($0) }))
}

let postcodeDict = Dictionary(arr) { $0.union($1) }

let countries = ["Northern Ireland", "Wales", "Scotland"]

/// Printing common postcods in countries

countries.forEach {
    let result = postcodeDict["E"]!.intersection(postcodeDict[String($0.first!)]!)
    if !result.isEmpty {
        print("England and \($0) common postcodes: ")
        print(result.sorted())
        print("---")
    }

}

let url1 = Bundle.main.url(forResource: "PostalDistricts", withExtension: ".json")
let data = try? Data(contentsOf: url1!)

let validPostcodesByAuthority = try JSONDecoder().decode([String: Set<String>].self, from: data!)

// print("Englad postcodes missing from the new csv file: \(validPostcodesByAuthority["E"]!.symmetricDifference(postcodeDict["E"]!))")
// print("North Ireland postcodes missing from the new csv file: \(validPostcodesByAuthority["N"]!.symmetricDifference(postcodeDict["N"]!))")
// print("Wales postcodes missing from the new csv file: \(validPostcodesByAuthority["W"]!.symmetricDifference(postcodeDict["W"]!))")
// print("Scotland postcodes missing from the new csv file: \(validPostcodesByAuthority["S"]!.symmetricDifference(postcodeDict["S"]!))")

struct PostcodeLAResult: Codable {
    let postcodes: [Postcode]
}

struct Postcode: Codable {
    let id: String
    let authorities: [LocalAuthority]
}

struct LocalAuthority: Codable {
    let id: String
    let name: String
    let country: [String]
}
