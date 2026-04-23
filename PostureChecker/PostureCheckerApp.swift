//
//  PostureCheckerApp.swift
//  PostureChecker
//
//  Created by Chance Harmon on 4/16/26.
//

import SwiftUI
import AppKit
import UserNotifications
import ServiceManagement

@main
struct PostureCheckerApp: App {
    
    // Tracks whether reminders are currently active.
    // Used for UI state (enabling/disabling Start/Stop) and behavior.
    @State private var isRunning: Bool = false
    
    // Stores the selected reminder interval in minutes.
    // Right now the menu allows 15 or 20.
    @State private var selectedInterval: Int = 15
    
    // Holds a reference to the currently running timer.
    // It is optional because there may be no timer running.
    @State private var timer: Timer?
    
    // Stores the user's "Start at Login" preference.
    // AppStorage persists the value between launches using UserDefaults.
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    
    // Runs when the app launches.
    // We request notification permission up front so the app can send reminders later.
    init() {
        requestNotificationPermission()
    }
    
    
    // Asks macOS for permission to show alerts and play sounds.
    // This only needs to be granted once, but calling it at launch is fine.
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    
    // Creates and sends a notification immediately.
    // This is what the timer calls every time it fires.
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Posture Check"
        content.body = "Check your knee position."
        content.sound = .default
        
        // Using a unique ID means each reminder is treated as a new notification.
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification send error: \(error.localizedDescription)")
            }
        }
    }
    
    
    // Starts or restarts the repeating reminder timer.
    // This function:
    // 1. marks the app as running
    // 2. invalidates any old timer
    // 3. creates a new timer using the selected interval
    func startTimer() {
        isRunning = true
        
        // Prevent duplicate timers if Start is clicked more than once
        // or if the interval changes while already running.
        timer?.invalidate()
        timer = nil
        
        let intervalInSeconds = Double(selectedInterval * 60)
        
        timer = Timer.scheduledTimer(withTimeInterval: intervalInSeconds, repeats: true) { _ in
            sendNotification()
        }
    }
    
    
    // Stops the current timer and resets timer-related state.
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    
    // Registers or unregisters the app as a macOS login item.
    // When enabled, the app launches automatically when the user logs in.
    // When disabled, the app is removed from the login items list.
    func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
                print("Registered for launch at login")
            } else {
                try SMAppService.mainApp.unregister()
                print("Unregistered from launch at login")
            }
        } catch {
            print("Login item error: \(error.localizedDescription)")
        }
    }
    
    
    var body: some Scene {
        MenuBarExtra("PostureChecker", systemImage: "figure.cross.training") {
            
            // Start button begins reminders.
            // Disabled while already running.
            Button("Start") {
                startTimer()
            }
            .disabled(isRunning)
            
            
            // Stop button ends reminders.
            // Disabled while already stopped.
            Button("Stop") {
                stopTimer()
            }
            .disabled(!isRunning)
            
            Divider()
            
            
            // Interval picker controls the reminder interval.
            // The selected value is bound directly to selectedInterval.
            Picker("Interval", selection: $selectedInterval) {
                Text("15 mins").tag(15)
                Text("20 mins").tag(20)
            }
            .onChange(of: selectedInterval) {
                // If the user changes interval while reminders are running,
                // restart the timer so the new interval takes effect immediately.
                if isRunning {
                    startTimer()
                }
            }
            
            Divider()
            
            // Toggle controls whether the app should launch automatically at login.
            // The setting is persisted, and changes are applied through ServiceManagement.
            Toggle("Start at Login", isOn: $launchAtLogin)
            .onChange(of: launchAtLogin) {
                    updateLaunchAtLogin()
            }
            
            Divider()
            
            // Quits the app entirely.
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        
        // Forces the menu bar item to behave like a normal dropdown menu.
        .menuBarExtraStyle(.menu)
    }
}
