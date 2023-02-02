//
//  Beer.swift
//  Brewery
//
//  Created by Cody on 2022/08/26.
//

import Foundation

struct Beer: Decodable {
    let id: Int?
    let name, tagLineString, description, brewersTips, imageUrl: String?
    let foodPairing: [String]?
    
    var tagLine: String {
        let tags = tagLineString?.components(separatedBy: ". ")
        let hashTags = tags?.map {
            "#" + $0.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: "")
        }

        return hashTags?.joined(separator: " ") ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case tagLineString = "tagline"
        case imageUrl = "image_url"
        case brewersTips = "brewers_tips"
        case foodPairing = "food_pairing"
    }
}
