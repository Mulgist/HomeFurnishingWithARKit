//
//  SelectProviderVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import WebKit
import Localize_Swift

class SelectProviderVC: UIViewController, WKScriptMessageHandler, WKUIDelegate {
    // Outlets
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var MicrosoftLoginBtn: UIButton!
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var showWebView: UIView!
    @IBOutlet weak var webBaseView: UIView!
    
    let transition = CATransition()
    var webView: WKWebView!
    var responseBody: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localization
        loginLbl.text = "LOG IN".localized(using: "MainStrings")
        googleLoginBtn.setTitle("Google Login".localized(using: "MainStrings"), for: .normal)
        MicrosoftLoginBtn.setTitle("Microsoft Login".localized(using: "MainStrings"), for: .normal)
        policyBtn.setTitle("> Privacy Policy".localized(using: "MainStrings"), for: .normal)
        
        setupWebView()
        webView.uiDelegate = self
        webBaseView.addSubview(webView)
    }
    
    func setupWebView() {
        let contentController = WKUserContentController()
        
        contentController.add(self, name: "loginSuccessAction")
        contentController.add(self, name: "exitAction")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.suppressesIncrementalRendering = true
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 350, height: 304), configuration: config)
        
        // Customizing User Agent due to Google's restriction policy on User Agent.
        webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 11_0_3 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Mobile/15A432 Safari/604.1.38 Version/11.2.0.0.2"
        webView.clearsContextBeforeDrawing = true
    }
    
    @IBAction func googleLoginBtnPressed(_ sender: Any) {
        showWebView.isHidden = false
        goUrl(urlString: GOOGLE_LOGIN_URL)
    }
    
    @IBAction func microsoftLoginBtnPressed(_ sender: Any) {
        showWebView.isHidden = false
        goUrl(urlString: MICROSOFT_LOGIN_URL)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func webBackBtnPressed(_ sender: Any) {
        goUrl(urlString: "about:blank")
        showWebView.isHidden = true
        webExitAction()
    }
    
    @IBAction func policyBtnPressed(_ sender: Any) {
        showWebView.isHidden = false
        goUrl(urlString: PRIVACY_POLICY_URL)
    }
    
    func goUrl(urlString: String) {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    func webExitAction() {
        if responseBody != "" {
            AuthService.instance.userId = responseBody
            AuthService.instance.setAndLoadUserInfoById { (success) in
                usleep(500000)
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showWebView.isHidden = true
                }
            }
        } else {
            showWebView.isHidden = true
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "loginSuccessAction" {
            print("JavaScript is sending a id \(message.body)")
            responseBody = message.body as! String
        }
        if message.name == "exitAction" {
            webExitAction()
        }
    }
}
