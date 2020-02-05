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
    @IBOutlet weak var messageLabel: UILabel!
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
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        //Tap on screen to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if (!StudentConfirmationViewController.back) {
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
        studentLabel.text = OptionSelectionViewController.fname
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
        }, completion: { finished in
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.5) {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= self.view.frame.height/2 - 30
                }
                self.studentLabel.frame.origin.y += self.messageLabel.frame.height
                self.messageLabel.isHidden = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.5) {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y = 0
                }
                self.studentLabel.frame.origin.y -= self.messageLabel.frame.height
                self.messageLabel.isHidden = false
            }
        }
    }
    
}
