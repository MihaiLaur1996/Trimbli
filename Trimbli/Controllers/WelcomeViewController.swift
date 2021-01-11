//
//  WelcomeViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 04/10/2020.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var libraryContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchContainer.isHidden = true
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            searchContainer.isHidden = false
//            libraryContainer.isHidden = true
//        case 1:
//            searchContainer.isHidden = true
//            libraryContainer.isHidden = false
//        default:
//            print("Error")
//        }
    }
}
