//
//  EndingViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class EndingViewController : UIViewController {
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var thankyouLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        mainCardView.layer.cornerRadius = 10
        mainCardView.layer.shouldRasterize = false
        mainCardView.layer.borderWidth = 1
        
        mainCardView.layer.shadowRadius = 10
        mainCardView.layer.shadowColor = UIColor.black.cgColor
        mainCardView.layer.shadowOpacity = 1
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        //Setup starting position for card
        mainCardView.center.x = mainCardView.center.x + self.view.bounds.width
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        thankyouLabel.text = "Thank you for visiting the " + CoreDataHelper.locationName + "."
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }, completion: { finished in
            UIView.animate(withDuration: 0.5, delay: 5.0, animations: {
                self.mainCardView.center.y = self.mainCardView.center.y + self.view.bounds.height
                }, completion: { finished in
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SearchStudentViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: false)
                            break
                        }
                    }
            })
        })
    }
    
}
