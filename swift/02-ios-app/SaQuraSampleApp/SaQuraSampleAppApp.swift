// SaQuraSampleAppApp.swift
// SaQura Sample iOS / macOS App — Copyright (c) 2026 KyotoTech LLC.
// Licensed under the MIT License (see LICENSE at the repo root).

import SwiftUI
import SaQura

@main
struct SaQuraSampleAppApp: App {
    @StateObject private var licenseManager = LicenseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(licenseManager)
                .task {
                    // Load stored license on app start
                    await licenseManager.loadStoredLicense()
                }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 900, height: 700)
        #endif
    }
}
