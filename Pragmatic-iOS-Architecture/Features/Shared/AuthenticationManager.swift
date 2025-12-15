//
//  AuthenticationManager.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Combine

@MainActor
final class AuthenticationManager: ObservableObject {

    // MARK: - Published State
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: UserInfo?
    @Published private(set) var isCheckingAuth: Bool = true

    // MARK: - Dependencies
    private let secureStorage: SecureStorageProtocol
    private let storage: LocalPersistenceProtocol

    // MARK: - Keys (HARUS SAMA DENGAN REPOSITORY)
    private let accessTokenKey = "accessToken"
    private let userSessionKey = StorageKeys.sessionUser

    // MARK: - Init
    init(
        secureStorage: SecureStorageProtocol = SecureStorage(),
        storage: LocalPersistenceProtocol = LocalPersistence()
    ) {
        self.secureStorage = secureStorage
        self.storage = storage

        checkLoginStatus()
    }

    // MARK: - Session Check (App Launch)
    func checkLoginStatus() {
        defer { isCheckingAuth = false }

        guard
            let token = secureStorage.getToken(key: accessTokenKey),
            !token.isEmpty,
            let cachedUser: UserInfo = storage.get(key: userSessionKey)
        else {
            resetSession()
            return
        }

        self.currentUser = cachedUser
        self.isAuthenticated = true
    }

    // MARK: - Login Success (dipanggil dari LoginViewModel)
    func loginSuccess(user: UserInfo) {
        self.currentUser = user
        self.isAuthenticated = true
    }

    // MARK: - Logout
    func logout() {
        resetSession()
    }

    // MARK: - Private Helper
    private func resetSession() {
        try? secureStorage.clearAll()
        storage.remove(key: userSessionKey)

        self.currentUser = nil
        self.isAuthenticated = false
    }
}
