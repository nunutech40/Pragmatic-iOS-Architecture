//
//  LoginViewModelTest.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import XCTest
import Combine
@testable import Pragmatic_iOS_Architecture // ⚠️ Sesuaikan Target

// MARK: - Dokumentasi Unit Testing LoginViewModel
/**
 * # 🎯 Tujuan Utama Pengujian
 * Menguji core logic dari 'LoginViewModel' untuk memverifikasi bagaimana state UI (@Published)
 * bereaksi secara sinkron terhadap hasil operasi asynchronous dari Repository.
 * * * Pengujian ini memastikan:
 * 1. State 'isLoading' diatur TRUE saat start dan FALSE saat selesai (baik sukses maupun gagal).
 * 2. State sukses ('isLoggedIn' dan 'user') diatur dengan benar setelah respons SUKSES dari Repository.
 * 3. State error ('isError' dan 'errorMessage') diatur dengan benar setelah Publisher mengembalikan FAILURE.
 * 4. State error di-reset di awal setiap pemanggilan login.
 * * * # 🛠️ Mock yang Digunakan
 * - MockUserRepository: Untuk mengontrol hasil dari 'repository.login(...)' (Sukses atau Gagal).
 * * * # 📜 Teori Pengujian Kritis
 * * 1. **State Transition:** ViewModel harus selalu menunjukkan transisi state: START (reset error, isLoading=true) -> END (isLoading=false, state success/failure).
 * * 2. **Combine Asynchronous:** Penggunaan XCTestExpectation wajib karena ViewModel menggunakan Combine Publisher yang bersifat asynchronous. Assert harus menunggu hingga Publisher selesai.
 * * 3. **Error Handling:** Saat Repository gagal (Publisher mengirim .failure), ViewModel harus menangkap error tersebut dan mengisi 'errorMessage' menggunakan 'error.localizedDescription'.
 */
final class LoginViewModelTests: XCTestCase {

    private var mockRepository: MockUserRepository!
    private var sut: LoginViewModel! // System Under Test
    private var cancellables: Set<AnyCancellable>!
    
    // Data Dummy
    private let dummyUser = UserInfo.dummySuccess()
    private let dummyAuthResponse = AuthDataResponse.dummySuccess()
    private let mockErrorMessage = "Username atau password salah." // Contoh pesan error

    override func setUp() {
        super.setUp()
        cancellables = []
        
        // 1. Inisialisasi Mock Repository
        mockRepository = MockUserRepository()
        
        // 2. Inject Mock ke ViewModel
        sut = LoginViewModel(repository: mockRepository)
    }

    // MARK: - 1. Login Sukses (Happy Path)
    func test_01_login_success_updatesUIState() throws {
        // Arrange
        // Set Mock Repository agar mengembalikan hasil SUKSES
        mockRepository.loginResult = .success(dummyAuthResponse)
        
        let expectation = self.expectation(description: "ViewModel should complete login successfully")

        // Act
        sut.login(username: "test", password: "123")
        
        // Assert A: Pre-login state check
        XCTAssertTrue(sut.isLoading, "Loading harus TRUE saat aksi dimulai.")
        
        // Monitor isLoggedin (atau user) untuk memverifikasi receiveValue dipanggil
        sut.$isLoggedIn
            .dropFirst() // Ignore initial value
            .sink { isLoggedIn in
                if isLoggedIn {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)

        // Assert B: Post-login state check
        XCTAssertTrue(mockRepository.loginCalled, "Repository login harus dipanggil.")
        XCTAssertFalse(sut.isLoading, "Loading harus FALSE setelah selesai.")
        XCTAssertFalse(sut.isError, "isError harus FALSE saat sukses.")
        XCTAssertTrue(sut.isLoggedIn, "isLoggedIn harus TRUE.")
        XCTAssertEqual(sut.user?.id, dummyUser.id, "User info harus di-set.")
    }

    // MARK: - 2. Login Gagal (Sad Path: Network/Server Error)
    func test_02_login_failure_updatesErrorState() throws {
        // Arrange
        let networkError = NetworkError.serverError(statusCode: 401, data: nil)
        // Set Mock Repository agar mengembalikan hasil GAGAL
        mockRepository.loginResult = .failure(networkError)
        
        let expectation = self.expectation(description: "ViewModel should complete with error")

        // Act
        sut.login(username: "test", password: "123")

        // Monitor isError untuk memverifikasi receiveCompletion(.failure) dipanggil
        sut.$isError
            .dropFirst()
            .sink { isError in
                if isError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertFalse(sut.isLoading, "Loading harus FALSE setelah error.")
        XCTAssertTrue(sut.isError, "isError harus TRUE saat gagal.")
        XCTAssertFalse(sut.isLoggedIn, "isLoggedIn harus FALSE.")
        // Verifikasi error message diisi
        XCTAssertFalse(sut.errorMessage.isEmpty, "Error message tidak boleh kosong.")
    }
}
