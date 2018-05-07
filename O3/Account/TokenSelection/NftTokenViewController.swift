//
//  NftTokenViewController.swift
//  O3
//
//  Created by Andrei Terentiev on 5/1/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class NftSelectionViewController: UIViewController {
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var nftConstructionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = O3Theme.backgroundColorPicker
        nftConstructionLabel.text = TokenSelectionStrings.underConstruction
        let lottieView = LOTAnimationView(name: "panda1")
        lottieView.frame = animationView.bounds
        lottieView.loopAnimation = true
        animationView.addSubview(lottieView)
        lottieView.play()
    }
}
