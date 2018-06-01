//
//  SaveDataInfoVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 15..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SaveDataInfoVC: UIViewController {
    // Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var saveData: SaveData?
    var savedObjects = [VirtualObject]()
    var originalTitle: String?
    weak var delegate: SaveDataInfoVCDelegate?
    weak var delegate2: SaveDataInfoVCDelegate2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = saveData {
            savedObjects = (delegate?.saveDataInfoVC(self, deserializeData: data.contentString))!
            delegate2?.saveDataInfoVC(self, pureVirtualObjects: savedObjects)
            self.nameField.text = data.name
            originalTitle = data.name
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let title = originalTitle {
            if nameField.text != title {
                let body: [String:Any] = [
                    "method": EDIT_SAVE_DATA_TITLE,
                    "data_id": saveData!.id,
                    "newtitle": nameField.text!,
                ]
                
                // Web Request
                Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)", method: .post, parameters: body, encoding: URLEncoding.default, headers: URL_ENCODE_HEADER).responseJSON { (response) in
                    if response.result.error == nil {
                        guard let data = response.data else { return }
                        var json = JSON(data)
                        json = json[0]
                        
                        if json["result"].stringValue == "success" {
                            self.delegate?.saveDataInfoVC(self, reloadTableData: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func saveAndBackBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SaveDataInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedObjectsCell") as? SavedObjectsCell else { return UITableViewCell() }
        let object = savedObjects[indexPath.row]
        cell.configureCell(data: object.getLocalizedName())
        return cell
    }
}

protocol SaveDataInfoVCDelegate: class {
    func saveDataInfoVC(_ infoVC: SaveDataInfoVC, deserializeData: String) -> [VirtualObject]
    func saveDataInfoVC(_ infoVC: SaveDataInfoVC, reloadTableData: Bool)
}

protocol SaveDataInfoVCDelegate2: class {
    func saveDataInfoVC(_ infoVC: SaveDataInfoVC, pureVirtualObjects: [VirtualObject])
}
