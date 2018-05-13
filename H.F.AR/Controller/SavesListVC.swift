//
//  SavesListVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 10..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire
import SwiftyJSON
import ARKit

class SavesListVC: UIViewController {
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SavesListVCDelegate?
    var loadedObjects: [VirtualObject]?
    var savesList = [SaveData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadSaveList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // tableView.reloadData()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let currentDateTime = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day)) \(String(format: "%02d", hour)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        
        // Alert Popup (Edit name)
        let alertController = UIAlertController(title: "SAVE THE STATUS", message: "Edit the name.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.keyboardType = .default
            textField.text = currentDateTime
            textField.borderStyle = .none
            textField.backgroundColor = .clear
        }

        // | OK |  Cancel  |
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            let name = alertController.textFields![0].text!
            self.saveData(currentDateTime, name)
        }
        alertController.addAction(OKAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            // ...
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func loadSaveList() {
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)?method=\(GET_USER_SAVES)&who=\(AuthService.instance.userId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: JSON_ENCODE_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                let json = JSON(data)
                var jsonElement: JSON
                
                self.savesList.removeAll()
                
                for i in 0..<json.count {
                    jsonElement = json[i]
                    
                    let data = SaveData(jsonElement["id"].stringValue, jsonElement["name"].stringValue, jsonElement["content"].stringValue)
                    self.savesList.append(data)
                }
                print("load succeed")
                self.tableView.reloadData()
            }
        }
    }
    
    func saveData(_ date: String, _ name: String) {
        let dataString = serializeVirtualObjects()
        
        // print("\(BASE_URL)\(REQUEST_SUFFIX)?method=\(SAVE_DATA)&who=\(AuthService.instance.userId)&date=\(date)&name=\(name)&data=\(dataString)")
        
        let body: [String:Any] = [
            "method": SAVE_DATA,
            "who": AuthService.instance.userId,
            "date": date,
            "name": name,
            "data": dataString
        ]
        
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)", method: .post, parameters: body, encoding: URLEncoding.default, headers: URL_ENCODE_HEADER).responseJSON { (response) in
            print(response.result.error?.localizedDescription ?? "none error")
            //print(response.response)
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
            if response.result.error == nil {
                guard let data = response.data else { return }
                var json = JSON(data)
                json = json[0]
                
                if json["result"].stringValue == "success" {
                    let alertController = UIAlertController(title: "SAVE SUCCEED", message: "The status has been successfully saved.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in self.loadSaveList() }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) { /* ... */ }
                } else {
                    let alertController = UIAlertController(title: "SAVE FAILED", message: "The state saving failed for some reason. Please try again.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in /* ... */ }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) { /* ... */ }
                }
            }
        }
    }
    
    func serializeVirtualObjects() -> String {
        var dataString = ""
        if let objects = loadedObjects {
            for object in objects {
                // modelName (ascii)
                dataString += object.modelName
                dataString += "^"
                // position (calculated)
                let originalPosition = object.position
                let currentCameraPosition = delegate!.savesListVC(self, getCurrentSession: true).currentFrame!.camera.transform.translation
                let newPosition = SCNVector3Make(originalPosition.x + (0.0 - currentCameraPosition.x), originalPosition.y + (0.0 - currentCameraPosition.y), originalPosition.z + (0.0 - currentCameraPosition.z))
                dataString += "\(newPosition.x),\(newPosition.y),\(newPosition.z)"
                dataString += "^"
                // objectRotation
                dataString += "\(object.objectRotation)"
                
                if object != objects.last {
                    dataString += "*"
                }
            }
        }
        return dataString
    }
    
    func deserializeDataString(_ data: String) -> ([VirtualObject], [Float]) {
        var objects = [VirtualObject]()
        var objectRotations = [Float]()
        let mainObjects = delegate!.savesListVC(self, getVirtualObjects: true)
        let objectStrings = data.components(separatedBy: "*")
        var modelNames = [String]()
        
        for object in mainObjects {
            modelNames.append(object.modelName)
        }
        
        for eachString in objectStrings {
            // 0: modelName (ascii), 1: position (calculated), 2: objectRotation
            let components = eachString.components(separatedBy: "^")
            
            // modelName (ascii)
            guard let index = modelNames.index(of: components[0]) else { return (objects, objectRotations) }
            guard let addedObject = VirtualObject(url: mainObjects[index].referenceURL) else { return (objects, objectRotations) }
            
            // position (calculated)
            let positions = components[1].components(separatedBy: ",")
            let savedX = Float(positions[0])!
            let savedY = Float(positions[1])!
            let savedZ = Float(positions[2])!
            let currentCameraPosition = delegate!.savesListVC(self, getCurrentSession: true).currentFrame!.camera.transform.translation
            let newPosition = SCNVector3Make(savedX + (0.0 - currentCameraPosition.x), savedY + (0.0 - currentCameraPosition.y), savedZ + (0.0 - currentCameraPosition.z))
            addedObject.position = newPosition
            
            // objectRotation
            objectRotations.append(Float(components[2])!)
            objects.append(addedObject)
        }
        print(objects.count)
        return (objects, objectRotations)
    }
}

extension SavesListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedDataCell") as? SavesListCell else { return UITableViewCell() }
        let saveData = savesList[indexPath.row]
        cell.configureCell(data: saveData)
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSave = savesList[indexPath.row]
        let deserializeResult = deserializeDataString(selectedSave.contentString)
        let objects = deserializeResult.0
        let rotations = deserializeResult.1
        
        delegate?.savesListVC(self, loadObjects: objects, objectRotations: rotations)
        
        dismiss(animated: true, completion: nil)
    }
    
    // 오른쪽에 정보 버튼 눌렀을 때
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("detail 누름")
    }
}

protocol SavesListVCDelegate: class {
    func savesListVC(_ listVC: SavesListVC, loadObjects: [VirtualObject], objectRotations: [Float])
    func savesListVC(_ listVC: SavesListVC, getCurrentSession: Bool) -> ARSession
    func savesListVC(_ listVC: SavesListVC, getVirtualObjects: Bool) -> [VirtualObject]
}
