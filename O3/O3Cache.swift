//
//  O3Cache.swift
//  O3
//
//  Created by Andrei Terentiev on 4/16/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import Cache

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
            try? storage.setObject(neoBalance, forKey: keys.neoBalance.rawValue)
        }
    }

    static func setGASForSession(gasBalance: Double) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.setObject(gasBalance, forKey: keys.gasBalance.rawValue)
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
            try? storage.setObject(neoBalance, forKey: keys.readOnlyNeoBalance.rawValue)
        }
    }
    
    static func setReadOnlyGasForSession(gasBalance: Double) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.setObject(gasBalance, forKey: keys.readOnlyGasBalance.rawValue)
        }
    }
    
    static func setReadOnlyTokensForSession(tokens: [TransferableAsset]) {
        if let storage = try? Storage(diskConfig: DiskConfig(name: "O3")) {
            try? storage.setObject(tokens, forKey: keys.readOnlyTokens.rawValue)
        }
    }

    // MARK: Cache Getters for Writable Balances
    static func gasBalance() -> Double {
        var cachedGASBalance = 0.0
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedGASBalance = (try? storage.object(ofType: Double.self, forKey: keys.gasBalance.rawValue)) ?? 0.0
        }
        return cachedGASBalance
    }

    static func neoBalance() -> Int {
        var cachedNEOBalance = 0
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedNEOBalance = (try? storage.object(ofType: Int.self, forKey: keys.neoBalance.rawValue)) ?? 0
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
    static func readOnlyGasBalance() -> Double {
        var cachedGASBalance = 0.0
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedGASBalance = (try? storage.object(ofType: Double.self, forKey: keys.readOnlyGasBalance.rawValue)) ?? 0.0
        }
        return cachedGASBalance
    }
    
    static func readOnlyNeoBalance() -> Int {
        var cachedNEOBalance = 0
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedNEOBalance = (try? storage.object(ofType: Int.self, forKey: keys.readOnlyNeoBalance.rawValue)) ?? 0
        }
        return cachedNEOBalance
    }
    
    static func readOnlyTokens() -> [TransferableAsset] {
        var cachedTokens = [TransferableAsset]()
        if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedTokens = (try? storage.object(ofType: [AccountState.Asset].self, forKey: keys.readOnlyTokens.rawValue)) ?? []
        }
        return cachedTokens
    }
}
