//
//  LoginPresenter.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    private let repository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var user: UserInfo?
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    // SATU FUNGSI UNTUK SEMUA: Basic, Firebase, SSO
    func performLogin(type: LoginType) {
        isLoading = true
        isError = false
        errorMessage = ""
        
        repository.login(with: type)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Response ini sudah berisi AuthDataResponse yang di-unwrap oleh NetworkClient
                self.user = response.userInfo
                self.isLoggedIn = true
            }
            .store(in: &cancellables)
    }
}
