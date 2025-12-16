//
//  MockUserRepository.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import Foundation
import Combine
@testable import Pragmatic_iOS_Architecture // Pastikan import ini ada

/**
 * Mock implementation dari UserRepositoryProtocol.
 * Digunakan untuk mengontrol hasil (Success/Failure) dari semua operasi Repository
 * saat Unit Testing ViewModel.
 */
final class MockUserRepository: UserRepositoryProtocol {
    
    // MARK: - Controllable Results (Input untuk Test Case)
    
    // Untuk fungsi login(credentials:)
    // Tipe Error harus sesuai dengan yang dilemparkan oleh network/parsing di Main Target
    var loginResult: Result<AuthDataResponse, Error> = .failure(AuthError.unknown)
    var loginCalled: Bool = false
    
    // Untuk fungsi getProfile()
    var profileResult: Result<UserProfileResponse, Error> = .failure(AuthError.unknown)
    var getProfileCalled: Bool = false
    
    // Untuk fungsi logout()
    var logoutCalled: Bool = false
    
    // MARK: - Implementation of Protocol

    func login(
        username: String,
        password: String,
        fcmToken: String
    ) -> AnyPublisher<AuthDataResponse, Error> {
        loginCalled = true
        
        // Menggunakan Just/Fail publisher dari Combine berdasarkan result yang di-set
        return loginResult.publisher
            .delay(for: 0.01, scheduler: RunLoop.main) // Tambahkan delay kecil untuk simulasi asynchronicity
            .eraseToAnyPublisher()
    }
    
    func getProfile() -> AnyPublisher<UserProfileResponse, Error> {
        getProfileCalled = true
        
        // Menggunakan Just/Fail publisher dari Combine berdasarkan result yang di-set
        return profileResult.publisher
            .delay(for: 0.01, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func logout() {
        logoutCalled = true
        // Biasanya tidak mengembalikan Publisher, hanya side effect
    }
}
