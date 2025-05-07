//
//  ProfileViewModel.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//
import Foundation
import CoreData

protocol ProfileViewDelegate: AnyObject {
    func showError(message: String)
}

class ProfileViewModel {
    weak var viewDelegate: ProfileViewDelegate?
    // Removed the managed object context from here.
    
    init(delegate: ProfileViewDelegate) {
        self.viewDelegate = delegate
    }
    
     func getUser(context: NSManagedObjectContext) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            viewDelegate?.showError(message: "Failed to load user data.")
            return nil
        }
    }
    
     func fetchRecentSessions(context: NSManagedObjectContext) -> [Session] {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Fetch only the last 10 sessions.
        fetchRequest.fetchLimit = 10
        
        do {
            let sessions = try context.fetch(fetchRequest)
            return sessions
        } catch {
            print("Error fetching sessions: \(error)")
            viewDelegate?.showError(message: "Failed to load session history.")
            return []
        }
    }
    
    //Get total points
     func getTotalPoints(context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        
        do {
            let sessions = try context.fetch(fetchRequest)
            let totalPoints = sessions.reduce(0) { sum, session -> Int in
                return sum + Int(session.points)
            }
            return totalPoints
        } catch {
            print("Error fetching sessions for total points: \(error)")
            viewDelegate?.showError(message: "Failed to calculate total points.")
            return 0
        }
    }
    
     // Function to get all unique badges from sessions
     func getAllBadges(context: NSManagedObjectContext) -> [String] {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        
        do {
            let sessions = try context.fetch(fetchRequest)
            var uniqueBadges = Set<String>()
            for session in sessions {
                if let badge = session.badge {
                    uniqueBadges.insert(badge)
                }
            }
            return Array(uniqueBadges)
        } catch {
            print("Error fetching sessions for badges: \(error)")
            viewDelegate?.showError(message: "Failed to load badges.")
            return []
        }
    }
    
}

