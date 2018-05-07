//
//  HomeViewModel.swift
//  O3
//
//  Created by Andrei Terentiev on 2/6/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import NeoSwift
import UIKit

protocol HomeViewModelDelegate: class {
    func updateWithBalanceData(_ assets: [TransferableAsset])
    func updateWithPortfolioData(_ portfolio: PortfolioValue)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class HomeViewModel {
    weak var delegate: HomeViewModelDelegate?

    var writableTokens: [TransferableAsset] = O3Cache.tokenAssets()
    var readOnlyTokens: [TransferableAsset] = O3Cache.readOnlyTokens()
    var neoBalance = O3Cache.neoBalance()
    var gasBalance = O3Cache.gasBalance()
    var readOnlyNeoBalance = O3Cache.readOnlyNeoBalance()
    var readOnlyGasBalance = O3Cache.readOnlyGasBalance()
    

    var watchAddresses = [WatchAddress]()
    var group = DispatchGroup()

    var portfolioType: PortfolioType = .writable
    var referenceCurrency: Currency = .usd
    var selectedInterval: PriceInterval = .oneDay

    func setPortfolioType(_ portfolioType: PortfolioType) {
        self.portfolioType = portfolioType
        self.delegate?.updateWithBalanceData(getTransferableAssets())
        loadPortfolioValue()
    }

    func setInterval(_ interval: PriceInterval) {
        self.selectedInterval = interval
        loadPortfolioValue()
    }

    func setReferenceCurrency(_ currency: Currency) {
        self.referenceCurrency = currency
    }

    func getCombinedReadOnlyAndWriteable() -> [TransferableAsset] {
        var assets: [TransferableAsset] = getReadOnlyAssets()
        for asset in getWritableAssets() {
            if let index = assets.index(where: { (item) -> Bool in item.name == asset.name }) {
                assets[index].value = assets[index].value + asset.value
            } else {
                assets.append(asset)
            }
        }
        return assets
    }
    
    func getWritableAssets() -> [TransferableAsset] {
        let neo = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                    decimals: 8, value: Double(neoBalance), assetType: .nativeAsset)
        let gas = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                    decimals: 8, value: Double(neoBalance), assetType: .nativeAsset)
        return [neo, gas] + writableTokens
    }
    
    func getReadOnlyAssets() -> [TransferableAsset] {
        let neo = TransferableAsset(id: NeoSwift.AssetId.neoAssetId.rawValue, name: "NEO", symbol: "NEO",
                                    decimals: 8, value: Double(readOnlyNeoBalance), assetType: .nativeAsset)
        let gas = TransferableAsset(id: NeoSwift.AssetId.gasAssetId.rawValue, name: "GAS", symbol: "GAS",
                                    decimals: 8, value: Double(readOnlyGasBalance), assetType: .nativeAsset)
        return [neo, gas] + writableTokens
    }

    func getTransferableAssets() -> [TransferableAsset] {
        var transferableAssetsToReturn: [TransferableAsset]  = []
        switch self.portfolioType {
        case .writable: transferableAssetsToReturn = getWritableAssets()
        case .readOnlyAndWritable: transferableAssetsToReturn = getCombinedReadOnlyAndWriteable()
        case .readOnly: transferableAssetsToReturn = getReadOnlyAssets()
        }

        //Put NEO + GAS at the top
        var sortedAssets = [TransferableAsset]()
        if let indexNEO = transferableAssetsToReturn.index(where: { (item) -> Bool in
            item.symbol == "NEO"
        }) {
            sortedAssets.append(transferableAssetsToReturn[indexNEO])
            transferableAssetsToReturn.remove(at: indexNEO)
        }

        if let indexGAS = transferableAssetsToReturn.index(where: { (item) -> Bool in
            item.symbol == "GAS"
        }) {
            sortedAssets.append(transferableAssetsToReturn[indexGAS])
            transferableAssetsToReturn.remove(at: indexGAS)
        }
        transferableAssetsToReturn.sort {$0.name < $1.name}
        return sortedAssets + transferableAssetsToReturn
    }

    func initiateCacheBalances() {
        
        
        
        /*if let storage =  try? Storage(diskConfig: DiskConfig(name: "O3")) {
            cachedWritableAssets = (try? storage.object(ofType: [TransferableAsset].self, forKey: "writableAssets")) ?? []
            cachedReadOnlyAssets = (try? storage.object(ofType: [TransferableAsset].self, forKey: "readOnlyAssets")) ?? []
        }*/
    }

    init(delegate: HomeViewModelDelegate) {
        self.delegate = delegate
        reloadBalances()
    }

    func reloadBalances() {
        do {
            watchAddresses = try UIApplication.appDelegate.persistentContainer.viewContext.fetch(WatchAddress.fetchRequest())
        } catch {
            
        }

        fetchAssetBalances(address: (Authenticated.account?.address)!, isReadOnly: false)
        for watchAddress in watchAddresses {
            if NEOValidator.validateNEOAddress(watchAddress.address ?? "") {
                self.fetchAssetBalances(address: (watchAddress.address)!, isReadOnly: true)
            }
        }
        group.notify(queue: .main) {
            self.loadPortfolioValue()
            self.delegate?.updateWithBalanceData(self.getTransferableAssets())
        }
    }

    

    func fetchAccountState(address: String, isReadOnly: Bool) {
       
    }

    func fetchAssetBalances(address: String, isReadOnly: Bool) {
       
    }
    
    
    
    func loadPortfolioValue() {
        delegate?.showLoadingIndicator()
        DispatchQueue.global().async {
            O3Client.shared.getPortfolioValue(self.getTransferableAssets(), interval: self.selectedInterval.rawValue) {result in
                switch result {
                case .failure:
                    self.delegate?.hideLoadingIndicator()
                case .success(let portfolio):
                    self.delegate?.hideLoadingIndicator()
                    self.delegate?.updateWithPortfolioData(portfolio)
                }
            }
        }
    }
}
