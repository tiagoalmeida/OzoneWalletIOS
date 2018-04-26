//
//  PreCreateWalletViewController.swift
//  O3
//
//  Created by Apisit Toompakdee on 10/28/17.
//  Copyright © 2017 drei. All rights reserved.
//

import UIKit
import NeoSwift

class PreCreateWalletViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create a Wallet"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToWelcome" {
            Authenticated.account = Account()
        }
    }
}
