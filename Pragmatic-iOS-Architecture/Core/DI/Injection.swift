//
//  Injection.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation

final class Injection {

    static let shared = Injection()

    private init() {}

    // MARK: - Repository
    func provideUserRepository() -> UserRepositoryProtocol {

        let secureStorage = SecureStorage()
        let localStorage = LocalPersistence()

        let apiClient = APIClient(tokenStorage: secureStorage)

        return UserRepository(
            client: apiClient,
            secureStorage: secureStorage,
            storage: localStorage
        )
    }

    // MARK: - Auth Manager (Global)
    @MainActor
    func provideAuthManager() -> AuthenticationManager {

        let secureStorage = SecureStorage()
        let localStorage = LocalPersistence()

        return AuthenticationManager(
            secureStorage: secureStorage,
            storage: localStorage
        )
    }
}
