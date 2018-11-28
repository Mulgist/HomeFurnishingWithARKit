//
//  ShadowAndRadiusView.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 5..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowAndRadiusView: UIView {
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    func setupView() {
        // View Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        
        // View Radius
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
}
