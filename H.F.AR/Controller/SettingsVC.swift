//
//  SettingsVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import Localize_Swift

class SettingsVC: UIViewController {
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Language View
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var selectLanguageTableView: UITableView!
    
    // App Info View
    @IBOutlet weak var appInfoView: UIView!
    @IBOutlet weak var versionTitleLbl: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var developerTitleLbl: UILabel!
    @IBOutlet weak var developerLbl1: UILabel!
    @IBOutlet weak var developerEmailBtn1: UIButton!
    @IBOutlet weak var developerLbl2: UILabel!
    @IBOutlet weak var developerEmailBtn2: UIButton!
    
    var settingElements = [String]()
    var settingViews = [UIView]()
    let languages = ["English", "한국어"]
    let langKeywards = ["en", "ko"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSettingElementsText()
        settingViews.append(languageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        selectLanguageTableView.delegate = self
        selectLanguageTableView.dataSource = self
    }
    
    func appInfoDidLoad() {
        versionTitleLbl.text = "Version".localized()
        developerTitleLbl.text = "Developers".localized()
        
        developerLbl1.text = "Jongsu Kim".localized()
        developerLbl2.text = "Juwon Lee".localized()
        
        // Get app version
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as? String
        
        if let ver = version {
            versionLbl.text = ver
        } else {
            versionLbl.text = "ERR"
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        closeLanguageView()
    }
    
    @IBAction func backBtnPressed2(_ sender: Any) {
        appInfoView.isHidden = true
        tableView.isHidden = false
    }
    
    @IBAction func loadEmail1(_ sender: Any) {
        let email = developerEmailBtn1.title(for: .normal)!
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func loadEmail2(_ sender: Any) {
        let email = developerEmailBtn2.title(for: .normal)!
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    
    
    func setSettingElementsText() {
        settingElements.removeAll()
        settingElements.append("Language")
        settingElements.append("Home Furnishing AR App Info".localized())
    }
    
    func openLanguageView() {
        tableView.isHidden = true
        selectLanguageTableView.reloadData()
        languageView.isHidden = false
    }
    
    func closeLanguageView() {
        tableView.reloadData()
        languageView.isHidden = true
        tableView.isHidden = false
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return settingElements.count
        } else if tableView == selectLanguageTableView {
            return languages.count
        }
        // Nothing
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingElementCell") as? OneLabelCell else { return UITableViewCell() }
            cell.configureCell(data: settingElements[indexPath.row])
            return cell
        } else if tableView == selectLanguageTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectLanguageCell") as? OneLabelCell else { return UITableViewCell() }
            cell.configureCell(data: languages[indexPath.row])
            if Localize.currentLanguage() == langKeywards[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        // Nothing
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if indexPath.row == 0 {
                openLanguageView()
            } else if indexPath.row == 1 {
                appInfoDidLoad()
                tableView.isHidden = true
                appInfoView.isHidden = false
            }
        } else if tableView == selectLanguageTableView {
            Localize.setCurrentLanguage(langKeywards[indexPath.row])
            setSettingElementsText()
            closeLanguageView()
        }
    }
}
