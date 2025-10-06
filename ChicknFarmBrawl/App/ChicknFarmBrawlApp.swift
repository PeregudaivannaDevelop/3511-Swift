//
//  ChicknFarmBrawlApp.swift
//  ChicknFarmBrawl
//
//  Created by Serhii Babchuk on 30.09.2025.
//

import SwiftUI

@main
struct ChicknFarmBrawlApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppEntryPoint()
        }
    }
}
