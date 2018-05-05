
// Abstract: UI Actions for the main view controller.

import UIKit
import SceneKit

extension MainVC: UIGestureRecognizerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
        case showSettings
        case showLogin
        case showAccount
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
    
    // Open Login
    @IBAction func showLoginVC() {
        if AuthService.instance.isLoggedIn {
            performSegue(withIdentifier: SegueIdentifier.showAccount.rawValue, sender: loginButton)
        } else {
            performSegue(withIdentifier: SegueIdentifier.showLogin.rawValue, sender: loginButton)
        }
    }
    
    // Change Image of Login Button if user is logged in
    @objc func loadUserProfileImage(_ notif: Notification) {
        if AuthService.instance.isLoggedIn {
            loginButton.setTitle(nil, for: .normal)
            loginButton.setImage(UserDataService.instance.profileImage, for: .normal)
            
            loginButton.setImage(UserDataService.instance.profileImage, for: .normal)
            loginButton.setTitle(UserDataService.instance.givenName, for: .normal)
        } else {
            loginButton.setImage(nil, for: .normal)
            loginButton.setTitle("Log In", for: .normal)
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
        
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier), segueIdentifer == .showObjects else { return }
        
        let objectsTableVC = segue.destination as! VirtualObjectSelectionVC
        // Load objects to objectsTableVC
        objectsTableVC.virtualObjects = virtualObjects
        objectsTableVC.delegate = self
        
        // Link to VirtualObjectSelectionVC
		self.objectsTableVC = objectsTableVC
        
        // Set all rows of currently placed objects to selected.
        for object in virtualObjectLoader.loadedObjects {
            guard let index = VirtualObject.availableObjects.index(of: object) else { continue }
            // objectsTableVC.selectedVirtualObjectRows.insert(index)
        }
    }
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		objectsTableVC = nil
	}
}
