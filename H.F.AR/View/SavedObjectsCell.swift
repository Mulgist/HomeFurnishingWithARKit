//
//  SavedObjectsCell.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 19..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class SavedObjectsCell: UITableViewCell {
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
