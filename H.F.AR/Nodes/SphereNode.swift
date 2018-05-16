//
//  SphereNode.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 9..
//  Copyright © 2018년 Apple. All rights reserved.
//

import SceneKit

class SphereNode: SCNNode {
    init(position: SCNVector3) {
        super.init()
        let sphereGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
