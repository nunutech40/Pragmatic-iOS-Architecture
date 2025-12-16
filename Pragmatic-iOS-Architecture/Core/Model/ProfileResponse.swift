//
//  ProfileResponse.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 15/12/25.
//

import Foundation
import Foundation

// Ini yang bakal jadi T di ServerResponse<UserProfileDTO>
struct UserProfileResponse: Codable {
    let id: Int
    let fullname: String
    let username: String
    let email: String
    let noTelp: String
    let photoProfileUrl: String?
    let joinDate: String?
    let kmpoin: Int?
    
    // Mapping snake_case ke camelCase
    enum CodingKeys: String, CodingKey {
        case id, fullname, username, email
        case noTelp = "no_telp"
        case photoProfileUrl = "photo_profile_url"
        case joinDate = "join_date"
        case kmpoin
    }
}

extension UserProfileResponse {
    static func dummySuccess() -> UserProfileResponse {
        return UserProfileResponse(
            id: 99,
            fullname: "Test User Full Profile",
            username: "testuser",
            email: "test@example.com",
            noTelp: "081234567890", // Data yang hanya ada di profile
            photoProfileUrl: "https://mock.url/photo.jpg",
            joinDate: "2024-01-01",
            kmpoin: 1500 // Data yang hanya ada di profile
        )
    }
}
