import Foundation
import SwiftData

@Model
final class VoiceRecording {
    var id: UUID
    var timestamp: Date
    var duration: TimeInterval
    var title: String
    var recordingDetails: String?
    var isPrivate: Bool
    var filePath: String
    
    init(title: String, duration: TimeInterval, filePath: String, recordingDetails: String? = nil, isPrivate: Bool = true) {
        self.id = UUID()
        self.timestamp = Date()
        self.title = title
        self.duration = duration
        self.recordingDetails = recordingDetails
        self.isPrivate = isPrivate
        self.filePath = filePath
    }
}

@Model
final class MarketplaceOpportunity {
    var id: UUID
    var timestamp: Date
    var title: String
    var details: String
    var budget: String
    var category: String
    var duration: String
    var requirements: String
    var isActive: Bool
    
    init(title: String, details: String, budget: String, category: String, duration: String, requirements: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.title = title
        self.details = details
        self.budget = budget
        self.category = category
        self.duration = duration
        self.requirements = requirements
        self.isActive = true
    }
}

@Model
final class UserProfile {
    var id: UUID
    var username: String
    var bio: String?
    var totalEarnings: Double
    var recordingsCount: Int
    var averageRating: Double
    var joinDate: Date
    
    init(username: String, bio: String? = nil) {
        self.id = UUID()
        self.username = username
        self.bio = bio
        self.totalEarnings = 0.0
        self.recordingsCount = 0
        self.averageRating = 0.0
        self.joinDate = Date()
    }
}
