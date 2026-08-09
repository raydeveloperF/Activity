//
//  ActivityApp.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/14.
//

import SwiftUI
import SwiftData

@main
struct ActivityApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    
    @State var activityViewModel = ActivityViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ContentView()
            .environment(activityViewModel)
    }
}
