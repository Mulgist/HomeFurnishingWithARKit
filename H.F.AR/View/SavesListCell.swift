//
//  SavesListCell.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 10..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class SavesListCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var nameLbl: UILabel!
    
    var data: SaveData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(data: SaveData) {
        self.data = data
        nameLbl.text = data.name
    }
}
