//
//  HomeViewModelTest.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import XCTest
import Combine
@testable import Pragmatic_iOS_Architecture // Sesuaikan Target

// MARK: - Dokumentasi Unit Testing HomeViewModel
/**
 * # 🎯 Tujuan Utama Pengujian
 * Menguji core logic dari 'HomeViewModel' yang bertanggung jawab untuk memuat data profil pengguna
 * ('UserProfileResponse') melalui Repository dan mengelola state UI terkait (loading dan error).
 * * * # 🛠️ Mock yang Digunakan
 * - MockUserRepository: Untuk mengontrol hasil dari 'repository.getProfile()' (Sukses/Gagal).
 * * * # 📜 Teori Pengujian Kritis
 * * 1. **Happy Path (Load Success):** Verifikasi bahwa data 'user' di-set dengan benar, dan 'isLoading' berakhir FALSE, tanpa 'errorMessage'.
 * * 2. **Sad Path (Total Failure):** Verifikasi bahwa ketika Repository mengembalikan kegagalan (network error DAN cache kosong), 'isLoading' berakhir FALSE, 'user' adalah NIL, dan 'errorMessage' diisi.
 * * 3. **Edge Case (Optimization/Debounce):** Karena 'loadProfile()' dipanggil di onAppear (HomeView), View Model harus dioptimalkan untuk TIDAK memanggil Repository (getProfileCalled = FALSE) jika data 'user' sudah berhasil dimuat sebelumnya.
 */
final class HomeViewModelTests: XCTestCase {
    
    private var mockRepository: MockUserRepository!
    private var sut: HomeViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    // Dummy Data
    private let dummyProfile = UserProfileResponse.dummySuccess()
    
    override func setUp() {
        super.setUp()
        cancellables = []
        mockRepository = MockUserRepository()
        sut = HomeViewModel(repository: mockRepository)
    }
    
    // MARK: - 1. Load Profile Sukses (Happy Path)
    func test_01_loadProfile_success_updatesUser() {
        // Arrange
        // Set Mock Repository agar mengembalikan hasil SUKSES (Happy Path)
        mockRepository.profileResult = .success(dummyProfile)
        
        let expectation = self.expectation(description: "Profile should be loaded")
        
        // Act
        sut.loadProfile()
        
        sut.$user
            .dropFirst()
            .sink { user in
                if user != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockRepository.getProfileCalled, "Repository getProfile harus dipanggil.")
        XCTAssertFalse(sut.isLoading, "Loading harus FALSE setelah selesai.")
        XCTAssertTrue(sut.errorMessage.isEmpty, "Error message harus String kosong saat sukses.")
        XCTAssertEqual(sut.user?.id, dummyProfile.id, "Profile user harus dimuat.")
    }
    
    // MARK: - 2. Load Profile Gagal Total (Sad Path: Network + Cache Kosong)
    func test_02_loadProfile_failure_setsErrorMessage() {
        // Arrange
        let mockError = NetworkError.serverError(statusCode: 500, data: nil)
        // Set Mock Repository agar mengembalikan hasil GAGAL (Sad Path: kegagalan total)
        mockRepository.profileResult = .failure(mockError)
        
        let expectation = self.expectation(description: "Profile load should fail")
        
        // Act
        sut.loadProfile()
        
        // Monitor isLoading untuk mengetahui kapan proses selesai
        sut.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertFalse(sut.isLoading, "Loading harus FALSE setelah kegagalan.")
        XCTAssertNil(sut.user, "User harus NIL saat gagal total.")
        XCTAssertFalse(sut.errorMessage.isEmpty, "Error message harus diisi.")
    }
    
    // MARK: - 3. Test Memuat Ulang Hanya Sekali (Edge Case: Optimization/Debounce)
    func test_03_loadProfile_whenUserExists_doesNotReload() {
        // Arrange
        // Simulasikan user sudah dimuat di state
        sut.user = dummyProfile
        // Reset call count di mock (penting untuk verifikasi)
        mockRepository.getProfileCalled = false
        
        // Act
        sut.loadProfile() // Dipanggil lagi
        
        // Assert
        // Kita Assert bahwa fungsi Repository TIDAK dipanggil.
        XCTAssertFalse(mockRepository.getProfileCalled, "loadProfile tidak boleh memanggil Repository jika data sudah ada (optimization).")
        XCTAssertEqual(sut.user?.id, dummyProfile.id, "Data user harus dipertahankan.")
    }
}
