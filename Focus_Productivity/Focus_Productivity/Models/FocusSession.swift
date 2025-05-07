//
//  FocusSession.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import Foundation

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let mode: FocusMode
    let startTime: Date
    var endTime: Date?
    var pointsEarned: Int
    var badgesEarned: [String]

    var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }
    enum CodingKeys: String, CodingKey {
            case id, mode, startTime, endTime, pointsEarned, badgesEarned
        }
    
    init(id: UUID = UUID(),
             mode: FocusMode,
             startTime: Date,
             endTime: Date? = nil,
             pointsEarned: Int = 0,
             badgesEarned: [String] = []) {
            self.id = id
            self.mode = mode
            self.startTime = startTime
            self.endTime = endTime
            self.pointsEarned = pointsEarned
            self.badgesEarned = badgesEarned
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            mode = try container.decode(FocusMode.self, forKey: .mode)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
            pointsEarned = try container.decode(Int.self, forKey: .pointsEarned)
            badgesEarned = try container.decode([String].self, forKey: .badgesEarned)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(mode, forKey: .mode)
            try container.encode(startTime, forKey: .startTime)
            try container.encodeIfPresent(endTime, forKey: .endTime)
            try container.encode(pointsEarned, forKey: .pointsEarned)
            try container.encode(badgesEarned, forKey: .badgesEarned)
        }
}
