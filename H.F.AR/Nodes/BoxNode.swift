//
//  BoxNode.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 9..
//  Copyright © 2018년 Apple. All rights reserved.
//

import SceneKit

class BoxNode: SCNNode {
    init(position: SCNVector3, length: CGFloat) {
        super.init()
        let boxGeometry = SCNBox(width: 0.01, height: 0.01, length: length, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        material.lightingModel = .physicallyBased
        boxGeometry.materials = [material]
        self.geometry = boxGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
