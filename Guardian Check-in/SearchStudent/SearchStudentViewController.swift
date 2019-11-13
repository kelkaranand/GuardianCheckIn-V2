//
//  SearchStudentViewController.swift
//  GuardianApp
//
//  Created by Alexander Stevens on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox
import AVFoundation

class SearchStudentViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var searchController: UISearchController?
    var selectedStudent = StudentRecord()
    static var studentRecords = [StudentRecord]()
    var filteredStudentrecords = [StudentRecord]()
    var searchActive = false
    @IBOutlet weak var mainCard: UIView!
    @IBOutlet weak var checkInCard: UIView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkInButtonView: UIView!
    @IBOutlet weak var superView: UIView!
    var moved = false
    
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    
    override func viewDidLayoutSubviews() {
        mainCard.layer.cornerRadius = 10
        mainCard.layer.shouldRasterize = false
        mainCard.layer.borderWidth = 1
        
        mainCard.layer.shadowRadius = 10
        mainCard.layer.shadowColor = UIColor.black.cgColor
        mainCard.layer.shadowOpacity = 1
        
        superView.layer.cornerRadius = 10
        superView.layer.shouldRasterize = false
        
        checkInCard.layer.cornerRadius = 10
        checkInCard.layer.shouldRasterize = false
        checkInCard.layer.borderWidth = 1
        
        checkInCard.layer.shadowRadius = 10
        checkInCard.layer.shadowColor = UIColor.black.cgColor
        checkInCard.layer.shadowOpacity = 1
        
        checkInButtonView.layer.cornerRadius = 10
        checkInButtonView.layer.shouldRasterize = false
        checkInButtonView.layer.borderWidth = 2
        checkInButtonView.backgroundColor = UIColor.lightGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if CoreDataHelper.locationName == "" {
            self.performSegue(withIdentifier: "showSetup", sender: self)
        }
        else {
            checkInLabel.text = "Welcome to the " + CoreDataHelper.locationName + ". Press the button below to check-in."
            self.mainCard.alpha = 0
            self.checkInCard.alpha = 1
            self.view.alpha = 1
            moved = false
            tableView.isHidden = true
            searchBar.text = nil
            UIView.animate(withDuration: 0.5) {
                self.superView.center.y = self.superView.center.y - self.view.bounds.height
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchStudentResultCell.self, forCellReuseIdentifier: "result")
        self.navigationController?.navigationBar.isHidden = true
        
        //Tap on screen to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        mainCard.backgroundColor = UIColor(white: 1.0, alpha: 1)
        
        //Setup starting position for card
        mainCard.center.y = mainCard.center.y + self.view.bounds.height
        
        //Rotation gesture to show setup
//        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(showSetup(_:)))
//        self.view.addGestureRecognizer(rotateGesture)
        
        //Tap gesture for check-in button
        checkInCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInPressed)))
        
        //Swipe right to flip back card
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(flipBack))
        rightSwipe.direction = .right
        mainCard.addGestureRecognizer(rightSwipe)
    
    }
    
    @objc func checkInPressed() {
        UIView.transition(with: checkInCard, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], animations: {
            self.checkInCard.alpha = 0
        }, completion: { finished in
            
        })
        UIView.transition(with: mainCard, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], animations: {
            self.mainCard.alpha = 1
        }, completion: { finished in
            
        })
        print("Check")
    }
    
    @objc func flipBack() {
        UIView.transition(with: mainCard, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
            self.mainCard.alpha = 0
        }, completion: { finished in
            
        })
        UIView.transition(with: checkInCard, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
            self.checkInCard.alpha = 1
        }, completion: { finished in
            
        })
        print("flip")
    }
 
//    @objc func showSetup(_ sender: UIRotationGestureRecognizer) {
//        if rad2deg(Double(sender.rotation)) > 120 {
//            if !moved {
//                moved = true
//                moveToSetup()
//            }
//        }
//    }
    
    func moveToSetup(){
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }, completion: { finished in
            self.performSegue(withIdentifier: "showSetup", sender: self)
        })
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
}

extension SearchStudentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? SearchStudentResultCell {
//                cell.backgroundColor = .blue
            let fragFname = filteredStudentrecords[indexPath.row].fname
            let fragLname = filteredStudentrecords[indexPath.row].lname
            cell.nameLabel.text = fragFname + " " + fragLname
            return cell
        }
        
        return UITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return filteredStudentrecords.count
        } else {
            return 0
        }
    }
}

extension SearchStudentViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("started")
        searchActive = true
//        centerConstraint.constant = -100
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("done")
        searchActive = false
        if (searchBar.text?.isEmpty)! {
            tableView.isHidden = true
        }
//        centerConstraint.constant = 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        
        if searchText == "Password" {
            self.mainCard.endEditing(true)
            moveToSetup()
        }
            filteredStudentrecords.removeAll(keepingCapacity: false)
              guard let text = searchBar.text else { return }
              let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
        
        filteredStudentrecords = SearchStudentViewController.studentRecords.filter({( student : StudentRecord) -> Bool in
            let name = student.fname + " " + student.lname
            return (name.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "guardianSelection" {
            StudentGuardianSelectionViewController.student = selectedStudent
        }
    }

    
}

extension SearchStudentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStudent = filteredStudentrecords[indexPath.row]
        UIView.animate(withDuration: 0.5, animations: {
            self.superView.center.x = self.superView.center.x - self.view.bounds.width
        }, completion: { finished in
            if CoreDataHelper.locationGuardianFlag {
                self.performSegue(withIdentifier: "guardianSelection", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "showEnd", sender: self)
            }
        })
    }
}
