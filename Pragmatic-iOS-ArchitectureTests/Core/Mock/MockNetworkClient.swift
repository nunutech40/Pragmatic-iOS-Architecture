//
//  MockNetworkClient.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//

import Foundation
import Combine
@testable import Pragmatic_iOS_Architecture

enum MockNetworkError: Error {
    case generalError
    case noData
}

final class MockAPIClient: NetworkClient {
    
    // Properti yang mengontrol hasil yang dikembalikan oleh mock
    // Kita pastikan tipenya adalah NetworkError
    var result: Result<Data, NetworkError> = .failure(.invalidResponse)
    
    var requestCalled = false
    var lastRouter: AppRouter?
    
    private let tokenStorage: SecureStorageProtocol
    
    init(tokenStorage: SecureStorageProtocol = MockSecureStorage()) {
        self.tokenStorage = tokenStorage
    }
    
    func request(router: AppRouter) -> AnyPublisher<Data, NetworkError> {
        requestCalled = true
        lastRouter = router
        
        // Cukup kembalikan result.publisher.mapError{ $0 } atau langsung result.publisher
        return result.publisher
            .mapError { error in
                // Karena result didefinisikan sebagai NetworkError, error juga NetworkError.
                // Kita kembalikan error secara langsung tanpa casting.
                return error
            }
            .eraseToAnyPublisher()
    }
    
    // DI MockAPIClient.swift, GANTI FUNGSI INI

    func setMockData<T: Codable>(_ model: T) throws { // Ganti T: Encodable menjadi T: Codable
        // 1. Bungkus data mentah (AuthDataResponse.dummy) ke dalam ServerResponse Mock
        let wrappedResponse = MockServerResponseWrapper.success(data: model)
        
        // 2. Encode Wrapper lengkap ini
        let data = try JSONEncoder().encode(wrappedResponse)
        
        // 3. Set result (JSON yang sekarang punya meta dan data)
        self.result = .success(data)
    }
    
    func setMockError(_ error: NetworkError) {
        // Saat set error, set result menjadi failure
        self.result = .failure(error)
    }
}
