
// Abstract: ARSCNViewDelegate interactions for `ViewController`.

import ARKit

extension MainVC: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.virtualObjectInteraction.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare()
        }
		
		// If the object selection menu is open, update availability of items
		if objectsTableVC != nil {
			let planeAnchor = focusSquare.currentPlaneAnchor
			objectsTableVC?.updateObjectAvailability(for: planeAnchor)
		}
		
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        let baseIntensity: CGFloat = 40
        let lightingEnvironment = sceneView.scene.lightingEnvironment
        if let lightEstimate = session.currentFrame?.lightEstimate {
            lightingEnvironment.intensity = lightEstimate.ambientIntensity / baseIntensity
        } else {
            lightingEnvironment.intensity = baseIntensity
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.statusViewController.cancelScheduledMessage(for: .planeEstimation)
            self.statusViewController.showMessage("SURFACE DETECTED".localized(using: "MainVCStrings"))
            if self.virtualObjectLoader.loadedObjects.isEmpty {
                self.statusViewController.scheduleMessage("TAP + TO PLACE AN OBJECT".localized(using: "MainVCStrings"), inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        updateQueue.async {
            for object in self.virtualObjectLoader.loadedObjects {
                object.adjustOntoPlaneAnchor(planeAnchor, using: node)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateQueue.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                for object in self.virtualObjectLoader.loadedObjects {
                    object.adjustOntoPlaneAnchor(planeAnchor, using: node)
                }
            } else {
                if let objectAtAnchor = self.virtualObjectLoader.loadedObjects.first(where: { $0.anchor == anchor }) {
                    objectAtAnchor.simdPosition = anchor.transform.translation
                    objectAtAnchor.anchor = anchor
                }
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
			
			// Unhide content after successful relocalization.
			virtualObjectLoader.loadedObjects.forEach { $0.isHidden = false }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.".localized(using: "MainVCStrings"), message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
		// Hide content before going into the background.
		virtualObjectLoader.loadedObjects.forEach { $0.isHidden = true }
    }
	
	func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
         // Allow the session to attempt to resume after an interruption. This process may not succeed, so the app must be prepared to reset the session if the relocalizing status continues for a long time -- see 'escalateFeedback' in 'StatusVC'.
		return true
	}
}
