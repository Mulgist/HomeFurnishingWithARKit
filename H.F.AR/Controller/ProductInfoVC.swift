//
//  ProductInfoVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 27..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import SceneKit
import Localize_Swift

class ProductInfoVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var manufacturerLogoImage: UIImageView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPageLbl: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var pageLinkBtn: UIButton!
    @IBOutlet weak var noticeLbl: UILabel!
    
    var selectedObject: VirtualObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manufacturerLogoImage.image = UIImage(named: "IKEA_logo_white_background")
        productPageLbl.text = "Product Page".localized(using: "MainStrings")
        noticeLbl.text = "The shape and color of the item on the product page may differ from the above 3D model.".localized(using: "MainStrings")
        
        let previousVC = self.presentingViewController as! MainVC
        selectedObject = previousVC.virtualObjectInteraction.selectedObject
        
        if let object = selectedObject {
            var productId = ""
            
            loadObject(object)
            
            if let index = previousVC.asciiObjectNames.index(of: object.modelName) {
                productId = previousVC.productIds[index]
            }
            productNameLbl.text = object.getLocalizedName()
            
            if productId == "" {
                pageLinkBtn.setTitle("This product is not currently available for sale.".localized(using: "MainStrings"), for: .normal)
            } else {
                pageLinkBtn.setTitle("\(IKEA_KOREA_BASE_URL)\(Localize.currentLanguage())/\(IKEA_PRODUCT_PREFIX)\(productId)", for: .normal)
            }
        } else {
            // 원래 selectedObject가 없으면 버튼 자체가 있으면 안된다.
            fatalError("Object Load Error!")
        }
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    func loadObject(_ object: VirtualObject) {
        let scene = SCNScene(named: "Models.scnassets/background.scn")!
        sceneView.scene = scene
        
        let camera = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        // Duplicate object
        let newObject = VirtualObject(url: object.referenceURL)!
        newObject.reset()
        newObject.load()
        
        // 진짜 bounding box 크기를 구하려면 max - min 계산을 해야 한다. scn 자체로는 depth(실제 높이)가 y이다.
        let boundingBox = SCNVector3Make(newObject.boundingBox.max.x - newObject.boundingBox.min.x, newObject.boundingBox.max.y - newObject.boundingBox.min.y, newObject.boundingBox.max.z - newObject.boundingBox.min.z)
        let multiple = getScaleMultipleValue(box: boundingBox)
        // print(multiple)
        
        camera.position.y = boundingBox.y * 8
        
        newObject.position = SCNVector3Make(0, 0, 0)
        newObject.scale = SCNVector3Make(multiple, multiple, multiple)
        
        let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:CGFloat(0.02 * Float.pi) , z: 0, duration: 0.1))
        newObject.runAction(rotate)
        scene.rootNode.addChildNode(newObject)
    }
    
    func getScaleMultipleValue(box: SCNVector3) -> Float {
        let stdLength: Float = 4
        
        // print("bounding x, y, z: \(box.x), \(box.y), \(box.z)")
        
        let maxValue = max(box.x, box.y, box.z)
        let multiple = stdLength / maxValue
        
        // print("maxValue: \(multiple)")
        
        return multiple
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        dismissDetail()
    }
    
    @IBAction func pageLinkBtnPressed(_ sender: Any) {
        if pageLinkBtn.title(for: .normal)!.range(of: "http") != nil {
            UIApplication.shared.open(URL(string : pageLinkBtn.title(for: .normal)!)!, options: [:], completionHandler: { (status) in })
        } else {
            UIApplication.shared.open(URL(string : "\(IKEA_KOREA_BASE_URL)\(Localize.currentLanguage())/")!, options: [:], completionHandler: { (status) in })
        }
    }
}
