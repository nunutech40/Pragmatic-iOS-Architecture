//
//  AuthDataResponse.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 15/12/25.
//

import Foundation

struct AuthDataResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let userInfo: UserInfo // Struct UserInfo juga harus didefinisikan
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case tokenType = "token_type"
        case userInfo = "data" // Mengakses lapisan "data" kedua
    }
}

struct UserInfo: Codable {
    let id: Int
    let partnerId: Int
    let partnerNo: String
    let username: String
    let fullname: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id, username, fullname, email
        case partnerId = "partner_id"
        case partnerNo = "partner_no"
    }
}


extension AuthDataResponse {
    static func dummySuccess() -> AuthDataResponse {
        let dummyUser = UserInfo(
            id: 99,
            partnerId: 1,
            partnerNo: "A1",
            username: "testuser",
            fullname: "Test User",
            email: "test@example.com"
        )
        return AuthDataResponse(
            accessToken: "mock.access.token",
            refreshToken: "mock.refresh.token",
            tokenType: "Bearer",
            userInfo: dummyUser
        )
    }
}

extension UserInfo {
    static func dummySuccess() -> UserInfo {
        return UserInfo(
            id: 99,
            partnerId: 1,
            partnerNo: "A1",
            username: "testuser",
            fullname: "Test User",
            email: "test@example.com"
        )
    }
}
