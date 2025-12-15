//
//  HomeViewModel.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 05/12/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    private let repository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var fullProfile: UserProfileResponse? // Data lengkap dari API
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    // Simpan data minimalis dari login
    let sessionUser: UserInfo?

    init(repository: UserRepositoryProtocol, sessionUser: UserInfo? = nil) {
        self.repository = repository
        self.sessionUser = sessionUser
    }

    func loadProfile() {
        // Cek dulu, kalau ini SSO/Firebase dan datanya sudah dianggap cukup,
        // mungkin lu mau skip. Tapi kalau tetep mau detail (no_telp dll), lanjut tembak API.
        
        isLoading = true
        errorMessage = ""

        repository.getProfile()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] profile in
                self?.fullProfile = profile
            }
            .store(in: &cancellables)
    }
}
