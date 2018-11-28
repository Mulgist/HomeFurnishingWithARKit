//
//  SettingsVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
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
    
    // Edit Account View
    @IBOutlet weak var editAccountView: UIView!
    @IBOutlet weak var editAccountTitleLbl: UILabel!
    @IBOutlet weak var emailTitleLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var familyNameTitleLbl: UILabel!
    @IBOutlet weak var familyNameTextFld: UITextField!
    @IBOutlet weak var givenNameTitleLbl: UILabel!
    @IBOutlet weak var givenNameTextFld: UITextField!
    @IBOutlet weak var fullNameTitleLbl: UILabel!
    @IBOutlet weak var fullNameTextFld: UITextField!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var editNoticeLbl: UILabel!
    
    var settingElements = [String]()
    let languages = ["English", "한국어"]
    let langKeywards = ["en", "ko"]
    var isAccountEdited = false;
    var isAccountDeleted = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSettingElementsText()
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
    
    func editAccountDidLoad() {
        editAccountTitleLbl.text = "Edit Account Info".localized()
        emailTitleLbl.text = "Email: ".localized()
        familyNameTitleLbl.text = "Family Name".localized()
        givenNameTitleLbl.text = "Given Name".localized()
        fullNameTitleLbl.text = "Full Name".localized()
        deleteAccountBtn.setTitle("DELETE ACCOUNT".localized(), for: .normal)
        editNoticeLbl.text = "* The account information of the account provider is NOT modified. *".localized()
        
        emailLbl.text = UserDataService.instance.email
        familyNameTextFld.text = UserDataService.instance.familyName
        givenNameTextFld.text = UserDataService.instance.givenName
        fullNameTextFld.text = UserDataService.instance.fullName
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        closeLanguageView()
    }
    
    @IBAction func backBtnPressed2(_ sender: Any) {
        appInfoView.isHidden = true
        tableView.isHidden = false
    }
    
    @IBAction func backBtnPressed3(_ sender: Any) {
        closeEditAccountView()
        
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
    
    @IBAction func saveAccountBtnPressed(_ sender: Any) {
        // Alert Popup (Remove data)
        let alertController = UIAlertController(title: "EDIT ACCOUNT".localized(), message: "Do you want to edit your account?".localized(), preferredStyle: .alert)
        
        // |  OK  | Cancel |
        let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in
            self.editAccount()
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { action in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: Any) {
        // Alert Popup (Remove data)
        let alertController = UIAlertController(title: "DELETE ACCOUNT".localized(), message: "Do you want to delete your account? All saved states are also removed.".localized(), preferredStyle: .alert)
        
        // |  OK  | Cancel |
        let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in
            self.deleteAccount()
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { action in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func editAccount() {
        let body: [String:Any] = [
            "method": EDIT_ACCOUNT,
            "user_id": AuthService.instance.userId,
            "family": familyNameTextFld.text!,
            "given": givenNameTextFld.text!,
            "full": fullNameTextFld.text!
        ]
        
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)", method: .post, parameters: body, encoding: URLEncoding.default, headers: URL_ENCODE_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                var json = JSON(data)
                json = json[0]
                
                if json["result"].stringValue == "success" {
                    self.isAccountEdited = true
                    self.closeEditAccountView()
                    
                    let alertController = UIAlertController(title: "EDIT SUCCEED".localized(), message: "Your account has been successfully edited.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "EDIT FAILED".localized(), message: "Your account editing failed for some reason. Please try again.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func deleteAccount() {
        let body: [String:Any] = [
            "method": DELETE_ACCOUNT,
            "user_id": AuthService.instance.userId,
        ]
        
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)", method: .post, parameters: body, encoding: URLEncoding.default, headers: URL_ENCODE_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                var json = JSON(data)
                json = json[0]
                
                if json["result"].stringValue == "success" {
                    self.isAccountDeleted = true
                    self.closeEditAccountView()
                    
                    let alertController = UIAlertController(title: "DELETE SUCCEED".localized(), message: "Your account has been successfully deleted.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "DELETE FAILED".localized(), message: "Your account deleting failed for some reason. Please try again.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setSettingElementsText() {
        settingElements.removeAll()
        settingElements.append("Language")
        
        if AuthService.instance.isLoggedIn {
            settingElements.append("Edit Account Info".localized())
        }
        
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
    
    func closeEditAccountView() {
        if isAccountEdited {
            UserDataService.instance.editUserData(familyName: familyNameTextFld.text!, givenName: givenNameTextFld.text!, fullName: fullNameTextFld.text!)
            isAccountEdited = false
        }
        
        if isAccountDeleted {
            UserDataService.instance.logoutUser()
            setSettingElementsText()
            tableView.reloadData()
            isAccountDeleted = false
        }
        
        editAccountView.isHidden = true
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
                if AuthService.instance.isLoggedIn {
                    editAccountDidLoad()
                    tableView.isHidden = true
                    editAccountView.isHidden = false
                } else {
                    appInfoDidLoad()
                    tableView.isHidden = true
                    appInfoView.isHidden = false
                }
            } else if indexPath.row == 2 {
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
