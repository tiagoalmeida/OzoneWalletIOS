//
//  NEP5Token.swift
//  O3
//
//  Created by Apisit Toompakdee on 1/21/18.
//  Copyright © 2018 drei. All rights reserved.
//

import UIKit
struct NEP5Token: Codable {

    var tokenHash: String!
    var name: String!
    var symbol: String!
    var decimal: Int!
    var totalSupply: Int!

    enum CodingKeys: String, CodingKey {
        case tokenHash
        case name
        case symbol
        case decimal
        case totalSupply
    }

    public init(tokenHash: String, name: String, symbol: String, decimal: Int, totalSupply: Int) {
        self.tokenHash = tokenHash
        self.name = name
        self.symbol = symbol
        self.decimal = decimal
        self.totalSupply = totalSupply
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenHash: String = try container.decode(String.self, forKey: .tokenHash)
        let name: String = try container.decode(String.self, forKey: .name)
        let symbol: String = try container.decode(String.self, forKey: .symbol)
        let decimal: Int = try container.decode(Int.self, forKey: .decimal)
        let totalSupply: Int = try container.decode(Int.self, forKey: .totalSupply)
        self.init(tokenHash: tokenHash, name: name, symbol: symbol, decimal: decimal, totalSupply: totalSupply)
    }
}
