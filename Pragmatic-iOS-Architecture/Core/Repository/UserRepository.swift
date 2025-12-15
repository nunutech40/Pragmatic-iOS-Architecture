//
//  UserRepository.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Combine

enum LoginType {
    case basic(username: String, password: String)
    case firebase(token: String)
    case sso(token: String, provider: String)
}

protocol UserRepositoryProtocol {
    func login(with request: LoginType) -> AnyPublisher<AuthDataResponse, Error>
    func getProfile() -> AnyPublisher<UserProfileResponse, Error>
    func logout()
}

final class UserRepository: UserRepositoryProtocol {
    
    // MARK: - Dependencies
    private let client: NetworkClient
    private let secureStorage: SecureStorageProtocol
    private let storage: LocalPersistenceProtocol
    
    // MARK: - Keys
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    // MARK: - Init
    init(
        client: NetworkClient = APIClient(),
        secureStorage: SecureStorageProtocol = SecureStorage(),
        storage: LocalPersistenceProtocol = LocalPersistence()
    ) {
        self.client = client
        self.secureStorage = secureStorage
        self.storage = storage
    }
    
    // MARK: - Login
    func login(with request: LoginType) -> AnyPublisher<AuthDataResponse, Error> {
        let router: AppRouter
        
        switch request {
        case .basic(let user, let pass):
            router = .login(credentials: ["username": user, "password": pass])
        case .firebase(let token):
            router = .firebaseLogin(token: token)
        case .sso(let token, let provider): // Ambil provider-nya juga
            router = .ssoLogin(token: token, provider: provider)
        }
        
        return client.request(router: router)
            .parseAPIResponse(type: AuthDataResponse.self)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                
                // 1. Simpan ke Keychain (Security)
                try? self.secureStorage.saveToken(response.accessToken, key: self.accessTokenKey)
                try? self.secureStorage.saveToken(response.refreshToken, key: self.refreshTokenKey)
                
                // 2. Simpan ke UserDefaults (Performance/UI)
                // Pake StorageKeys yang udah lu buat biar gak typo!
                self.storage.save(response.userInfo, key: StorageKeys.sessionUser)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Profile (Network + Cache Fallback)
    func getProfile() -> AnyPublisher<UserProfileResponse, Error> {
        
        let router = AppRouter.getProfile
        
        return client.request(router: router)
            .parseAPIResponse(type: UserProfileResponse.self)
        
            .handleEvents(receiveOutput: { [weak self] profile in
                self?.storage.save(profile, key: StorageKeys.fullProfile)
            })
        
            .catch { [weak self] error -> AnyPublisher<UserProfileResponse, Error> in
                guard
                    let cached: UserProfileResponse =
                        self?.storage.get(key: StorageKeys.fullProfile)
                else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return Just(cached)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Logout
    func logout() {
        // 1. Tembak API Logout (Optional, biar refresh token di BE mati)
        // client.request(router: .logout)...
        
        // 2. Sapu bersih lokal (Wajib)
        try? secureStorage.clearAll()
        storage.remove(key: StorageKeys.sessionUser)
        storage.remove(key: StorageKeys.fullProfile)
        
    }
}
