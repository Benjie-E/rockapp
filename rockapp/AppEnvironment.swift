//
//  Environment.swift
//  rockapp
//
//  Created by Benjie on 2/13/25.
//

import Foundation

public enum AppEnvironment {
    enum Keys {
        static let baseUrl = "BASE_URL"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let baseURL: String = {
        guard let baseURLString = AppEnvironment.infoDictionary[Keys.baseUrl] as? String else {
            fatalError("Base URL not set in plist")
        }
        return baseURLString
    }()
}
