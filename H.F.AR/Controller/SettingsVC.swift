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
    @IBOutlet weak var enBtn: UIButton!
    @IBOutlet weak var koBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Localize.currentLanguage() == "en" {
            enBtn.backgroundColor = #colorLiteral(red: 0.5019607843, green: 0.3312425119, blue: 0.08983408131, alpha: 1)
            koBtn.backgroundColor = #colorLiteral(red: 0.7670905556, green: 0.6118228691, blue: 0.1305803571, alpha: 1)
        } else if Localize.currentLanguage() == "ko" {
            enBtn.backgroundColor = #colorLiteral(red: 0.7670905556, green: 0.6118228691, blue: 0.1305803571, alpha: 1)
            koBtn.backgroundColor = #colorLiteral(red: 0.5019607843, green: 0.3312425119, blue: 0.08983408131, alpha: 1)
        }
    }
    
    @IBAction func enBtnPressed(_ sender: Any) {
        Localize.setCurrentLanguage("en")
        enBtn.backgroundColor = #colorLiteral(red: 0.5019607843, green: 0.3312425119, blue: 0.08983408131, alpha: 1)
        koBtn.backgroundColor = #colorLiteral(red: 0.7670905556, green: 0.6118228691, blue: 0.1305803571, alpha: 1)
    }
    
    @IBAction func koBtnPressed(_ sender: Any) {
        Localize.setCurrentLanguage("ko")
        enBtn.backgroundColor = #colorLiteral(red: 0.7670905556, green: 0.6118228691, blue: 0.1305803571, alpha: 1)
        koBtn.backgroundColor = #colorLiteral(red: 0.5019607843, green: 0.3312425119, blue: 0.08983408131, alpha: 1)
    }
}
