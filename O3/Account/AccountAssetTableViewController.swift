//
//  AccountAssetTableViewController.swift
//  O3
//
//  Created by Apisit Toompakdee on 1/21/18.
//  Copyright © 2018 O3 Labs Inc. All rights reserved.
//

import UIKit
import NeoSwift
import PKHUD
import Cache
import SwiftTheme
import Crashlytics
import StoreKit

class AccountAssetTableViewController: UITableViewController {
    @IBOutlet weak var addNEP5Button: UIButton!

    private enum sections: Int {
        case unclaimedGAS = 0
        case assets
    }

    var claims: Claims?
    var isClaiming: Bool = false
    var refreshClaimableGasTimer: Timer?

    var tokenAssets = O3Cache.tokenAssets()
    var neo: Int = Int(O3Cache.neo().value)
    var gasBalance: Double = O3Cache.gas().value
    var mostRecentClaimAmount = 0.0

    @objc func reloadCells() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAllData), name: NSNotification.Name(rawValue: "tokenSelectorDismissed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCells), name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: ThemeUpdateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "tokenSelectiorDismissed"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedStrings()
        addObservers()
        self.view.theme_backgroundColor = O3Theme.backgroundColorPicker
        self.tableView.theme_backgroundColor = O3Theme.backgroundColorPicker
        applyNavBarTheme()
        loadAccountState()
        loadClaimableGAS()
        refreshClaimableGasTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(AccountAssetTableViewController.loadClaimableGAS), userInfo: nil, repeats: true)
        refreshClaimableGasTimer?.fire()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reloadAllData), for: .valueChanged)
    }

    @objc func reloadAllData() {
        loadAccountState()
        loadClaimableGAS()
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func claimGas() {
        self.enableClaimButton(enable: false)
        self.loadClaimableGAS()
        Authenticated.account?.claimGas { _, error in
            if error != nil {
                //if error then try again in 10 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.claimGas()
                }
                return
            }
            Answers.logCustomEvent(withName: "Gas Claimed",
                             customAttributes: ["Amount": self.mostRecentClaimAmount])
            DispatchQueue.main.async {
                HUD.hide()
                OzoneAlert.alertDialog(message: AccountStrings.successfulClaimPrompt, dismissTitle: OzoneAlert.okPositiveConfirmString) {
                    UserDefaultsManager.numClaims += 1
                    if UserDefaultsManager.numClaims == 1 || UserDefaultsManager.numClaims % 10 == 0 {
                        SKStoreReviewController.requestReview()
                    }
                }

                //save latest claim time interval here to limit user to only claim every 5 minutes
                let now = Date().timeIntervalSince1970
                UserDefaults.standard.set(now, forKey: "lastetClaimDate")
                UserDefaults.standard.synchronize()

                self.isClaiming = false
                //if claim succeeded then fire the timer to refresh claimable gas again.
                self.refreshClaimableGasTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(AccountAssetTableViewController.loadClaimableGAS), userInfo: nil, repeats: true)
                self.refreshClaimableGasTimer?.fire()
                self.loadClaimableGAS()
            }
        }
    }

    func enableClaimButton(enable: Bool) {
        let indexPath = IndexPath(row: 0, section: sections.unclaimedGAS.rawValue)
        guard let cell = tableView.cellForRow(at: indexPath) as? UnclaimedGASTableViewCell else {
            return
        }
        cell.claimButton.isEnabled = enable && isClaiming == false
    }

    func prepareClaimingGAS() {

        if self.neo == 0 {
            return
        }
        refreshClaimableGasTimer?.invalidate()
        enableClaimButton(enable: false)

        HUD.show(.labeledProgress(title: AccountStrings.claimingInProgressTitle, subtitle: AccountStrings.claimingInProgressSubtitle))

        //select best node
        if let bestNode = NEONetworkMonitor.autoSelectBestNode() {
            UserDefaultsManager.seed = bestNode
            UserDefaultsManager.useDefaultSeed = false
        }

        //we are able to claim gas only when there is data in the .claims array
        if self.claims != nil && self.claims!.claims.count > 0 {
            DispatchQueue.main.async {
                self.claimGas()
            }
            return
        }

        //to be able to claim. we need to send the entire NEO to ourself.
        Authenticated.account?.sendAssetTransaction(asset: AssetId.neoAssetId, amount: Double(self.neo), toAddress: (Authenticated.account?.address)!) { completed, _ in
            if completed == false {
                HUD.hide()
                self.enableClaimButton(enable: true)
                return
            }
            DispatchQueue.main.async {
                //if completed then mark the flag that we are claiming GAS
                self.isClaiming = true
                //disable button and invalidate the timer to refresh claimable GAS
                self.refreshClaimableGasTimer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.claimGas()
                }
            }
        }
    }

    @objc func loadClaimableGAS() {
        if Authenticated.account == nil {
            return
        }

        Authenticated.account?.neoClient.getClaims(address: (Authenticated.account?.address)!) { result in
            switch result {
            case .failure:
                return
            case .success(let claims):
                self.claims = claims
                self.mostRecentClaimAmount = Double(claims.totalUnspentClaim) / 100000000.0
                DispatchQueue.main.async {
                    self.showClaimableGASAmount(amount: self.mostRecentClaimAmount)
                }
            }
        }
    }

    func showClaimableGASAmount(amount: Double) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: sections.unclaimedGAS.rawValue)
            guard let cell = self.tableView.cellForRow(at: indexPath) as? UnclaimedGASTableViewCell else {
                return
            }
            cell.amountLabel.text = amount.string(8, removeTrailing: true)

            //only enable button if latestClaimDate is more than 5 minutes
            let latestClaimDateInterval: Double = UserDefaults.standard.double(forKey: "lastetClaimDate")
            let latestClaimDate: Date = Date(timeIntervalSince1970: latestClaimDateInterval)
            let diff = Date().timeIntervalSince(latestClaimDate)
            if diff > (5 * 60) {
                cell.claimButton.isEnabled = true
            } else {
                cell.claimButton.isEnabled = false
            }
            cell.claimButton.isEnabled = amount > 0
        }
    }

    func loadAccountState() {
        O3Client().getAccountState(address: Authenticated.account?.address ?? "") { result in
            DispatchQueue.main.async {
            switch result {
                case .failure:
                    self.tableView.refreshControl?.endRefreshing()
                case .success:
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections.unclaimedGAS.rawValue {
            return 1
        }
        return 2 + tokenAssets.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == sections.unclaimedGAS.rawValue {
            return 108.0
        }
        return 52.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sections.unclaimedGAS.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell-unclaimedgas") as? UnclaimedGASTableViewCell else {
                let cell =  UITableViewCell()
                cell.theme_backgroundColor = O3Theme.backgroundColorPicker
                return cell
            }
            cell.delegate = self
            return cell
        }

        if indexPath.section == sections.assets.rawValue && indexPath.row < 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell-nativeasset") as? NativeAssetTableViewCell else {
                let cell =  UITableViewCell()
                cell.theme_backgroundColor = O3Theme.backgroundColorPicker
                return cell
            }

            if indexPath.row == 0 {
                cell.titleLabel.text = "NEO"
            }

            if indexPath.row == 1 {
                cell.titleLabel.text = "GAS"
            }

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell-nep5token") as? NEP5TokenTableViewCell else {
            let cell =  UITableViewCell()
            cell.theme_backgroundColor = O3Theme.backgroundColorPicker
            return cell
        }
        let list = tokenAssets
        let token = list[indexPath.row]
        cell.titleLabel.text = token.symbol
        cell.subtitleLabel.text = token.name
        /*DispatchQueue.global().async {
            self.loadTokenBalance(cell: cell, token: token)
        }*/
        return cell
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == sections.unclaimedGAS.rawValue {
            return false
        }
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func setLocalizedStrings() {
        self.navigationController?.navigationBar.topItem?.title = AccountStrings.accountTitle
        addNEP5Button.setTitle(AccountStrings.addNEP5Token, for: UIControlState())
    }
}

extension AccountAssetTableViewController: UnclaimGASDelegate {
    func claimButtonTapped() {
        DispatchQueue.main.async {
            self.prepareClaimingGAS()
        }
    }
}
