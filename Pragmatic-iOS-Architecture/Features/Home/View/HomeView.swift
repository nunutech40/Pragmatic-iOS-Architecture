//
//  HomeView.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import SwiftUI

struct HomeView: View {
    
    // Global auth state
    @EnvironmentObject var authManager: AuthenticationManager
    
    // ViewModel
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                if let user = viewModel.user {
                    
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)
                            .shadow(radius: 5)
                        
                        VStack(spacing: 5) {
                            Text("Selamat Datang,")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(user.fullname)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("@\(user.username)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    
                } else if viewModel.isLoading {
                    
                    ProgressView("Loading Profile...")
                    
                } else if !viewModel.errorMessage.isEmpty {
                    
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                    
                } else {
                    
                    EmptyView()
                }
                
                Spacer()
                
                Text("Content Dashboard Here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            authManager.logout()
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        let repository = UserRepository()
        let viewModel = HomeViewModel(repository: repository)
        
        HomeView(viewModel: viewModel)
            .environmentObject(AuthenticationManager())
    }
}
