//
//  OptionSelectionViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class OptionSelectionViewController : UIViewController {
    
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var heyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var options = [String]()
    static var fname:String = ""
    static var comingFromConfirmation = false
    static var staffName: String?
    static var familyMemberId = ""
    static var studentAPSId = ""
    static var studentCheckIn = false
    
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
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if (OptionSelectionViewController.staffName == "" || OptionSelectionViewController.staffName == nil) {
            heyLabel.text = "Hey " + OptionSelectionViewController.fname + "!"
        }
        else {
            heyLabel.text = "Hey " + OptionSelectionViewController.staffName! + "!"
        }
        
        locationLabel.text = "Welcome to the " + CoreDataHelper.locationName + ". Please select your reason for visiting."
        UIView.animate(withDuration: 0.5) {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }
        for temp in CoreDataHelper.locationOptions.split(separator: ",") {
            options.append(String(temp))
        }
    }
    
    @objc func goBack() {
        if !OptionSelectionViewController.comingFromConfirmation {
            UIView.animate(withDuration: 0.5, animations: {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }, completion: { finished in
                StudentGuardianSelectionViewController.back = true
                StudentConfirmationViewController.back = true
                self.navigationController?.popViewController(animated: false)
            })
        }
    }
    
}

extension OptionSelectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as! OptionCollectionCell
        
        cell.layer.cornerRadius = 10
        cell.layer.shouldRasterize = false
        cell.layer.borderWidth = 2
        cell.backgroundColor = UIColor.clear
        cell.layer.borderColor = UIColor.white.cgColor
        
        cell.textLabel.text = options[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
}

extension OptionSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 20
        return CGSize(width: (self.collectionView.frame.width / 2) - 20, height: (self.collectionView.frame.height / 2) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension OptionSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }, completion: { finished in
            let url = URL(string:RestHelper.urls["CheckIn"]!)!
            print(url)
            if OptionSelectionViewController.studentCheckIn {
                OptionSelectionViewController.studentCheckIn = false
                let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!, "checkinLocation":CoreDataHelper.locationName, "checkinReason":self.options[indexPath.row], "apsStudentId":OptionSelectionViewController.studentAPSId, "staffMemberName":OptionSelectionViewController.staffName!])
                if jsonString.localizedStandardContains("successfully") {
                    self.performSegue(withIdentifier: "showEnding", sender: self)
                }
                else {
                    AlertViewController.msg = "There was an error when trying to complete the check-in. Please try again."
                    AlertViewController.img = "error"
                    let storyboard = UIStoryboard(name: "Alert", bundle: nil)
                    let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
                    myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(myAlert, animated: true, completion: nil)
                }
            }
            else {
                let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!, "checkinLocation":CoreDataHelper.locationName, "checkinReason":self.options[indexPath.row], "familyMemberId":OptionSelectionViewController.familyMemberId])
                if jsonString.localizedStandardContains("successfully") {
                    self.performSegue(withIdentifier: "showEnding", sender: self)
                }
                else {
                    AlertViewController.msg = "There was an error when trying to complete the check-in. Please try again."
                    AlertViewController.img = "error"
                    let storyboard = UIStoryboard(name: "Alert", bundle: nil)
                    let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
                    myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(myAlert, animated: true, completion: nil)
                }
            }
        })
    }
}

