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
    var filteredTableData = [String]()
    var listOfNames = [String]()
    var searchActive = false
    var swipeCount = 0
    @IBOutlet weak var lockBack: UIImageView!
    @IBOutlet weak var lockFront: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    var lastRotation:CGFloat = 0
    var rotation:CGFloat = 0
    var counter = 0
    
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var verificationLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        swipeCount = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDummyData()
        tableView.register(SearchStudentResultCell.self, forCellReuseIdentifier: "result")
        
        //Tap on screen to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //Hide Lock
        lockFront.isHidden = true
        lockBack.isHidden = true
        verificationLabel.isHidden = true
        
        //Longpress to show lock
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showLock))
        longPressGesture.minimumPressDuration = 5.0
        self.view.addGestureRecognizer(longPressGesture)
        
        //Rotation gesture for the lock
        let rotateLock = UIRotationGestureRecognizer(target: self, action: #selector(rotateLock(_:)))
        self.view.addGestureRecognizer(rotateLock)
    }
 
    @objc func showLock() {
        if(lockFront.isHidden){
            toggleLockDisplay()
            verificationLabel.isHidden = false
        }
    }
    
    func toggleLockDisplay() {
        if(lockFront.isHidden) {
            lockFront.isHidden = false
            lockBack.isHidden = false
        }
        else {
            lockFront.isHidden = true
            lockBack.isHidden = true
        }
    }
    
    @objc func rotateLock(_ sender: UIRotationGestureRecognizer) {
        counter = counter + 1
        if(sender.state == .began){
            rotation = rotation + lastRotation
        } else if(sender.state == .changed){
            let newRotation = sender.rotation + rotation
            self.lockFront.transform = CGAffineTransform(rotationAngle: newRotation)
            if (counter > 10){
                AudioServicesPlaySystemSoundWithCompletion(1157,nil)
                counter = 0
            }
        } else if(sender.state == .ended) {
            lastRotation = sender.rotation
            verificationLabel.text = String(getLockValue(lockRotation: rotation+lastRotation))
        }
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    func getLockValue(lockRotation:CGFloat) -> Int {
        var deg = rad2deg(Double(lockRotation))
        deg = deg.truncatingRemainder(dividingBy: 360)
        var integer = Int(deg/3.6)
        print(integer)
        if(integer < 0){
            integer = integer * -1
        }
        else if(integer > 0) {
            integer = 100 - integer
        }
        return integer
    }
    
    @objc func showSetup() {
        swipeCount = swipeCount + 1
        if(swipeCount == 3){
        self.performSegue(withIdentifier: "showSetup", sender: self)
        }
    }
    
    private func fetchDummyData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")

        do {
            let results = try context.fetch(fetchRequest)
            let students = results as! [Student]

            for student in students {
                listOfNames.append(student.name ?? "")
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

extension SearchStudentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? SearchStudentResultCell {
//                cell.backgroundColor = .blue
            cell.nameLabel.text = filteredTableData[indexPath.row]
            return cell
        }
        
        return UITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return filteredTableData.count
        } else {
            return 0
        }
    }
}

extension SearchStudentViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("started")
        searchActive = true
        centerConstraint.constant = -100
        //self.searchBar.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("done")
        searchActive = false
        centerConstraint.constant = 0
        //self.searchBar.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100).isActive = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
              filteredTableData.removeAll(keepingCapacity: false)
              guard let text = searchBar.text else { return }
              let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
        
              guard let unwrappedListOfNames = listOfNames as? NSArray else { return }
              let array = (unwrappedListOfNames).filtered(using: searchPredicate)
              filteredTableData = array as! [String]
              tableView.reloadData()
    }

    
}

extension SearchStudentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "StudentGuardianSelection", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "studentGuardianSelection")
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
