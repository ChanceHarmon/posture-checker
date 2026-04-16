//
//  PostureCheckerApp.swift
//  PostureChecker
//
//  Created by Chance Harmon on 4/16/26.
//

import SwiftUI
import AppKit
import UserNotifications

@main
struct PostureCheckerApp: App {
    @State private var isRunning: Bool = false
    @State private var selectedInterval: Int = 15
    @State private var timer: Timer?
    
    init(){
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if granted {
                print("Permission granted.")
            } else {
                print("Permission denied.")
            }
        }
    }

    func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Posture Check"
        content.body = "Check your knee position."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func startTimer() {
        isRunning = true
        timer?.invalidate()
        timer = nil
        var testInterval = 0.0
        if selectedInterval == 15{
            testInterval = 3.0
        }
        if selectedInterval == 20{
            testInterval = 5.0
        }
        timer = Timer.scheduledTimer(withTimeInterval: testInterval, repeats: true) { _ in
            sendNotification()
        }
    }
    
    func stopTimer(){
        isRunning = false
        timer?.invalidate()
        timer = nil
        print("Timer stopped")
    }
    
    var body: some Scene {
        MenuBarExtra("PostureChecker", systemImage: "figure.walk") {
            Text(isRunning ? "Status: Running" : "Status: Stopped")
            Divider()
            Button("Start"){
                startTimer()
            }
            Button("Stop"){
                stopTimer()
            }
            Divider()
            Button(action: {
                selectedInterval = 15
                if isRunning {
                    startTimer()
                }
            }){
                HStack {
                    Text("15 mins")
                    if selectedInterval == 15 {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: {
                selectedInterval = 20
                if isRunning {
                    startTimer()
                }
            }){
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
