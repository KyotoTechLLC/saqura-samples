// LicenseView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura
import UniformTypeIdentifiers

struct LicenseView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var showingFilePicker = false
    @State private var licenseJsonInput = ""
    @State private var showingJsonInput = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // License Status Card
                statusCard

                // Feature Availability
                featureCard

                // Activation Options
                activationCard

                // Message
                if !licenseManager.licenseMessage.isEmpty {
                    messageCard
                }
            }
            .padding()
        }
        .navigationTitle("License Management")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "lic") ?? .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Task {
                        // Need to access the security-scoped resource
                        guard url.startAccessingSecurityScopedResource() else { return }
                        defer { url.stopAccessingSecurityScopedResource() }

                        await licenseManager.activateFromFile(url)
                    }
                }
            case .failure(let error):
                licenseManager.licenseMessage = "File picker error: \(error.localizedDescription)"
            }
        }
        .sheet(isPresented: $showingJsonInput) {
            jsonInputSheet
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "key.fill")
                .font(.system(size: 50))
                .foregroundColor(licenseManager.isLicensed ? .green : .orange)

            Text("SaQura License")
                .font(.title)
                .fontWeight(.bold)

            Text("Manage your SaQura library license")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(licenseManager.isLicensed ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(licenseManager.isLicensed ? "Licensed" : "Free Mode")
                            .fontWeight(.semibold)
                    }
                }

                Divider()

                HStack {
                    Text("Tier")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(licenseManager.currentTier)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(tierColor.opacity(0.2))
                        .foregroundColor(tierColor)
                        .cornerRadius(8)
                }

                if licenseManager.isLicensed {
                    Divider()

                    HStack {
                        Text("Customer")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(licenseManager.customerEmail)
                            .fontWeight(.medium)
                    }

                    Divider()

                    HStack {
                        Text("Expires")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(licenseManager.expirationDate)
                            .fontWeight(.medium)
                    }

                    Divider()

                    HStack {
                        Text("Days Remaining")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(licenseManager.daysRemaining)")
                            .fontWeight(.medium)
                            .foregroundColor(licenseManager.daysRemaining < 30 ? .orange : .primary)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("License Status", systemImage: "checkmark.seal.fill")
        }
    }

    private var tierColor: Color {
        switch licenseManager.currentTier.lowercased() {
        case "enterprise": return .purple
        case "pro": return .blue
        case "standard": return .green
        case "basic": return .orange
        default: return .gray
        }
    }

    // MARK: - Feature Card

    private var featureCard: some View {
        GroupBox {
            VStack(spacing: 12) {
                featureRow("AES Encryption", available: licenseManager.isAESAvailable)
                Divider()
                featureRow("RSA Encryption", available: licenseManager.isRSAAvailable)
                Divider()
                featureRow("Password Hashing", available: licenseManager.isPasswordHashingAvailable)
                Divider()
                featureRow("Quantum-Safe", available: licenseManager.isQuantumAvailable)
            }
            .padding(.vertical, 8)
        } label: {
            Label("Available Features", systemImage: "list.bullet.rectangle.fill")
        }
    }

    private func featureRow(_ name: String, available: Bool) -> some View {
        HStack {
            Text(name)
            Spacer()
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? .green : .red)
        }
    }

    // MARK: - Activation Card

    private var activationCard: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Load from file
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Load License File (.lic)")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Load bundled license (Standard)
                Button(action: {
                    Task {
                        await licenseManager.activateFromBundledLicense(named: "SaQura_Sample_standard")
                    }
                }) {
                    HStack {
                        Image(systemName: "shippingbox.fill")
                        Text("Activate Bundled Standard License")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Load bundled license (Distribution)
                Button(action: {
                    Task {
                        await licenseManager.activateFromBundledLicense(named: "SaQura_Sample_distribution")
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill")
                        Text("Activate Bundled Distribution License")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Enter JSON manually
                Button(action: {
                    showingJsonInput = true
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Enter License JSON")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Deactivate
                if licenseManager.isLicensed {
                    Divider()

                    Button(action: {
                        Task {
                            await licenseManager.deactivate()
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Deactivate License")
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Activation", systemImage: "arrow.up.circle.fill")
        }
    }

    // MARK: - Message Card

    private var messageCard: some View {
        HStack {
            Image(systemName: licenseManager.licenseMessage.contains("success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            Text(licenseManager.licenseMessage)
            Spacer()
        }
        .padding()
        .background(licenseManager.licenseMessage.contains("success") ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .foregroundColor(licenseManager.licenseMessage.contains("success") ? .green : .orange)
        .cornerRadius(10)
    }

    // MARK: - JSON Input Sheet

    private var jsonInputSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Paste your license JSON content below:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextEditor(text: $licenseJsonInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .border(Color.gray.opacity(0.3))
                    .cornerRadius(8)

                Button("Activate") {
                    Task {
                        await licenseManager.activateFromJson(licenseJsonInput)
                        showingJsonInput = false
                        licenseJsonInput = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(licenseJsonInput.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Enter License JSON")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingJsonInput = false
                        licenseJsonInput = ""
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 400)
        #endif
    }
}

#Preview {
    LicenseView()
        .environmentObject(LicenseManager())
}
