//
//  HomeViewModel.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 05/12/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    // MARK: - Dependency
    private let repository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI State
    @Published var user: UserProfileResponse?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    // MARK: - Init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Load Profile
    func loadProfile() {
        isLoading = true
        errorMessage = ""

        repository
            .getProfile()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }

                self.isLoading = false

                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
