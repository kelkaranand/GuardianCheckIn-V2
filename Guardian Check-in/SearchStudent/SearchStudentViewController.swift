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
//    var filteredTableData = [String]()
//    static var listOfNames = [String]()
    var selectedStudent = StudentRecord()
    static var studentRecords = [StudentRecord]()
    var filteredStudentrecords = [StudentRecord]()
    var searchActive = false
    @IBOutlet weak var mainCard: UIView!
    
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    
    override func viewDidLayoutSubviews() {
        mainCard.layer.cornerRadius = 10
        mainCard.layer.shouldRasterize = false
        mainCard.layer.borderWidth = 2
        
        mainCard.layer.shadowRadius = 10
        mainCard.layer.shadowColor = UIColor.black.cgColor
        mainCard.layer.shadowOpacity = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tableView.isHidden = true
        UIView.animate(withDuration: 1) {
            self.mainCard.center.y = self.mainCard.center.y - self.view.bounds.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchStudentResultCell.self, forCellReuseIdentifier: "result")
        
        //Tap on screen to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        mainCard.backgroundColor = UIColor(white: 1.0, alpha: 1)
        
        //Setup starting position for card
        mainCard.center.y = mainCard.center.y + self.view.bounds.height
    
    }
 
    @objc func showSetup() {
        
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
            filteredStudentrecords.removeAll(keepingCapacity: false)
              guard let text = searchBar.text else { return }
              let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
        
//        guard let unwrappedListOfNames = SearchStudentViewController.listOfNames as? NSArray else { return }
//              let array = (unwrappedListOfNames).filtered(using: searchPredicate)
//              filteredTableData = array as! [String]
//              tableView.reloadData()
        
        filteredStudentrecords = SearchStudentViewController.studentRecords.filter({( student : StudentRecord) -> Bool in
            let name = student.fname + " " + student.lname
            return (name.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "guardianSelection" {
            let dest = segue.destination as? StudentGuardianSelectionViewController
            dest?.student = selectedStudent
        }
    }

    
}

extension SearchStudentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStudent = filteredStudentrecords[indexPath.row]
        UIView.animate(withDuration: 1, animations: {
            self.mainCard.center.y = self.mainCard.center.y + self.view.bounds.height
        }, completion: { finished in
            self.performSegue(withIdentifier: "guardianSelection", sender: self)
        })
    }
}
