//
//  MultiOptionSelectionViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class MultiOptionSelectionViewController : UIViewController {
    
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var heyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollImage: UIImageView!
    @IBOutlet weak var scrollText: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    @IBAction func buttonPressed(_ sender: Any) {
        checkIn()
    }
    static var fname:String = ""
    static var comingFromConfirmation = false
    static var staffName:String? = "Noah"
    static var familyMemberId: String?
    static var studentAPSId = ""
    static var studentCheckIn = false
    
    static var locationName = "Loads of Love"
    static var locationOptions = "Laundry, Detergent, Softener, Option 4, Option 5"
    
    var options = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedData = [String]() // This is selected cell data array
    
    var bucket = [["Harry", "Potter", "12345"], ["Hermione", "Granger", "000300019"]]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkInButton.layer.cornerRadius = 10
        checkInButton.layer.shouldRasterize = false
        checkInButton.layer.borderWidth = 2
        checkInButton.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup starting position for card
        mainCardView.center.x = mainCardView.center.x + self.view.bounds.width
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        scrollImage.image = UIImage.gifImageWithName("whitedown")
        
        print(bucket)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        options.removeAll()
        arrSelectedIndex.removeAll()
        arrSelectedData.removeAll()
        collectionView.reloadData()
        
        MultiOptionSelectionViewController.self.fname = bucket[0][0]
        MultiOptionSelectionViewController.self.studentAPSId = bucket[0][2]
        print(MultiOptionSelectionViewController.self.fname)
        
        if (MultiOptionSelectionViewController.staffName == "" || MultiOptionSelectionViewController.staffName == nil) {
            heyLabel.text = "Hey " + MultiOptionSelectionViewController.fname + "!"
        }
        else {
            heyLabel.text = "Hey " + MultiOptionSelectionViewController.staffName! + "!"
        }
        
        locationLabel.text = "Welcome to the " + MultiOptionSelectionViewController.self.locationName + ". Please select your reason for visiting."
//        UIView.animate(withDuration: 0.5) {
//            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
//        }
        for temp in MultiOptionSelectionViewController.self.locationOptions.split(separator: ",") {
            options.append(String(temp))
        }
        if options.count > 4 {
            scrollImage.isHidden = false
            scrollText.isHidden = false
        }
        else {
            scrollImage.isHidden = true
            scrollText.isHidden = true
        }
    }
    
    @objc func goBack() {
        if !MultiOptionSelectionViewController.comingFromConfirmation {
            UIView.animate(withDuration: 0.5, animations: {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }, completion: { finished in
                StudentGuardianSelectionViewController.back = true
                StudentConfirmationViewController.back = true
                self.navigationController?.popViewController(animated: false)
            })
        }
    }
    
    @objc func checkIn(){
        
        if arrSelectedIndex.count > 0 {
            print("skip animate")
//            UIView.animate(withDuration: 0.5, animations: {
//                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
//            }, completion: { finished in
                let url = URL(string:RestHelper.urls["CheckIn"]!)!
                print(url)
                MultiOptionSelectionViewController.studentCheckIn = false
                let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!, "checkinLocation":MultiOptionSelectionViewController.self.locationName, "checkinReason":self.arrSelectedData.joined(separator: ", "), "apsStudentId":MultiOptionSelectionViewController.studentAPSId, "staffMemberName":MultiOptionSelectionViewController.staffName!])
                if jsonString.localizedStandardContains("successfully") {
                    if self.bucket.count > 1 {
                        print("more students left")
//                        self.viewDidLoad()
                        bucket.removeFirst(1)
                        print("bucket")
                        self.viewWillAppear(true)

                    } else {
                        self.performSegue(withIdentifier: "showEnding", sender: self)
                    }
                    
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
//            })
        } else {
            let optionsAlert = UIAlertController(title: "Error", message: "Please select your reason(s) for visitng us today!", preferredStyle: .alert)
            optionsAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(optionsAlert, animated: true)
        }
        
    }
    
}

extension MultiOptionSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as! MultiOptionCollectionCell
        
        cell.layer.cornerRadius = 10
        cell.layer.shouldRasterize = false
        cell.layer.borderWidth = 2
//        cell.backgroundColor = UIColor.clear
        cell.layer.borderColor = UIColor.white.cgColor
        
        cell.textLabel.text = options[indexPath.row]
        
        if arrSelectedIndex.contains(indexPath) { // You need to check wether selected index array contain current index if yes then change the color
            cell.backgroundColor = #colorLiteral(red: 0.9952836633, green: 0.9879123569, blue: 1, alpha: 0.3509022887)
            
        }
        else {
            cell.backgroundColor = UIColor.clear
        }

        cell.layoutSubviews()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}

extension MultiOptionSelectionViewController: UICollectionViewDelegateFlowLayout {
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

extension MultiOptionSelectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("selected")
        let strData = options[indexPath.item]

        if arrSelectedIndex.contains(indexPath) {
            arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
            arrSelectedData = arrSelectedData.filter { $0 != strData}
        }
        else {
            arrSelectedIndex.append(indexPath)
            arrSelectedData.append(strData)
        }

        print(arrSelectedData)
        collectionView.reloadData()
        

    }
 
}
