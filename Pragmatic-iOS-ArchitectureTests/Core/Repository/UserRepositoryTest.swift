//
//  UserRepositoryTest.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//
import XCTest
import Combine
@testable import Pragmatic_iOS_Architecture

// Pastikan semua Mock Classes (MockAPIClient, MockSecureStorage, MockLocalPersistence)
// sudah didefinisikan di Target Test lu.

final class UserRepositoryTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!
    // Deklarasikan Mock di sini
    private var mockAPI: MockAPIClient!
    private var mockSecureStorage: MockSecureStorage!
    private var mockLocalPersistence: MockLocalPersistence!
    
    // Key yang dipakai di UserRepository (Harus sesuai)
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    // Key yang dipakai di Local Persistence (Asumsi StorageKeys ada)
    private let sessionUserKey = StorageKeys.sessionUser
    private let fullProfileKey = StorageKeys.fullProfile
    
    override func setUp() {
        super.setUp()
        cancellables = []
        // Inisialisasi Mock sebelum setiap test
        mockAPI = MockAPIClient()
        mockSecureStorage = MockSecureStorage()
        mockLocalPersistence = MockLocalPersistence()
    }
    
    // MARK: - 1. Menguji Side Effect Login (Penyimpanan Token & User)
    func test_01_loginSuccess_storesTokensAndUserInfo() throws {
        // Arrange
        let expectedResponse = AuthDataResponse.dummySuccess()
        
        // Atur Mock Client agar mengembalikan data sukses
        try mockAPI.setMockData(expectedResponse)
        
        let repo = UserRepository(
            client: mockAPI,
            secureStorage: mockSecureStorage,
            storage: mockLocalPersistence
        )
        
        let expectation = XCTestExpectation(description: "Login should succeed and store data")
        
        // Act
        repo.login(username: "u", password: "p", fcmToken: "fcm")
            .sink(receiveCompletion: { completion in
                if case .failure = completion { XCTFail("Login seharusnya sukses") } // <-- GARIS INI GAGAL
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.5)
        
        // Assert: Verifikasi Side Effect Penyimpanan
        
        // Check 1: Secure Storage (Token)
        XCTAssertEqual(mockSecureStorage.savedTokens[accessTokenKey], expectedResponse.accessToken,
                       "Access Token harus disimpan di Keychain Mock.")
        XCTAssertEqual(mockSecureStorage.savedTokens[refreshTokenKey], expectedResponse.refreshToken,
                       "Refresh Token harus disimpan di Keychain Mock.")
        
        // Check 2: Local Persistence (User Info)
        let savedUserInfo: UserInfo? = mockLocalPersistence.get(key: sessionUserKey)
        XCTAssertNotNil(savedUserInfo, "User Info harus disimpan di Local Persistence Mock.")
    }
    
    // MARK: - 2. Menguji Cache Fallback (Get Profile)
    func test_02_getProfile_networkFails_shouldReturnCachedData() throws {
        // Arrange
        let cachedProfile = UserProfileResponse.dummySuccess()
        
        // 1. Simulasikan adanya cache di Local Persistence Mock
        mockLocalPersistence.save(cachedProfile, key: fullProfileKey)
        
        // 2. Atur Network Client agar GAGAL (Simulasi Server Error)
        mockAPI.setMockError(.serverError(statusCode: 500, data: nil))
        
        let repo = UserRepository(
            client: mockAPI,
            secureStorage: mockSecureStorage,
            storage: mockLocalPersistence
        )
        let expectation = XCTestExpectation(description: "Should return cached data on network failure")
        
        // Act
        repo.getProfile()
            .sink(receiveCompletion: { completion in
                if case .failure = completion { XCTFail("Cache Fallback gagal, harusnya sukses dari cache") }
                expectation.fulfill()
            }, receiveValue: { profile in
                // Assert: Pastikan data yang dikembalikan adalah data cache
                XCTAssertEqual(profile.id, cachedProfile.id, "Data yang diterima harus dari cache.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // MARK: - 3. Menguji Logout (Verifikasi Penghapusan Data)
    func test_03_logout_clearsAllStorageKeysAndData() throws {
        // Arrange
        // 1. Simulasikan adanya data di storage sebelum logout
        try mockSecureStorage.saveToken("valid_token", key: accessTokenKey)
        mockLocalPersistence.save("data", key: fullProfileKey)
        mockLocalPersistence.save("user", key: sessionUserKey)
        
        let repo = UserRepository(
            client: mockAPI,
            secureStorage: mockSecureStorage,
            storage: mockLocalPersistence
        )
        
        // Act
        repo.logout()
        
        // Assert 1: Verifikasi pemanggilan fungsi clean-up SecureStorage
        XCTAssertTrue(mockSecureStorage.clearAllCalled, "SecureStorage.clearAll() harus dipanggil.")
        
        // Assert 2: Verifikasi penghapusan Local Persistence (Penting!)
        let expectedRemovedKeys: Set<String> = [fullProfileKey, sessionUserKey]
        
        XCTAssertEqual(mockLocalPersistence.removeKeysCalled, expectedRemovedKeys,
                       "Repository harus memanggil remove untuk session user dan full profile.")
        
        // Assert 3: Pastikan data benar-benar hilang dari mock storage
        XCTAssertFalse(mockLocalPersistence.has(key: fullProfileKey), "Full Profile harus dihapus.")
        XCTAssertNil(mockSecureStorage.getToken(key: accessTokenKey), "Access Token harus dihapus.")
    }
}
