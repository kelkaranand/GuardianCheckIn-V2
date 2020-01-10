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
    @IBOutlet weak var logoImage: UIImageView!
    var moved = false
    var easterEgg = false
    
    
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
        self.mainCard.isHidden = true
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
        
        //Tap gesture for check-in button
        checkInButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInPressed)))
        
        //Swipe right to flip back card
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(flipBack))
        rightSwipe.direction = .right
        mainCard.addGestureRecognizer(rightSwipe)
        
        //Easter egg gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showLebron))
        longPress.minimumPressDuration = 5
        logoImage.addGestureRecognizer(longPress)
    
    }
    
    @objc func showLebron() {
        if(!easterEgg)
        {
            easterEgg = true
            UIView.transition(with: logoImage, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
                self.logoImage.alpha = 0
            }, completion: { finished in
                self.logoImage.image = UIImage.gifImageWithURL("https://media0.giphy.com/media/Y506ebOM2Zd4llHv43/source.gif")
                self.logoImage.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.logoImage.alpha = 0
                    }, completion: { finished in
                        self.logoImage.image = UIImage.init(named: "LJFF_logo")
                        self.logoImage.alpha = 1
                    })
                }
            })
        }
    }
    
    @objc func checkInPressed() {
        self.mainCard.isHidden = false
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
            self.mainCard.isHidden = true
        })
        print("flip")
    }
    
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

//Do not touch anything below this line!!!

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
//        var delay = 0.05
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        var delay = delayObject as! Double
        
//        if delay < 0.1 {
//            delay = 0.1
//        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}
