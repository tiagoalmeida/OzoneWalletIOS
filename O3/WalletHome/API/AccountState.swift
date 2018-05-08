//
//  AccountState.swift
//  O3
//
//  Created by Andrei Terentiev on 5/7/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import NeoSwift

typealias TransferableAsset = AccountState.TransferableAsset

public struct AccountState: Codable {
    var version: Int
    var address: String
    var scriptHash: String
    var assets: [TransferableAsset]
    var nep5Tokens: [TransferableAsset]

    enum CodingKeys: String, CodingKey {
        case version
        case address
        case scriptHash
        case assets
        case nep5Tokens
    }

    public init(version: Int, address: String, scriptHash: String,
                assets: [TransferableAsset], nep5Tokens: [TransferableAsset]) {
        self.version = version
        self.address = address
        self.scriptHash = scriptHash
        self.assets = assets
        self.nep5Tokens = nep5Tokens
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version: Int = try container.decode(Int.self, forKey: .version)
        let address: String = try container.decode(String.self, forKey: .address)
        let scriptHash: String = try container.decode(String.self, forKey: .scriptHash)
        let assets: [TransferableAsset] = try container.decode([TransferableAsset].self, forKey: .assets)
        let nep5Tokens: [TransferableAsset] = try container.decode([TransferableAsset].self, forKey: .nep5Tokens)
        self.init(version: version, address: address, scriptHash: scriptHash, assets: assets, nep5Tokens: nep5Tokens)
    }

    public struct TransferableAsset: Codable {
        var id: String
        var name: String
        var symbol: String
        var decimals: Int
        var value: Double
        var assetType: AssetType

        public enum AssetType: Int, Codable {
            case nativeAsset = 0
            case nep5Token
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case symbol
            case decimals
            case value
        }

        public init(id: String, name: String, symbol: String, decimals: Int, value: Double, assetType: AssetType) {
            self.id = id
            self.name = name
            self.symbol = symbol
            self.decimals = decimals
            self.value = value
            self.assetType = assetType
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let symbol = try container.decode(String.self, forKey: .symbol)
            let decimals = try container.decode(Int.self, forKey: .decimals)
            let valueString = try container.decode(String.self, forKey: .value)
            let valueDecimal = Decimal(string: valueString)
            let type: AssetType = id.hasPrefix("0x") ? .nativeAsset : .nep5Token
            var value = 0.0
            if type == .nativeAsset {
                value = Double(truncating: (valueDecimal as NSNumber?)!)
            } else {
                let dividedBalance = value / 10000000
                value = Double(truncating: (dividedBalance as NSNumber?)!)
            }

            self.init(id: id, name: name, symbol: symbol, decimals: decimals, value: value, assetType: type)
        }
    }
}

extension TransferableAsset {

    var formattedBalanceString: String {
        let amountFormatter = NumberFormatter()
        amountFormatter.minimumFractionDigits = self.decimals
        amountFormatter.numberStyle = .decimal
        amountFormatter.locale = Locale.current
        amountFormatter.usesGroupingSeparator = true
        return String(format: "%@", amountFormatter.string(from: NSDecimalNumber(decimal: Decimal(self.value)))!)
    }
}

extension TransferableAsset {
    static func NEO() -> TransferableAsset {
        return TransferableAsset(
            id: NeoSwift.AssetId.neoAssetId.rawValue,
            name: "NEO",
            symbol: "NEO",
            decimals: 0,
            value: O3Cache.neo().value,
            assetType: AssetType.nativeAsset)
    }

    static func GAS() -> TransferableAsset {
        return TransferableAsset(
            id: NeoSwift.AssetId.gasAssetId.rawValue,
            name: "GAS",
            symbol: "GAS",
            decimals: 8,
            value: O3Cache.gas().value,
            assetType: AssetType.nativeAsset)
    }
}
