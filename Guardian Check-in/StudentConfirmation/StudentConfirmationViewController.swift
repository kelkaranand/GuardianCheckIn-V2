//
//  StudentConfirmationViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 12/01/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class StudentConfirmationViewController : UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var studentLabel: UILabel!
    @IBOutlet weak var staffMemberTextBox: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func buttonPressed(_ sender: UIButton) {
        OptionSelectionViewController.studentCheckIn = true
        OptionSelectionViewController.staffName = staffMemberTextBox.text!
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
        }, completion: { finished in
            self.performSegue(withIdentifier: "showOptions", sender: self)
        })
    }
    
    static var back = false;
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        
        doneButton.layer.cornerRadius = 10
        doneButton.layer.shouldRasterize = false
        doneButton.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        //Setup starting position for card
        cardView.center.x = cardView.center.x + self.view.bounds.width
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if (!StudentConfirmationViewController.back) {
            StudentConfirmationViewController.back = true
            UIView.animate(withDuration: 0.5) {
                self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
            }
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
            }
            StudentConfirmationViewController.back = false
        }
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
        }, completion: { finished in
            self.navigationController?.popViewController(animated: false)
        })
    }
    
}
