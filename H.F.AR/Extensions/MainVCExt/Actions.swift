
// Abstract: UI Actions for the main view controller.

import UIKit
import SceneKit

extension MainVC: UIGestureRecognizerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
        case showSettings
        case showLogin
        case showAccount
        case showSaves
    }
    
    // MARK: - Interface Actions
    // Displays the 'VirtualObjectSelectionVC' from the 'addObjectButton' or in response to a tap gesture in the 'sceneView'.
    @IBAction func showVirtualObjectSelectionViewController() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !addObjectButton.isHidden && !virtualObjectLoader.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: addObjectButton)
    }
    
    // Determines if the tap gesture for presenting the 'VirtualObjectSelectionVC' should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectLoader.loadedObjects.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        virtualObjectLoader.removeAllVirtualObjects()
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        resetTracking()
        
        // Remove object information and delete buttons
        NotificationCenter.default.post(name: NOTIF_UNSET_INFO_RM_BUTTON, object: nil)
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    // Open Setting
    @IBAction func showSettingVC() {
        performSegue(withIdentifier: SegueIdentifier.showSettings.rawValue, sender: settingsButton)
    }
    
    // Save the Screenshot
    @IBAction func saveScreenshot() {
        let image = sceneView.snapshot()
        ARSnapshotsPhotoAlbumService.instance.saveImage(image: image)
    }
    
    // Open Login
    @IBAction func showLoginVC() {
        if AuthService.instance.isLoggedIn {
            performSegue(withIdentifier: SegueIdentifier.showAccount.rawValue, sender: loginButton)
        } else {
            performSegue(withIdentifier: SegueIdentifier.showLogin.rawValue, sender: loginButton)
        }
    }
    
    // Open saves list
    @IBAction func showSavesList() {
        performSegue(withIdentifier: SegueIdentifier.showSaves.rawValue, sender: savesButton)
    }
    
    // Open object info page
    @IBAction func showObjectInfo(_ sender: Any) {
        guard let productInfoVC = storyboard?.instantiateViewController(withIdentifier: "ProductInfoVC") else { return }
        productInfoVC.modalPresentationStyle = .custom
        presentDetial(productInfoVC)
    }
    
    // Remove selected object
    @IBAction func removeObject(_ sender: Any) {
        if let selected = virtualObjectInteraction.selectedObject {
            if let index = virtualObjectLoader.loadedObjects.index(of: selected) {
                virtualObjectLoader.removeVirtualObject(at: index)
                NotificationCenter.default.post(name: NOTIF_UNSET_INFO_RM_BUTTON, object: nil)
            }
        }
    }
    
    // For Debuging
    @IBAction func savesButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NOTIF_SHOW_SAVES, object: nil)
    }
    
    // Change Image of Login Button if user is logged in
    @objc func loadUserProfileImage(_ notif: Notification) {
        if AuthService.instance.isLoggedIn {
            loginButton.setTitle(nil, for: .normal)
            loginButton.setImage(UserDataService.instance.profileImage, for: .normal)
            loginButton.setTitle(UserDataService.instance.givenName, for: .normal)
            
            // Show savesButton
            savesButton.isHidden = false
        } else {
            loginButton.setImage(nil, for: .normal)
            loginButton.setTitle("Log In", for: .normal)
            
            // Hide savesButtone
            savesButton.isHidden = true
        }
    }
    
    // Set or Unset infoButton and removeButton
    @objc func setInfoAndRemoveButon(_ notif: Notification) {
        if notif.name == NOTIF_SET_INFO_RM_BUTTON {
            infoButton.isHidden = false
            removeButton.isHidden = false
        } else if notif.name == NOTIF_UNSET_INFO_RM_BUTTON {
            infoButton.isHidden = true
            removeButton.isHidden = true
        }
    }
    
    @objc func showMessage(_ notif: Notification) {
        let text = notif.object as! String
        self.statusViewController.showMessage(text)
    }
    
    // Codes for debuging
    @objc func printSaves(_ notif: Notification) {
        let list = virtualObjectLoader.loadedObjects
        for element in list {
            print(element.modelName)
            //print("\(element.anchor!.transform.columns.0.w), \(element.anchor!.transform.columns.0.x), \(element.anchor!.transform.columns.0.y), \(element.anchor!.transform.columns.0.z)")
            //print("\(element.anchor!.transform.columns.1.w), \(element.anchor!.transform.columns.1.x), \(element.anchor!.transform.columns.1.y), \(element.anchor!.transform.columns.1.z)")
            //print("\(element.anchor!.transform.columns.2.w), \(element.anchor!.transform.columns.2.x), \(element.anchor!.transform.columns.2.y), \(element.anchor!.transform.columns.2.z)")
            //print("\(element.anchor!.transform.columns.3.w), \(element.anchor!.transform.columns.3.x), \(element.anchor!.transform.columns.3.y), \(element.anchor!.transform.columns.3.z)")
            
            // print position
            print("position: \(element.position.x), \(element.position.y), \(element.position.z)")
            // print("eulerAngles: \(element.eulerAngles.x), \(element.eulerAngles.y), \(element.eulerAngles.z)")
        }
        print("current camera: \(session.currentFrame!.camera.transform.translation.x), \(session.currentFrame!.camera.transform.translation.y), \(session.currentFrame!.camera.transform.translation.z)")
        // 원점에 상자 추가
        // let box = BoxNode(position: SCNVector3Make(0.0, 0.0, 0.0), length: 0.01)
        // sceneView.scene.rootNode.addChildNode(box)
    }
}

extension MainVC: UIPopoverPresentationControllerDelegate {
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // All menus should be popovers (even on iPhone).
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        if segue.identifier == SegueIdentifier.showSaves.rawValue {
            if let vc = segue.destination as? SavesListVC {
                vc.delegate = self
            }
        }
        
        if let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier), segueIdentifer == .showObjects {
            // Load objects to objectsTableVC
            let objectsTableVC = segue.destination as! VirtualObjectSelectionVC
            objectsTableVC.virtualObjects = virtualObjects
            objectsTableVC.delegate = self
            
            // Link to VirtualObjectSelectionVC
            self.objectsTableVC = objectsTableVC
        }
    }
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		objectsTableVC = nil
	}
}
