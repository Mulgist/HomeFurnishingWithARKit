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
            if let index = previousVC.asciiObjectNames.index(of: object.modelName) {
                productId = previousVC.productIds[index]
            }
            productNameLbl.text = object.localizedName[Localize.currentLanguage()]
            if productNameLbl.text == "" {
                productNameLbl.text = object.localizedName["en"]
            }
            
            if productId == "" {
                pageLinkBtn.setTitle("This product is not currently available for sale.".localized(using: "MainStrings"), for: .normal)
            } else {
                pageLinkBtn.setTitle("\(IKEA_KOREA_BASE_URL)\(Localize.currentLanguage())/\(IKEA_PRODUCT_PREFIX)\(productId)", for: .normal)
            }
        } else {
            // 원래 selectedObject가 없으면 버튼 자체가 나오면 안된다.
            fatalError("Object Load Error!")
        }
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
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
