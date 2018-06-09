//
//  SavesListVC.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 5. 10..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit
import SceneKit
import Localize_Swift
import Alamofire
import SwiftyJSON
import ARKit

class SavesListVC: UIViewController {
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var anchorView: UIView!
    
    enum SegueIdentifier: String {
        case showDataDetail
    }
    
    weak var delegate: SavesListVCDelegate?
    var loadedObjects: [VirtualObject]?
    var savesList = [SaveData]()
    var selectedIndexforDetail: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadedObjects = delegate?.savesListVC(self, getLoadedVirtualObjects: true)
        loadSaveList()
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
        let alertController = UIAlertController(title: "SAVE THE STATUS".localized(), message: "Edit the title.".localized(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.keyboardType = .default
            textField.text = currentDateTime
            textField.borderStyle = .none
            textField.backgroundColor = .clear
        }

        // |  OK  | Cancel |
        let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in
            let name = alertController.textFields![0].text!
            self.saveData(currentDateTime, name)
        }
        alertController.addAction(OKAction)

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { action in }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
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
                self.tableView.reloadData()
            }
        }
    }
    
    func saveData(_ date: String, _ name: String) {
        let dataString = serializeVirtualObjects()
        
        let body: [String:Any] = [
            "method": SAVE_DATA,
            "who": AuthService.instance.userId,
            "date": date,
            "name": name,
            "data": dataString
        ]
        
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)", method: .post, parameters: body, encoding: URLEncoding.default, headers: URL_ENCODE_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                var json = JSON(data)
                json = json[0]
                
                if json["result"].stringValue == "success" {
                    let alertController = UIAlertController(title: "SAVE SUCCEED".localized(), message: "The status has been successfully saved.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in self.loadSaveList() }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "SAVE FAILED".localized(), message: "The state saving failed for some reason. Please try again.".localized(), preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK".localized(), style: .default) { action in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
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
                let newPosition = SCNVector3Make(originalPosition.x - currentCameraPosition.x, originalPosition.y - currentCameraPosition.y, originalPosition.z - currentCameraPosition.z)
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
    
    func deserializeDataString(_ data: String) -> ([VirtualObject], [SCNVector3], [Float]) {
        var objects = [VirtualObject]()
        var objectPositions = [SCNVector3]()
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
            guard let index = modelNames.index(of: components[0]) else { return (objects, objectPositions, objectRotations) }
            guard let addedObject = VirtualObject(url: mainObjects[index].referenceURL) else { return (objects, objectPositions, objectRotations) }
            
            // position (calculated)
            let positions = components[1].components(separatedBy: ",")
            let savedX = Float(positions[0])!
            let savedY = Float(positions[1])!
            let savedZ = Float(positions[2])!
            let currentCameraPosition = delegate!.savesListVC(self, getCurrentSession: true).currentFrame!.camera.transform.translation
            let newPosition = SCNVector3Make(savedX + currentCameraPosition.x, savedY + currentCameraPosition.y, savedZ + currentCameraPosition.z)
            addedObject.position = newPosition
            // addedObject.position = SCNVector3Make(savedX, savedY, savedZ)
            
            objectPositions.append(newPosition)
            // objectRotation
            objectRotations.append(Float(components[2])!)
            objects.append(addedObject)
        }
        return (objects, objectPositions, objectRotations)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedDataCell") as? OneLabelCell else { return UITableViewCell() }
        let saveData = savesList[indexPath.row]
        cell.configureCell(data: saveData.name)
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
        let positions = deserializeResult.1
        let rotations = deserializeResult.2
        
        delegate?.savesListVC(self, loadObjects: objects, objectPositions: positions, objectRotations: rotations)
        
        dismiss(animated: true, completion: nil)
    }
    
    // When the information button on the right of the item is pressed
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedIndexforDetail = indexPath.row
        performSegue(withIdentifier: SegueIdentifier.showDataDetail.rawValue, sender: anchorView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showDataDetail.rawValue {
            if let vc = segue.destination as? SaveDataInfoVC {
                if let index = selectedIndexforDetail {
                    // for UIPopoverArrowDirection
                    vc.popoverPresentationController!.delegate = self
                    vc.delegate = self
                    vc.delegate2 = delegate as? SaveDataInfoVCDelegate2
                    vc.saveData = savesList[index]
                }
            }
        }
    }
}

extension SavesListVC: SaveDataInfoVCDelegate, UIPopoverPresentationControllerDelegate {
    func saveDataInfoVC(_ infoVC: SaveDataInfoVC, deserializeData: String) -> [VirtualObject] {
        return deserializeDataString(deserializeData).0
    }
    
    func saveDataInfoVC(_ infoVC: SaveDataInfoVC, reloadTableData: Bool) {
        loadSaveList()
    }
    
    // When the device is iPad, the popover arrow direction is left and when the device is iPhone, the popover arrow direction is down.
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if UIDevice.current.isiPad {
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.left
        } else if UIDevice.current.isiPhone {
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.down
        }
    }
}

protocol SavesListVCDelegate: class {
    func savesListVC(_ listVC: SavesListVC, loadObjects: [VirtualObject], objectPositions: [SCNVector3], objectRotations: [Float])
    func savesListVC(_ listVC: SavesListVC, getCurrentSession: Bool) -> ARSession
    func savesListVC(_ listVC: SavesListVC, getLoadedVirtualObjects: Bool) -> [VirtualObject]
    func savesListVC(_ listVC: SavesListVC, getVirtualObjects: Bool) -> [VirtualObject]
}
