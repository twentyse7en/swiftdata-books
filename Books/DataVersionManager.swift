//
//  DataVersionManager.swift
//  Books
//
//  Created by Abijith B on 01/04/25.
//


import Foundation

class DataVersionManager {
    
    /// The resource name of the configuration plist
    private let configResourceName = "Config"
    
    /// The key for the version in the plist file
    private let plistVersionKey = "DataVersion"
    
    /// The key for storing the version in UserDefaults
    private let userDefaultsVersionKey = "dataVersion"
    
    /**
     * Checks if a data update is available by comparing the version in the plist file
     * with the version stored in UserDefaults.
     *
     * @return true if an update is available, false otherwise.
     * If the plist file cannot be read, returns false.
     */
    func isUpdateAvailable() -> Bool {
        guard let plistPath = Bundle.main.path(forResource: configResourceName, ofType: "plist"),
              let plistData = NSDictionary(contentsOfFile: plistPath) else {
            print("Failed to read Config.plist file")
            return false
        }
        
        guard let dataVersion = plistData[plistVersionKey] as? Int else {
            print("Failed to read DataVersion from plist")
            return false
        }
        
        let localVersion = UserDefaults.standard.object(forKey: userDefaultsVersionKey) as? Int ?? 0
        print("LocalVersion \(localVersion)")
        print("Plist version \(dataVersion)")
        
        return localVersion < dataVersion
    }
    
    /**
     * Marks the update as complete by setting the UserDefaults version
     * to match the current plist version.
     *
     * @return true if successfully updated the version, false if plist couldn't be read
     */
    func markUpdateComplete() -> Bool {
        guard let plistPath = Bundle.main.path(forResource: configResourceName, ofType: "plist"),
              let plistData = NSDictionary(contentsOfFile: plistPath),
              let dataVersion = plistData[plistVersionKey] as? Int else {
            print("Failed to read Config.plist file")
            return false
        }
        
        UserDefaults.standard.set(dataVersion, forKey: userDefaultsVersionKey)
        return true
    }
}
