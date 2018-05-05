//
//  AccountVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import Alamofire
import Localize_Swift

class AccountVC: UIViewController {
    // Outlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLblLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var fullNameLblLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var accountProviderLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var providerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize
        emailLblLbl.text = "EMAIL ADDRESS".localized(using: "MainStrings")
        fullNameLblLbl.text = "FULL NAME".localized(using: "MainStrings")
        logoutBtn.setTitle("Logout".localized(using: "MainStrings"), for: .normal)
        accountProviderLbl.text = "ACCOUNT PROVIDER".localized(using: "MainStrings")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUserInfo()
    }
    
    func loadUserInfo() {
        if UserDataService.instance.fullName == "" {
            self.nameLbl.text = "...로드하는 중..."
        } else {
            if Localize.currentLanguage() == "en" {
                self.nameLbl.text = "Welcome Back, \(UserDataService.instance.familyName)!"
            } else if Localize.currentLanguage() == "ko" {
                self.nameLbl.text = "\(UserDataService.instance.familyName)\(UserDataService.instance.givenName)님 환영합니다!"
            }
        }
        self.emailLbl.text = UserDataService.instance.email
        self.fullNameLbl.text = UserDataService.instance.fullName
        self.profileImage.image = UserDataService.instance.profileImage
        if UserDataService.instance.provider == "Google" {
            Alamofire.request(GOOGLE_LOGO_URL).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.providerImage.image = image
            })
        } else if UserDataService.instance.provider == "Microsoft" {
            Alamofire.request(MICROSOFT_LOGO_URL).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.providerImage.image = image
            })
        }
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        UserDataService.instance.logoutUser()
        dismiss(animated: false, completion: nil)
    }
}
