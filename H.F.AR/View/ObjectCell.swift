//
//  VirtualObjectSelectionCell.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 17..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import Localize_Swift

// MARK: - ObjectCell
class ObjectCell: UITableViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    
    var modelName = "" {
        didSet {
            if Localize.currentLanguage() == "ko" {
                objectTitleLabel.text = modelName.localized(using: "MainVCStrings")
            } else {
                objectTitleLabel.text = modelName.capitalized
            }
        
        objectImageView.image = UIImage(named: modelName)
        }
    }
}
