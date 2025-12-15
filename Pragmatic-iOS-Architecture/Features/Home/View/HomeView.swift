//
//  HomeView.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                // LOGIC: Cek data lengkap dulu, baru data session
                if let profile = viewModel.fullProfile {
                    // Tampilan User dengan Data Lengkap (Ada kmpoin dll)
                    userDataView(name: profile.fullname,
                                 username: profile.username,
                                 extraInfo: "Poin: \(profile.kmpoin ?? 0)")
                    
                } else if let session = viewModel.sessionUser {
                    // Tampilan User dengan Data Minimal (Biar nggak kosong pas loading)
                    userDataView(name: session.fullname,
                                 username: session.username,
                                 extraInfo: "Loading detail...")
                } else if viewModel.isLoading {
                    ProgressView("Syncing...")
                }

                Spacer()
                Text("Content Dashboard Here")
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) { authManager.logout() } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
    
    // Helper view biar nggak redundant
    func userDataView(name: String, username: String, extraInfo: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            VStack(spacing: 5) {
                Text("Selamat Datang,")
                    .font(.subheadline).foregroundColor(.secondary)
                Text(name)
                    .font(.title2).fontWeight(.bold)
                Text("@\(username)")
                    .font(.caption).foregroundColor(.gray)
                Text(extraInfo)
                    .font(.caption2).foregroundColor(.blue).padding(.top, 5)
            }
        }
        .padding(.top, 40)
    }
}
