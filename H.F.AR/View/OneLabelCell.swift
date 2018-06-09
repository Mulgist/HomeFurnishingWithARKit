//
//  OneLableCell.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 6. 9..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class OneLabelCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var nameLbl: UILabel!
    
    var data: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(data: String) {
        self.data = data
        nameLbl.text = data
    }
}
