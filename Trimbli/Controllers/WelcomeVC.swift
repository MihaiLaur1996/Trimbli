//
//  WelcomeViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 04/10/2020.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var libraryContainer: UIView!
    @IBOutlet weak var emptyContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForListLength()
        let whiteAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let blackAttribute = [NSAttributedString.Key.foregroundColor: UIColor.listColor]
        segmentControl.setTitleTextAttributes(whiteAttribute, for: .normal)
        segmentControl.setTitleTextAttributes(blackAttribute, for: .selected)
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        do {
            try selectContainer(sender)
        } catch {
            AlertHandler.shared.showErrorMessage(error.localizedDescription)
        }
    }
    
    func selectContainer(_ segmentedControl: UISegmentedControl) throws {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            NotificationCenter.default.addObserver(self, selector: #selector(loading), name: .loading, object: nil)
            searchContainer.isHidden = false
            libraryContainer.isHidden = true
            emptyContainer.isHidden = true
        case 1:
            checkForListLength()
        default:
            throw "Error at list selection. The list number does not exist."
        }
    }
    
    @objc func loading() {
        AlertHandler.shared.showLoadingMessage("Loading...")
    }
    
    func checkForListLength() {
        if MediaPlayer.shared.downloadedSongs.isEmpty {
            libraryContainer.isHidden = true
            emptyContainer.isHidden = false
        } else {
            libraryContainer.isHidden = false
            emptyContainer.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .loading, object: nil)
    }
}
