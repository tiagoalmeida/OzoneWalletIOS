//
//  CurrencyTableViewController.swift
//  O3
//
//  Created by Andrei Terentiev on 2/26/18.
//  Copyright © 2018 drei. All rights reserved.
//

import Foundation
import UIKit

class CurrencyTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet private var themedCells: [UITableViewCell]!
    @IBOutlet private var themedTitleLabels: [UILabel]!
   
    // MARK: - Properties
    
    private let currencies: [Currency] =  [.usd, .jpy, .eur, .krw, .cny, .aud, .gbp, .rub, .cad]
    private var currentlySelectedIndex = 0

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setThemedElements()
        navigationItem.title = SettingsStrings.currencyTitle(UserDefaultsManager.referenceFiatCurrency.description)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currencyIndex = currencies.index(of: UserDefaultsManager.referenceFiatCurrency)
        let selectedRow = currencyIndex ?? 0

        tableView.reloadData()
        setSelectedCell(index: selectedRow)
    }

    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        UserDefaultsManager.referenceFiatCurrency = currencies[indexPath.row]
        tableView.cellForRow(at: IndexPath(item: currentlySelectedIndex, section: 0))?.accessoryType = .none
        setSelectedCell(index: indexPath.row)
    }
    
    // MARK: - Private
    
    private func setSelectedCell(index: Int) {
        let cell = self.tableView.cellForRow(at: IndexPath(item: index, section: 0))
        cell?.accessoryType = .checkmark
        currentlySelectedIndex = index
        navigationItem.title = SettingsStrings.currencyTitle(currencies[index].description)
    }
    
    private func setThemedElements() {
        tableView.theme_backgroundColor = O3Theme.backgroundColorPicker
        tableView.theme_separatorColor = O3Theme.tableSeparatorColorPicker
        for label in themedTitleLabels {
            label.theme_textColor = O3Theme.titleColorPicker
        }
        for cell in themedCells {
            cell.theme_backgroundColor = O3Theme.backgroundColorPicker
            cell.contentView.theme_backgroundColor = O3Theme.backgroundColorPicker
        }
    }
    
}
