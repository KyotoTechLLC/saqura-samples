// ContentView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

struct ContentView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var selectedTab = 0

    var body: some View {
        #if os(iOS)
        TabView(selection: $selectedTab) {
            LicenseView()
                .tabItem {
                    Label("License", systemImage: "key.fill")
                }
                .tag(0)

            AESTestView()
                .tabItem {
                    Label("AES", systemImage: "lock.fill")
                }
                .tag(1)

            RSATestView()
                .tabItem {
                    Label("RSA", systemImage: "key.horizontal.fill")
                }
                .tag(2)

            PasswordTestView()
                .tabItem {
                    Label("Password", systemImage: "ellipsis.rectangle.fill")
                }
                .tag(3)

            QuantumTestView()
                .tabItem {
                    Label("Quantum", systemImage: "atom")
                }
                .tag(4)
        }
        #else
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: 0) {
                    Label("License", systemImage: "key.fill")
                }
                NavigationLink(value: 1) {
                    Label("AES Encryption", systemImage: "lock.fill")
                }
                NavigationLink(value: 2) {
                    Label("RSA Encryption", systemImage: "key.horizontal.fill")
                }
                NavigationLink(value: 3) {
                    Label("Password Hashing", systemImage: "ellipsis.rectangle.fill")
                }
                NavigationLink(value: 4) {
                    Label("Quantum-Safe", systemImage: "atom")
                }
            }
            .navigationTitle("SaQura Test")
            .listStyle(.sidebar)
        } detail: {
            switch selectedTab {
            case 0:
                LicenseView()
            case 1:
                AESTestView()
            case 2:
                RSATestView()
            case 3:
                PasswordTestView()
            case 4:
                QuantumTestView()
            default:
                LicenseView()
            }
        }
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(LicenseManager())
}
