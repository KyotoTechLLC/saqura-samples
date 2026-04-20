// LicenseManager.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

@MainActor
class LicenseManager: ObservableObject {
    @Published var isLicensed: Bool = false
    @Published var currentTier: String = "Free"
    @Published var licenseMessage: String = ""
    @Published var isLoading: Bool = false

    @Published var isAESAvailable: Bool = false
    @Published var isRSAAvailable: Bool = false
    @Published var isQuantumAvailable: Bool = false
    @Published var isPasswordHashingAvailable: Bool = false

    @Published var daysRemaining: Int = 0
    @Published var expirationDate: String = "-"
    @Published var customerEmail: String = "-"

    func loadStoredLicense() async {
        isLoading = true
        await ApiLicense.loadStoredLicense()
        updateStatus()
        isLoading = false
    }

    func activateFromFile(_ url: URL) async {
        isLoading = true
        licenseMessage = ""

        do {
            let licenseContent = try String(contentsOf: url, encoding: .utf8)
            let result = await ApiLicense.activateLicenseFromJson(licenseContent)

            if result.success {
                licenseMessage = "License activated successfully!"
                updateStatus()
            } else {
                licenseMessage = "Activation failed: \(result.errorMessage ?? "Unknown error")"
            }
        } catch {
            licenseMessage = "Failed to read license file: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func activateFromJson(_ json: String) async {
        isLoading = true
        licenseMessage = ""

        let result = await ApiLicense.activateLicenseFromJson(json)

        if result.success {
            licenseMessage = "License activated successfully!"
            updateStatus()
        } else {
            licenseMessage = "Activation failed: \(result.errorMessage ?? "Unknown error")"
        }

        isLoading = false
    }

    func activateFromBundledLicense(named filename: String) async {
        isLoading = true
        licenseMessage = ""

        // Try to find the license file in the bundle
        if let url = Bundle.main.url(forResource: filename, withExtension: "lic", subdirectory: "Licenses") {
            await activateFromFile(url)
        } else if let url = Bundle.main.url(forResource: filename, withExtension: "lic") {
            await activateFromFile(url)
        } else {
            licenseMessage = "License file '\(filename).lic' not found in bundle"
            isLoading = false
        }
    }

    func deactivate() async {
        isLoading = true
        _ = await ApiLicense.deactivateLicense()
        updateStatus()
        licenseMessage = "License deactivated"
        isLoading = false
    }

    private func updateStatus() {
        isLicensed = ApiLicense.isLicensed
        currentTier = ApiLicense.currentTier.displayName

        isAESAvailable = ApiLicense.isAESAvailable
        isRSAAvailable = ApiLicense.isRSAAvailable
        isQuantumAvailable = ApiLicense.isQuantumAvailable
        isPasswordHashingAvailable = ApiLicense.isPasswordHashingAvailable

        daysRemaining = ApiLicense.getDaysRemaining()

        if let info = ApiLicense.currentLicense {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            expirationDate = formatter.string(from: info.expiresAt)
            customerEmail = info.customer.email
        } else {
            expirationDate = "-"
            customerEmail = "-"
        }
    }
}
