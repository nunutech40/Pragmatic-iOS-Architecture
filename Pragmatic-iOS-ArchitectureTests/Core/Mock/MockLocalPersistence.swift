//
//  MockLocalPersistence.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import Foundation
@testable import Pragmatic_iOS_Architecture

final class MockLocalPersistence: LocalPersistenceProtocol {
    
    // MARK: - Internal State (Menggantikan UserDefaults)
    // Menggunakan Dictionary untuk menyimpan data yang sudah di-encode
    var storedData = [String: Data]()
    
    // MARK: - Verification Properties (Untuk Assert di Unit Test)
    var saveCalledCount = 0
    var removeKeysCalled = Set<String>() // Set untuk melacak key yang dihapus

    // MARK: - Implementasi Protokol
    
    func save<T: Codable>(_ value: T, key: String) {
        saveCalledCount += 1
        // Simulasikan encoding dan penyimpanan ke dictionary
        if let encoded = try? JSONEncoder().encode(value) {
            storedData[key] = encoded
        }
    }
    
    func get<T: Codable>(key: String) -> T? {
        guard let data = storedData[key] else { return nil }
        // Simulasikan decoding dan pengambilan data
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func remove(key: String) {
        // 1. Simulasikan penghapusan
        storedData.removeValue(forKey: key)
        // 2. Logging untuk verifikasi (misal saat logout)
        removeKeysCalled.insert(key)
    }
    
    func has(key: String) -> Bool {
        // Cek keberadaan di dictionary
        return storedData.keys.contains(key)
    }
    
    // Helper untuk membersihkan Mock sebelum test lain dimulai
    func reset() {
        storedData.removeAll()
        saveCalledCount = 0
        removeKeysCalled.removeAll()
    }
}
