//
//  AlertHandler.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 13.03.2021.
//

import UIKit

struct AlertHandler {
    
    static var shared = AlertHandler()
    var alertController = UIAlertController()
    let progressBar = UIProgressView(progressViewStyle: .bar)
    
    mutating func showErrorMessage(_ message: String) {
        alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        var rootViewController = UIApplication.shared.windows[0].rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    mutating func showLoadingMessage(_ message: String) {
        alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        var rootViewController = UIApplication.shared.windows[0].rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    mutating func downloadSongProgress() {
        alertController = UIAlertController(title: "Downloading...", message: nil, preferredStyle: .alert)
        var rootViewController = UIApplication.shared.windows[0].rootViewController
        progressBar.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        alertController.view.addSubview(progressBar)
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
