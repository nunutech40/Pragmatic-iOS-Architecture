//
//  MockSecureStorage.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//
import Foundation
import Combine
@testable import Pragmatic_iOS_Architecture

final class MockSecureStorage: SecureStorageProtocol {
    
    // MARK: - Internal State (Menggantikan Keychain)
    var savedTokens = [String: String]()
    
    // MARK: - Verification Properties (Untuk Assert di Unit Test)
    var saveTokenCalledCount = 0
    var lastSavedKey: String?
    var clearAllCalled = false
    
    // MARK: - Implementasi Protokol
    
    func saveToken(_ token: String, key: String) throws {
        // 1. Simulasikan penyimpanan
        savedTokens[key] = token
        // 2. Logging untuk verifikasi
        saveTokenCalledCount += 1
        lastSavedKey = key
    }
    
    func getToken(key: String) -> String? {
        // 1. Simulasikan pengambilan data
        return savedTokens[key]
    }
    
    func clearAll() throws {
        // 1. Set flag verifikasi
        clearAllCalled = true
        // 2. Simulasikan penghapusan
        savedTokens.removeValue(forKey: "accessToken") // Sesuai dengan logic clearAll asli lu
        savedTokens.removeValue(forKey: "refreshToken") // Sesuai dengan logic clearAll asli lu
    }
    
    // Lu juga bisa tambahkan helper di sini jika mau
    func reset() {
        savedTokens.removeAll()
        saveTokenCalledCount = 0
        clearAllCalled = false
        lastSavedKey = nil
    }
}
