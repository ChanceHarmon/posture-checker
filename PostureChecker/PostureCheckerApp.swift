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
    @State private var isRunning: Bool = false
    @State private var selectedInterval: Int = 15
    var body: some Scene {
        MenuBarExtra("PostureChecker", systemImage: "figure.walk") {
            Text(isRunning ? "Status: Running" : "Status: Stopped")
            Divider()
            Button("Start"){
                isRunning = true
            }
            Button("Stop"){
                isRunning = false
            }
            Divider()
            Button(action: {selectedInterval = 15}){
                HStack {
                    Text("15 mins")
                    if selectedInterval == 15 {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: {selectedInterval = 20}){
                HStack {
                    Text("20 mins")
                    if selectedInterval == 20 {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Divider()
            Button("Quit"){
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
