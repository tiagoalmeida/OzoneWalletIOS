//
//  O3Cache.swift
//  O3
//
//  Created by Andrei Terentiev on 4/16/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import Cache
import NeoSwift

class O3Cache {
    enum keys: String {
        case gasBalance
        case neoBalance
        case tokens
        case readOnlyGasBalance
        case readOnlyNeoBalance
        case readOnlyTokens
    }

    static func clear() {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.removeObject(forKey: keys.gasBalance.rawValue)
            try? storage.removeObject(forKey: keys.neoBalance.rawValue)
            try? storage.removeObject(forKey: keys.tokens.rawValue)

            try? storage.removeObject(forKey: keys.readOnlyGasBalance.rawValue)
            try? storage.removeObject(forKey: keys.readOnlyNeoBalance.rawValue)
            try? storage.removeObject(forKey: keys.readOnlyTokens.rawValue)
        }
    }

    // MARK: Cache Setters for Writable Balances
    static func setNEOForSession(neoBalance: Int) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            let neoAsset = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                             decimals: 8, value: Double(neoBalance), assetType: .nativeAsset)
            try? storage.setObject(neoAsset, forKey: keys.neoBalance.rawValue)
        }
    }

    static func setGASForSession(gasBalance: Double) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            let gasAsset = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                             decimals: 8, value: gasBalance, assetType: .nativeAsset)
            try? storage.setObject(gasAsset, forKey: keys.gasBalance.rawValue)
        }
    }

    static func setTokenAssetsForSession(tokens: [TransferableAsset]) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.setObject(tokens, forKey: keys.tokens.rawValue)
        }
    }

    // MARK: Cache Setters for Read Only Balances
    static func setReadOnlyNEOForSession(neoBalance: Int) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            let neoAsset = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                             decimals: 8, value: Double(neoBalance), assetType: .nativeAsset)
            try? storage.setObject(neoAsset, forKey: keys.readOnlyNeoBalance.rawValue)
        }
    }

    static func setReadOnlyGasForSession(gasBalance: Double) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            let gasAsset = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                                     decimals: 8, value: gasBalance, assetType: .nativeAsset)
            try? storage.setObject(gasAsset, forKey: keys.readOnlyGasBalance.rawValue)
        }
    }

    static func setReadOnlyTokensForSession(tokens: [TransferableAsset]) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.setObject(tokens, forKey: keys.readOnlyTokens.rawValue)
        }
    }

    // MARK: Cache Getters for Writable Balances
    static func gas() -> TransferableAsset {
        var cachedGASBalance = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                                 decimals: 8, value: 0, assetType: .nativeAsset)
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedGASBalance = (try? storage.object(ofType: TransferableAsset.self, forKey: keys.gasBalance.rawValue)) ?? cachedGASBalance
        }
        return cachedGASBalance
    }

    static func neo() -> TransferableAsset {
        var cachedNEOBalance = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                                 decimals: 8, value: 0, assetType: .nativeAsset)
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedNEOBalance = (try? storage.object(ofType: TransferableAsset.self, forKey: keys.neoBalance.rawValue)) ?? cachedNEOBalance
        }
        return cachedNEOBalance
    }

    static func tokenAssets() -> [TransferableAsset] {
        var cachedTokens = [TransferableAsset]()
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedTokens = (try? storage.object(ofType: [TransferableAsset].self, forKey: keys.tokens.rawValue)) ?? []
        }
        return cachedTokens
    }

    // MARK: Cache Getters For Read Only Balances
    static func readOnlyGas() -> TransferableAsset {
        var cachedGASBalance = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                                                   decimals: 8, value: 0, assetType: .nativeAsset)
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedGASBalance = (try? storage.object(ofType: TransferableAsset.self, forKey: keys.readOnlyGasBalance.rawValue)) ?? cachedGASBalance
        }
        return cachedGASBalance
    }

    static func readOnlyNeo() -> TransferableAsset {
        var cachedNEOBalance = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                                 decimals: 8, value: 0, assetType: .nativeAsset)
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedNEOBalance = (try? storage.object(ofType: TransferableAsset.self, forKey: keys.readOnlyNeoBalance.rawValue)) ?? cachedNEOBalance
        }
        return cachedNEOBalance
    }

    static func readOnlyTokens() -> [TransferableAsset] {
        var cachedTokens = [TransferableAsset]()
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedTokens = (try? storage.object(ofType: [TransferableAsset].self, forKey: keys.readOnlyTokens.rawValue)) ?? []
        }
        return cachedTokens
    }
}
