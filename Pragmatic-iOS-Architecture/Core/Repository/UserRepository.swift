//
//  UserRepository.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Combine

protocol UserRepositoryProtocol {
    func login(
        username: String,
        password: String,
        fcmToken: String
    ) -> AnyPublisher<AuthDataResponse, Error>
    
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
    func login(
        username: String,
        password: String,
        fcmToken: String
    ) -> AnyPublisher<AuthDataResponse, Error> {
        
        let parameters: [String: String] = [
            "username": username,
            "password": password,
            "fcm_token": fcmToken
        ]
        
        let router = AppRouter.login(credentials: parameters)
        
        return client.request(router: router)
            .parseAPIResponse(type: AuthDataResponse.self)
        
        // SIDE EFFECT: simpan token + cache user
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                
                try? self.secureStorage.saveToken(
                    response.accessToken,
                    key: self.accessTokenKey
                )
                
                try? self.secureStorage.saveToken(
                    response.refreshToken,
                    key: self.refreshTokenKey
                )
                
                self.storage.save(
                    response.userInfo,
                    key: StorageKeys.sessionUser
                )
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
        try? secureStorage.clearAll()
        storage.remove(key: StorageKeys.sessionUser)
        storage.remove(key: StorageKeys.fullProfile)
    }
}
