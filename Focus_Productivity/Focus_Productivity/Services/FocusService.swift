//
//  FocusServiceProtocol.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import Foundation

protocol FocusServiceProtocol {
    func startSession(mode: FocusMode)
    func stopSession()
    func getCurrentSession() -> FocusSession?
    func saveSession()
}

final class FocusService: FocusServiceProtocol {
    
    static let shared = FocusService()

    private var session: FocusSession?

    func startSession(mode: FocusMode) {
        session = FocusSession(id: UUID(), mode: mode, startTime: Date(), endTime: nil, pointsEarned: 0, badgesEarned: [])
    }

    func stopSession() {
        session?.endTime = Date()
    }

    func getCurrentSession() -> FocusSession? {
        return session
    }

    func saveSession() {
        // TODO: Save to Core Data
    }
}
