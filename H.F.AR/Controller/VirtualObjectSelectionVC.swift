
// Abstract: Popover view controller for choosing virtual objects to place in the AR scene.

import UIKit
import ARKit
import Localize_Swift


// MARK: - VirtualObjectSelectionVC
// A custom table view controller to allow users to select 'VirtualObject's for placement in the scene.
class VirtualObjectSelectionVC: UITableViewController {
    // The collection of 'VirtualObject's to select from.
    var virtualObjects = [VirtualObject]()
	
	// The rows of the 'VirtualObject's that are currently allowed to be placed.
	var enabledVirtualObjectRows = Set<Int>()
    
    weak var delegate: VirtualObjectSelectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
	func updateObjectAvailability(for planeAnchor: ARPlaneAnchor?) {
		var newEnabledVirtualObjectRows = Set<Int>()
        for (row, object) in VirtualObject.availableObjects.enumerated() {
			// Enable row if item can be placed at the current location
			if object.isPlacementValid(on: planeAnchor) {
				newEnabledVirtualObjectRows.insert(row)
			}
		}
		
		// Only reload changed rows
		let changedRows = newEnabledVirtualObjectRows.symmetricDifference(enabledVirtualObjectRows)
		enabledVirtualObjectRows = newEnabledVirtualObjectRows
        let indexPaths = changedRows.map { row in IndexPath(row: row, section: 0) }

		DispatchQueue.main.async {
			self.tableView.reloadRows(at: indexPaths, with: .automatic)
		}
	}
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }
		
        // let object = virtualObjects[indexPath.row]
        let object = VirtualObject(url: virtualObjects[indexPath.row].referenceURL)!
        
        // VirtualObject가 새로 생성되었으니 name도 다시 넣어준다.
        object.setNames(virtualObjects[indexPath.row].localizedName["en"]!, virtualObjects[indexPath.row].localizedName["ko"]!)
        
        delegate?.virtualObjectSelectionVC(self, didSelectObject: object)
        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    // Cell configuration
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected '\(ObjectCell.self)' type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        // At this time, the text and image of the cell are set.
        cell.modelName = virtualObjects[indexPath.row].getLocalizedName()
        
		let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
		if cellIsEnabled {
            cell.vibrancyView.alpha = 1.0
        } else {
			cell.vibrancyView.alpha = 0.1
		}
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }

        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }

        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
}

// MARK: - VirtualObjectSelectionVCDelegate
protocol VirtualObjectSelectionVCDelegate: class {
    func virtualObjectSelectionVC(_ selectionVC: VirtualObjectSelectionVC, didSelectObject: VirtualObject)
}
