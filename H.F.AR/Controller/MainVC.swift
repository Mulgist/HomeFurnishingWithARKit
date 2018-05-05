
// Abstract: Main view controller for the AR experience.

import ARKit
import SceneKit
import UIKit
import Alamofire
import SwiftyJSON
import Localize_Swift

class MainVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var sceneView: VirtualObjectARView!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var loginButton: CircleButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var virtualObjects = [VirtualObject]()
    var productIds = [String]()
    var asciiObjectNames = [String]()
    var enObjectNames = [String]()
    var koObjectNames = [String]()
    
    // MARK: - UI Elements
    var focusSquare = FocusSquare()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusVC = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusVC }).first!
    }()
	
	/// The view controller that displays the virtual object selection menu.
	var objectsTableVC: VirtualObjectSelectionVC?
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        virtualObjects = VirtualObject.availableObjects

        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)

        // The 'sceneView.automaticallyUpdatesLighting' option creates an ambient light source and modulates its intensity. This sample app instead modulates a global lighting environment map for use with physically based materials, so disable automatic lighting.
        sceneView.automaticallyUpdatesLighting = false
        // sceneView.autoenablesDefaultLighting = true
        if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
        }

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        let showObjectsTapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        showObjectsTapGesture.delegate = self
        sceneView.addGestureRecognizer(showObjectsTapGesture)
        
        let showSettingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(showSettingVC))
        showSettingsTapGesture.delegate = self
        settingsButton.addGestureRecognizer(showSettingsTapGesture)
        
        let showLoginTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLoginVC))
        showLoginTapGesture.delegate = self
        loginButton.addGestureRecognizer(showLoginTapGesture)
        
        // Register Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserProfileImage(_:)), name: NOTIF_USER_DATA_LOADED, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setInfoAndRemoveButon(_:)), name: NOTIF_SET_INFO_RM_BUTTON, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setInfoAndRemoveButon(_:)), name: NOTIF_UNSET_INFO_RM_BUTTON, object: nil)
        
        // Set objects array
        setupObjectArray()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		// UIApplication.shared.isIdleTimerDisabled = true

        // Start the 'ARSession'.
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        
        session.pause()
	}
    
    func setupObjectArray() {
        // Web Request
        Alamofire.request("\(BASE_URL)\(REQUEST_SUFFIX)method=\(GET_OBJECTS)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                let json = JSON(data)
                var jsonElement: JSON
                self.productIds.removeAll()
                self.asciiObjectNames.removeAll()
                self.enObjectNames.removeAll()
                self.koObjectNames.removeAll()
                
                for i in 0..<json.count {
                    jsonElement = json[i]
                    self.productIds.append(jsonElement["product_id"].stringValue)
                    self.asciiObjectNames.append(jsonElement["ascii"].stringValue)
                    self.enObjectNames.append(jsonElement["en"].stringValue)
                    self.koObjectNames.append(jsonElement["ko"].stringValue)
                    // print("KO Name: \(String(describing: self.koObjectNames.last))")
                }
                for element in self.virtualObjects {
                    if let index = self.asciiObjectNames.index(of: element.modelName) {
                        element.setNames(self.enObjectNames[index], self.koObjectNames[index])
                    }
                }
            }
        }
    }
    
    @IBAction func showObjectInfo(_ sender: Any) {
        guard let productInfoVC = storyboard?.instantiateViewController(withIdentifier: "ProductInfoVC") else { return }
        productInfoVC.modalPresentationStyle = .custom
        presentDetial(productInfoVC)
    }
    
    @IBAction func removeObject(_ sender: Any) {
        if let selected = virtualObjectInteraction.selectedObject {
            if let index = virtualObjectLoader.loadedObjects.index(of: selected) {
                virtualObjectLoader.removeVirtualObject(at: index)
                NotificationCenter.default.post(name: NOTIF_UNSET_INFO_RM_BUTTON, object: nil)
            }
        }
    }

    // MARK: - Scene content setup

    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }

        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }

    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
	func resetTracking() {
		virtualObjectInteraction.selectedObject = nil
		
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isAutoFocusEnabled = true
        // configuration.isLightEstimationEnabled = true
		session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT".localized(using: "MainStrings"), inSeconds: 7.5, messageType: .planeEstimation)
	}

    // MARK: - Focus Square

	func updateFocusSquare() {
        let isObjectVisible = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT".localized(using: "MainStrings"), inSeconds: 5.0, messageType: .focusSquare)
        }
		
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
            addObjectButton.isHidden = false
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addObjectButton.isHidden = true
        }
	}
    
	// MARK: - Error handling
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session".localized(using: "MainStrings"), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}
