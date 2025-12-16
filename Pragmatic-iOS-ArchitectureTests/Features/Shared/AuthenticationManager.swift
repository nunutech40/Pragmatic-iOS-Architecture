//
//  AuthenticationManager.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import XCTest
import Combine
@testable import Pragmatic_iOS_Architecture // ⚠️ Sesuaikan Target

// MARK: - Dokumentasi Unit Testing AuthenticationManager
/**
 * # 🎯 Tujuan Utama Pengujian
 * Menguji core logic dari 'AuthenticationManager' yang berfungsi sebagai Source of Truth
 * untuk status sesi pengguna ('isAuthenticated', 'currentUser', 'isCheckingAuth').
 * * Pengujian ini memastikan:
 * 1. Validasi Sesi Saat App Launch (CheckLoginStatus) berhasil memuat data dari Mock Storage.
 * 2. Logika Pembersihan Data ('resetSession' dan 'logout') dipanggil dan membersihkan semua dependensi (Keychain dan Local Persistence).
 * 3. Pembaruan State (@Published) setelah login atau logout berjalan sesuai harapan.
 * * # 🛠️ Mock yang Digunakan
 * - MockSecureStorage (Menggantikan Keychain)
 * - MockLocalPersistence (Menggantikan UserDefaults/Cache)
 * * # 📜 Teori Pengujian Kritis
 * * 1. **CheckLoginStatus (Validasi Sesi):** Logika diuji untuk memverifikasi bahwa *hanya* jika [Token (Keychain) ADA] DAN [UserInfo (Cache) ADA], maka sesi dianggap sah. Kegagalan salah satu kondisi harus memicu 'resetSession()'.
 * * 2. **Side Effect (Logout/Reset):** Setiap kali 'logout()' atau 'resetSession()' dipanggil,
 * harus terverifikasi bahwa:
 * - mockSecureStorage.clearAll() dipanggil.
 * - mockLocalPersistence.remove(key: userSessionKey) dipanggil.
 * - State @Published di-reset ke nilai awal (false, nil).
 * */

final class AuthenticationManagerTests: XCTestCase {

    private var mockSecure: MockSecureStorage!
    private var mockLocal: MockLocalPersistence!
    private var sut: AuthenticationManager! // System Under Test

    private let accessTokenKey = "accessToken"
    private let userSessionKey = StorageKeys.sessionUser
    private let dummyUser = UserInfo.dummySuccess() // Asumsi dummySuccess() sudah tersedia

    override func setUp() {
        super.setUp()
        // Inisialisasi Mocks baru sebelum setiap test
        mockSecure = MockSecureStorage()
        mockLocal = MockLocalPersistence()
        
        // Inisialisasi SUT (System Under Test) dengan dependency injection
        // Perhatian: Init ini akan langsung memanggil checkLoginStatus()
        sut = AuthenticationManager(
            secureStorage: mockSecure,
            storage: mockLocal
        )
    }

    // MARK: - 1. Test Login Sukses Saat App Launch (Sesi Valid)
    func test_01_checkLoginStatus_Success() {
        // Arrange
        let dummyToken = "valid_token"
        // 1. Simulasikan Token ada di Keychain
        try? mockSecure.saveToken(dummyToken, key: accessTokenKey)
        // 2. Simulasikan User Info ada di Local Cache
        mockLocal.save(dummyUser, key: userSessionKey)
        
        // Act: Ulangi inisialisasi untuk memicu checkLoginStatus() ulang
        sut = AuthenticationManager(secureStorage: mockSecure, storage: mockLocal)

        // Assert
        XCTAssertFalse(sut.isCheckingAuth, "Status check harus selesai.")
        XCTAssertTrue(sut.isAuthenticated, "Harus terautentikasi.")
        XCTAssertEqual(sut.currentUser?.id, dummyUser.id, "Current user harus dimuat dari cache.")
    }

    // MARK: - 2. Test Kegagalan Jika Token Hilang/Invalid
    func test_02_checkLoginStatus_tokenMissing_shouldResetSession() {
        // Arrange
        // Token TIDAK DISIMPAN di mockSecure
        mockLocal.save(dummyUser, key: userSessionKey) // User Cache ada

        // Act: Ulangi inisialisasi
        sut = AuthenticationManager(secureStorage: mockSecure, storage: mockLocal)

        // Assert
        XCTAssertFalse(sut.isAuthenticated, "Tidak boleh terautentikasi jika token hilang.")
        // Verifikasi bahwa resetSession dipanggil dan membersihkan storage
        XCTAssertTrue(mockSecure.clearAllCalled, "Jika status gagal, clearAll harus dipanggil.")
        XCTAssertTrue(mockLocal.removeKeysCalled.contains(userSessionKey), "User session cache harus dihapus.")
    }

    // MARK: - 3. Test Kegagalan Jika User Cache Hilang
    func test_03_checkLoginStatus_cacheMissing_shouldResetSession() {
        // Arrange
        let dummyToken = "valid_token"
        try? mockSecure.saveToken(dummyToken, key: accessTokenKey) // Token ada
        // User Cache TIDAK DISIMPAN di mockLocal

        // Act: Ulangi inisialisasi
        sut = AuthenticationManager(secureStorage: mockSecure, storage: mockLocal)

        // Assert
        XCTAssertFalse(sut.isAuthenticated, "Tidak boleh terautentikasi jika cache hilang.")
        // currentUser HARUS NIL setelah resetSession
            XCTAssertNil(sut.currentUser, "Current User harus NIL setelah sesi di-reset karena cache hilang.")
        
        // Verifikasi bahwa resetSession dipanggil
        XCTAssertTrue(mockSecure.clearAllCalled, "Jika status gagal, clearAll harus dipanggil.")
    }

    // MARK: - 4. Test Login Success (Update State)
    func test_04_loginSuccess_updatesState() {
        // Act
        sut.loginSuccess(user: dummyUser)

        // Assert
        XCTAssertTrue(sut.isAuthenticated, "Status harus menjadi true setelah login sukses.")
        XCTAssertEqual(sut.currentUser?.username, dummyUser.username, "Current user harus di-set.")
    }

    // MARK: - 5. Test Logout Functionality (Data Clean-up)
    func test_05_logout_resetsStateAndClearsStorage() {
        // Arrange: Simulasikan sedang login
        sut.loginSuccess(user: dummyUser)

        // Act
        sut.logout()

        // Assert
        XCTAssertFalse(sut.isAuthenticated, "Status harus menjadi false setelah logout.")
        XCTAssertNil(sut.currentUser, "Current user harus nil setelah logout.")
        // Verifikasi pemanggilan clean-up
        XCTAssertTrue(mockSecure.clearAllCalled, "ClearAll harus dipanggil saat logout.")
        XCTAssertTrue(mockLocal.removeKeysCalled.contains(userSessionKey), "User session cache harus dihapus saat logout.")
    }
}
