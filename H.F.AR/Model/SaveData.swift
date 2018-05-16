//
//  SaveData.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 10..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class SaveData {
    let id: String
    let name: String
    var contentString: String
    
    init(_ id: String, _ name: String, _ contentString: String) {
        self.id = id
        self.name = name
        self.contentString = contentString
    }
}
