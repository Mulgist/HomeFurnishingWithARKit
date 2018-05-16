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
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var widthLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var depthLbl: UILabel!
    @IBOutlet weak var productPageLbl: UILabel!
    @IBOutlet weak var pageLinkBtn: UIButton!
    @IBOutlet weak var pageWarningLbl: UILabel!
    @IBOutlet weak var noticeLbl: UILabel!
    
    var selectedObject: VirtualObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manufacturerLogoImage.image = UIImage(named: "IKEA_logo_white_background")
        sizeLbl.text = "Size (approximate)".localized(using: "MainStrings")
        productPageLbl.text = "Product Page".localized(using: "MainStrings")
        pageWarningLbl.text = "(Warning: After viewing the website, this app will try to recover the AR session.)".localized(using: "MainStrings")
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
            
            // To get the real bounding box size, it have to do a max - min calculation. The depth (actual height) is y in .scn itself.
            let boundingBox = SCNVector3Make(object.boundingBox.max.x - object.boundingBox.min.x, object.boundingBox.max.y - object.boundingBox.min.y, object.boundingBox.max.z - object.boundingBox.min.z)
            
            let width = (boundingBox.x * 100).roundToPlaces(1) // x
            let height = (boundingBox.z * 100).roundToPlaces(1) // z
            let depth = (boundingBox.y * 100).roundToPlaces(1) // y
            
            widthLbl.text = "\("width".localized(using: "MainStrings")): \(width)cm"
            heightLbl.text = "\("height".localized(using: "MainStrings")): \(height)cm"
            depthLbl.text = "\("depth".localized(using: "MainStrings")): \(depth)cm"
            
            if productId == "" {
                pageLinkBtn.setTitle("This product is not currently available for sale.".localized(using: "MainStrings"), for: .normal)
            } else {
                pageLinkBtn.setTitle("\(IKEA_KOREA_BASE_URL)\(Localize.currentLanguage())/\(IKEA_PRODUCT_PREFIX)\(productId)", for: .normal)
            }
        } else {
            // originally without the selectedObject, the button itself should not be present.
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
        
        let boundingBox = SCNVector3Make(newObject.boundingBox.max.x - newObject.boundingBox.min.x, newObject.boundingBox.max.y - newObject.boundingBox.min.y, newObject.boundingBox.max.z - newObject.boundingBox.min.z)
        let multiple = getScaleMultipleValue(box: boundingBox)
        
        camera.position.y = boundingBox.y * multiple * 0.7
        newObject.position = SCNVector3Make(0, 0, 0)
        newObject.scale = SCNVector3Make(multiple, multiple, multiple)
        
        let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:CGFloat(0.02 * Float.pi) , z: 0, duration: 0.1))
        newObject.runAction(rotate)
        scene.rootNode.addChildNode(newObject)
    }
    
    func getScaleMultipleValue(box: SCNVector3) -> Float {
        let stdLength: Float = 4
        let maxValue = max(box.x, box.y, box.z)
        let multiple = stdLength / maxValue
        
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
