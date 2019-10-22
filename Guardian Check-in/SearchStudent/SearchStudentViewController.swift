//
//  SearchStudentViewController.swift
//  GuardianApp
//
//  Created by Alexander Stevens on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit
import CoreData

class SearchStudentViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var searchController: UISearchController?
    var filteredTableData = [String]()
    var listOfNames = [String]()
    var searchActive = false
    var swipeCount = 0
    
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        swipeCount = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDummyData()
        tableView.register(SearchStudentResultCell.self, forCellReuseIdentifier: "result")
        
        let rotate = UIRotationGestureRecognizer(target: self, action:     #selector(rotatedView(_:)))
        self.view.addGestureRecognizer(rotate)
        
    }
    
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        print(sender.rotation)
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
                cell.backgroundColor = .blue
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
