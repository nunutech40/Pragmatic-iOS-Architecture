//
//  ContentView.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 12/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isCheckingAuth {
                
                splashView
                    .transition(.opacity)
                
            } else if authManager.isAuthenticated {
                
                createHomeModule()
                    .transition(.opacity)
                
            } else {
                
                createLoginModule()
                    .transition(
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                    )
            }
        }
        .animation(.easeInOut, value: authManager.isCheckingAuth)
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}

extension ContentView {
    
    // Splash
    var splashView: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                ProgressView()
            }
        }
    }
    
    // LOGIN MODULE
    func createLoginModule() -> some View {
        
        let repository = Injection.shared.provideUserRepository()
        let viewModel = LoginViewModel(repository: repository)
        
        return LoginView(viewModel: viewModel)
            .onReceive(viewModel.$isLoggedIn) { isLoggedIn in
                if isLoggedIn, let user = viewModel.user {
                    authManager.loginSuccess(user: user)
                }
            }
    }
    
    // HOME MODULE
    func createHomeModule() -> some View {
        let repository = Injection.shared.provideUserRepository()
        // Masukin currentUser ke ViewModel
        let viewModel = HomeViewModel(repository: repository, sessionUser: authManager.currentUser)
        return HomeView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationManager())
    }
}
