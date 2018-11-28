//
//  AccountVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import Localize_Swift

class AccountVC: UIViewController, WKUIDelegate {
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
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var showWebView: UIView!
    @IBOutlet weak var webBaseView: UIView!
    
    
    let transition = CATransition()
    var webView: WKWebView!
    var responseBody: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize
        emailLblLbl.text = "EMAIL ADDRESS".localized()
        fullNameLblLbl.text = "FULL NAME".localized()
        logoutBtn.setTitle("Logout".localized(), for: .normal)
        accountProviderLbl.text = "ACCOUNT PROVIDER".localized()
        policyBtn.setTitle("> Privacy Policy".localized(), for: .normal)
        
        setupWebView()
        webView.uiDelegate = self
        webBaseView.addSubview(webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserInfo()
    }
    
    func setupWebView() {
        let contentController = WKUserContentController()
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.suppressesIncrementalRendering = true
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 350, height: 304), configuration: config)
        webView.clearsContextBeforeDrawing = true
    }
    
    func goUrl(urlString: String) {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    func loadUserInfo() {
        if UserDataService.instance.fullName == "" {
            self.nameLbl.text = "...Loading..."
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
        UserDataService.instance.logoutUser()
        dismissDetail()
    }
    
    @IBAction func poilcyBtnPressed(_ sender: Any) {
        showWebView.isHidden = false
        goUrl(urlString: PRIVACY_POLICY_URL)
    }
    
    @IBAction func webCloseBtnPressed(_ sender: Any) {
        goUrl(urlString: "about:blank")
        showWebView.isHidden = true
    }
}
