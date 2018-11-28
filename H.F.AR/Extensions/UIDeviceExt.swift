//
//  UIDeviceExt.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

extension UIDevice {
    public var isiPhone: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            return true
        }
        return false
    }
    public var isiPad: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return true
        }
        return false
    }
}
