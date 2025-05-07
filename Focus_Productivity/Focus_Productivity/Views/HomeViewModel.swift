//
//  HomeViewModel.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import Foundation
import CoreData
import UIKit

protocol HomeViewDelegate: AnyObject {
    func updateTimerLabel(timeString: String)
    func displayBadge(badge: String)
    func showError(message: String)
    func updatePointsAndBadge()
    func updateUIForActiveSession()
}

class HomeViewModel {
    weak var viewDelegate: HomeViewDelegate?
    
    var currentSession: Session?
    var timer: Timer?
    var timeInSeconds: Int = 0
    
    //Badges
     let treeBadges = ["🌳","🌲","🌴","🌱","🌿"]
     let leafFungiBadges = ["🍄", "🍁", "🍂"]
     let animalBadges = ["🐶", "🐱", "🐻", "🐼"]
    
    var selectedMode: FocusMode = .work
    
    enum FocusMode: String, CaseIterable {
        case work = "Work"
        case play = "Play"
        case rest = "Rest"
        case sleep = "Sleep"
        
        var timerInterval: TimeInterval {
            switch self {
            case .work, .play, .rest, .sleep:
                return 1.0 // Update timer every second.
            }
        }
    }
    
    init(delegate: HomeViewDelegate) {
        self.viewDelegate = delegate
    }
    
    //Get user data
     func getUser(context: NSManagedObjectContext) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
     //save user data
     func saveUser(name: String, image: UIImage, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try context.fetch(fetchRequest)
            if let existingUser = users.first {
                // Update existing user
                existingUser.name = name
                existingUser.image = image.jpegData(compressionQuality: 1.0)
            } else {
                // Create a new user
                let newUser = User(context: context)
                newUser.name = name
                newUser.image = image.jpegData(compressionQuality: 1.0)
            }
            try context.save()
        } catch {
            print("Error saving user: \(error)")
            viewDelegate?.showError(message: "Failed to save user data.") // Inform the view
        }
    }
    
    // Function to start the timer
    func startTimer(context: NSManagedObjectContext) {
        guard timer == nil else { return } // Prevent multiple timers
        
        //Check for existing session
         if currentSession == nil {
            startNewSession(context: context)
         }
        
        timer = Timer.scheduledTimer(timeInterval: selectedMode.timerInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // Function to stop the timer
    func stopTimer(context: NSManagedObjectContext) {
        timer?.invalidate()
        timer = nil
        if let session = currentSession {
            session.endTime = Date()
            session.duration = Int32(timeInSeconds)
            do {
                try context.save()
                
            } catch {
                print("Error saving session: \(error)")
                viewDelegate?.showError(message: "Failed to save session data.")
            }
            currentSession = nil // Clear the current session
        }
        timeInSeconds = 0
        viewDelegate?.updateTimerLabel(timeString: "00:00") //reset the timer label
    }
    
     // Function to start new session and store it in core data
    private func startNewSession(context: NSManagedObjectContext) {
        let newSession = Session(context: context)
        newSession.id = UUID()
        newSession.mode = selectedMode.rawValue
        newSession.startTime = Date()
        newSession.endTime = nil
        newSession.duration = 0
        newSession.points = 0
        
        currentSession = newSession
        
        do {
            try context.save()
        } catch {
            print("Error saving new session: \(error)")
            viewDelegate?.showError(message: "Failed to start new session.")
        }
    }
    
    // Timer update function
     @objc func updateTimer() {
        timeInSeconds += 1
        let timeString = formatTime(seconds: timeInSeconds)
        viewDelegate?.updateTimerLabel(timeString: timeString)
        
        if timeInSeconds % 120 == 0 { // Every 2 minutes (120 seconds)
            viewDelegate?.updatePointsAndBadge()
        }
    }
    
     // Function to update points and badge
    func updatePointsAndBadge(context: NSManagedObjectContext) {
         if let session = currentSession {
            session.points += 1
            do{
                 try context.save()
            } catch {
                 print("Error saving points: \(error)")
                 viewDelegate?.showError(message: "Failed to save points.")
            }
            let badge = getRandomBadge()
            viewDelegate?.displayBadge(badge: badge)
        }
    }
    
    // Function to format time
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
    
     // Function to get random badge
     func getRandomBadge() -> String {
        let badgeType = Int.random(in: 0..<3)
        switch badgeType {
        case 0:
            return treeBadges.randomElement() ?? ""
        case 1:
            return leafFungiBadges.randomElement() ?? ""
        case 2:
            return animalBadges.randomElement() ?? ""
        default:
            return ""
        }
    }
    
     // MARK: - Load Session Data
       func loadCurrentSession(context: NSManagedObjectContext) {
           let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
           let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false) // Get most recent
           fetchRequest.sortDescriptors = [sortDescriptor]
           fetchRequest.fetchLimit = 1
           
           do {
               let sessions = try context.fetch(fetchRequest)
               if let session = sessions.first, session.endTime == nil { // Check if it's an active session
                   currentSession = session
                   selectedMode = FocusMode(rawValue: session.mode ?? "Work") ?? .work //default value
                   
                   // Calculate the time elapsed since the session started.
                   let startTime = session.startTime ?? Date()
                   timeInSeconds = Int(Date().timeIntervalSince(startTime))
                   
                   let timeString = formatTime(seconds: timeInSeconds)
                   viewDelegate?.updateTimerLabel(timeString: timeString)
                   viewDelegate?.updateUIForActiveSession() //update the ui
                   
                   startTimer(context: context) //restart the timer.
                   
               }
           } catch {
               print("Error loading session: \(error)")
               viewDelegate?.showError(message: "Failed to load saved session.")
           }
       }
    
}
