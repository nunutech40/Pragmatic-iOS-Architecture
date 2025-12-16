//
//  LoginPresenter.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {

    // MARK: - Dependency
    private let repository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var user: UserInfo?

    // MARK: - Init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Login Action
    func login(username: String, password: String) {

        isLoading = true
        isError = false
        errorMessage = ""

        repository
            .login(
                username: username,
                password: password,
                fcmToken: "dummy_fcm"
            )
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }

                self.isLoading = false

                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }

                // Repository sudah simpan token + cache user
                self.user = response.userInfo
                self.isLoggedIn = true
            }
            .store(in: &cancellables)
    }
}
