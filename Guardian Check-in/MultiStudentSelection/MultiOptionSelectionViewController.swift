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
    var fname:String = ""
    static var comingFromConfirmation = false
    static var staffName:String? = "Noah"
    var studentAPSId = ""
    
    //Use the following three arrays to manage multiple option selections
    var options = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedData = [String]() // This is selected cell data array
    
    //Variable passed from the student selection with array of students
    var studentBucket = [StudentRecord]()
    
    
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
        
        scrollImage.image = UIImage.gifImageWithName("whitedown")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        //Clearing the arrays used for multi-options for each student
        options.removeAll()
        arrSelectedIndex.removeAll()
        arrSelectedData.removeAll()
        collectionView.reloadData()
        
        //Pull first student name and APS id from studentBucket
        fname = studentBucket[0].fname
        studentAPSId = studentBucket[0].id
        print(fname)
        
        //Change label on top of page for staff who is checking student in
        heyLabel.text = "Hey " + fname + "!"
        
        //Adjust welcome message for student and location
        locationLabel.text = "Welcome to the " + CoreDataHelper.locationName + ". Please select your reason(s) for visiting."
        UIView.animate(withDuration: 0.5) {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }
        
        //Location options are stored as string (comma delimited) in Salesforce. Seperated out here to present individually
        for temp in CoreDataHelper.locationOptions.split(separator: ",") {
            options.append(String(temp))
        }
        
        //Determine if collection view needs to be scrollable (more than 4 options for a location)
        if options.count > 4 {
            scrollImage.isHidden = false
            scrollText.isHidden = false
        }
        else {
            scrollImage.isHidden = true
            scrollText.isHidden = true
        }
    }
    
    //Function initiated by pressing checkin button
    @objc func checkIn(){
        
        //API actions to take place if at least one option is selected for the student
        if arrSelectedIndex.count > 0 {
            print("skip animate")
//            UIView.animate(withDuration: 0.5, animations: {
//                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
//            }, completion: { finished in
                let url = URL(string:RestHelper.urls["CheckIn"]!)!
                print(url)
            let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!, "checkinLocation":CoreDataHelper.locationName, "checkinReason":self.arrSelectedData.joined(separator: ", "), "apsStudentId":studentAPSId, "staffMemberName":MultiOptionSelectionViewController.staffName!])
                if jsonString.localizedStandardContains("successfully") {
                    //Check if more students still need to be checked in (studentBucket has 2 or more entries left)
                    if self.studentBucket.count > 1 {
                        
                        print("more students left")
                        //Removes student from studentBucket array to shift next students into first position and reload screen
                        studentBucket.removeFirst(1)
                        self.viewWillAppear(true) //reload screen
                    //Complete checkin and move to confirmation screen if no more students left to checkin
                    } else {
                        self.performSegue(withIdentifier: "showEnding", sender: self)
                    }
                    
                }
                //Error handling if the checkin api does not connect
                else {
                    AlertViewController.msg = "There was an error when trying to complete the check-in. Please try again."
                    AlertViewController.img = "error"
                    let storyboard = UIStoryboard(name: "Alert", bundle: nil)
                    let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
                    myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(myAlert, animated: true, completion: nil)
                }
        // If no options were selected throws an alert error that user needs to select at least one option for the student
        } else {
            let optionsAlert = UIAlertController(title: "Error", message: "Please select your reason(s) for visitng us today!", preferredStyle: .alert)
            optionsAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(optionsAlert, animated: true)
        }
        
    }
    
}

//Following extensions are all used for Collection View (which displays the location options)
extension MultiOptionSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as! MultiOptionCollectionCell
        
        cell.layer.cornerRadius = 10
        cell.layer.shouldRasterize = false
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor
        
        cell.textLabel.text = options[indexPath.row]
        
        //Shades option background when selected so there is visual indicator it's been selected
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

//Following extension manages main layout views and format for collection view
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

//Following extension is used to manage the arrays that keep track of selected options and refreshes when options are deselected
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
