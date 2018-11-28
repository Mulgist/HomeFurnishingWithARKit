//
//  CircleImage.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 8..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}
