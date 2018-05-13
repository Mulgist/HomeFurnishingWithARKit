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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: SaveData) {
        self.data = data
        
        nameLbl.text = data.name
    }

}
