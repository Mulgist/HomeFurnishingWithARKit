//
//  UserDataService.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

class UserDataService {
    static let instance = UserDataService()
    
    public private(set) var id: String = ""
    public private(set) var email: String = ""
    public private(set) var familyName: String = ""
    public private(set) var givenName: String = ""
    public private(set) var fullName: String = ""
    public private(set) var provider: String = ""
    public private(set) var profileImage: UIImage = UIImage(named: DEFAULT_PROFILE_IMAGE_NAME)!
    
    func setUserData(id: String, email: String, familyName: String, givenName: String, fullName: String, provider: String, profileImage: UIImage = UIImage(named: DEFAULT_PROFILE_IMAGE_NAME)!) {
        self.id = id
        self.email = email
        self.familyName = familyName
        self.givenName = givenName
        self.fullName = fullName
        self.provider = provider
        self.profileImage = profileImage
    }
    
    func editUserData(familyName: String, givenName: String, fullName: String) {
        self.familyName = familyName
        self.givenName = givenName
        self.fullName = fullName
    }
    
    func logoutUser() {
        id = ""
        email = ""
        familyName = ""
        givenName = ""
        fullName = ""
        provider = ""
        profileImage = UIImage(named: DEFAULT_PROFILE_IMAGE_NAME)!
        AuthService.instance.userId = "userId"
        // Log out completed
        AuthService.instance.isLoggedIn = false
        NotificationCenter.default.post(name: NOTIF_USER_DATA_LOADED, object: nil)
    }
}
