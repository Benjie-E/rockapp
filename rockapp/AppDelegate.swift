//
//  AppDelegate.swift
//  rockapp
//
//  Created by Benjie on 4/2/25.
//

import Foundation
import UIKit
import Lock
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      return Lock.resumeAuth(url, options: options)
    }
}
