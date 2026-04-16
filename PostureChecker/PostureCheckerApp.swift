//
//  PostureCheckerApp.swift
//  PostureChecker
//
//  Created by Chance Harmon on 4/16/26.
//

import SwiftUI
import AppKit

@main
struct PostureCheckerApp: App {
    var body: some Scene {
        MenuBarExtra("PostureChecker", systemImage: "figure.walk") {
            Text("Posture Reminders")
            Divider()
            Button("Quit"){
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
