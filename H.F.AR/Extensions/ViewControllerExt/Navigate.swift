//
//  Navigate.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 4. 7..
//  Copyright © 2018년 Apple. All rights reserved.
//

import UIKit

extension UIViewController {
    // Move screen to double dismiss
    func presentSecondDetail(_ viewControllerToPresent: UIViewController) {
        // The presentedViewController is the view controller that called by self VC.
        guard let presentedViewController = presentedViewController else { return }
        presentedViewController.dismiss(animated: false) {
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
    
    // Animation behavior when screen is dismissed
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        // If animated is not set to false, it will work as the default animation.
        dismiss(animated: false, completion: nil)
    }
    
    func presentDetial(_ vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        present(vc, animated: false, completion: nil)
    }
    
    // Double dismiss
    func doubleDismiss() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        guard let doublePresentingVC = self.presentingViewController?.presentingViewController else { return }
        doublePresentingVC.dismiss(animated: false, completion: nil)
    }
}

