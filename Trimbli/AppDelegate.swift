//
//  AppDelegate.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 04/10/2020.
//

import UIKit
import Firebase
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        FirebaseApp.configure()
        clearCache()
        return true
    }
    
    func clearCache() {
        let fileManager = FileManager.default
        do {
            let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for url in fileURLs {
               try fileManager.removeItem(at: url)
            }
        } catch {
            let errorMessage = "There was a problem at removing cache data. Please try again."
            AlertHandler.shared.showErrorMessage(errorMessage)
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
