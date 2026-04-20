// QuantumTestView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

struct QuantumTestView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var inputText = "Quantum-safe secret message"
    @State private var selectedGeneration: QuantumGeneration = .gen6
    @State private var selectedStrength: QuantumStrength = .standard
    @State private var publicKey: Data = Data()
    @State private var privateKey: Data = Data()
    @State private var encapsulatedSecret: Data = Data()
    @State private var encryptedData: Data = Data()
    @State private var decryptedText = ""
    @State private var statusMessage = ""
    @State private var isProcessing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Feature Check
                if !licenseManager.isQuantumAvailable {
                    unavailableCard
                }

                // Generation Info
                generationInfoCard

                // Key Generation
                keyGenerationSection

                // Encryption
                encryptionSection

                // Status
                if !statusMessage.isEmpty {
                    statusCard
                }
            }
            .padding()
        }
        .navigationTitle("Quantum-Safe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "atom")
                .font(.system(size: 40))
                .foregroundColor(.cyan)

            Text("Quantum-Safe Encryption")
                .font(.title2)
                .fontWeight(.bold)

            Text("Future-proof security against advanced threats")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Unavailable Card

    private var unavailableCard: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Quantum-safe encryption requires a Pro or higher license")
                .foregroundColor(.orange)
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Generation Info

    private var generationInfoCard: some View {
        GroupBox {
            VStack(spacing: 12) {
                // Generation Picker
                HStack {
                    Text("Generation")
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Generation", selection: $selectedGeneration) {
                        Text("Gen 2").tag(QuantumGeneration.gen2)
                        Text("Gen 4").tag(QuantumGeneration.gen4)
                        Text("Gen 5").tag(QuantumGeneration.gen5)
                        Text("Gen 6 (Recommended)").tag(QuantumGeneration.gen6)
                        Text("Gen 7 (Maximum)").tag(QuantumGeneration.gen7)
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                // Strength Picker
                HStack {
                    Text("Strength")
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Strength", selection: $selectedStrength) {
                        Text("Standard").tag(QuantumStrength.standard)
                        Text("Medium").tag(QuantumStrength.medium)
                        Text("Highest").tag(QuantumStrength.highest)
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                // Security Assessment
                HStack {
                    Text("Assessment")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(Quantum.getSecurityAssessment(selectedGeneration))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Quantum.isSecureGeneration(selectedGeneration) ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(Quantum.isSecureGeneration(selectedGeneration) ? .green : .red)
                        .cornerRadius(6)
                }

                // Recommended
                HStack {
                    Text("Recommended for Mobile")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(Quantum.getRecommendedGeneration(forMobile: true, highestSecurity: false) == selectedGeneration ? "Yes" : "No")
                        .fontWeight(.medium)
                        .foregroundColor(Quantum.getRecommendedGeneration(forMobile: true, highestSecurity: false) == selectedGeneration ? .green : .secondary)
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Configuration", systemImage: "gearshape.fill")
        }
    }

    // MARK: - Key Generation

    private var keyGenerationSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                Button(action: generateKeys) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text("Generate Quantum Key Pair")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .disabled(isProcessing)

                if !publicKey.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Public Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(publicKey.count) bytes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(publicKey.prefix(40).map { String(format: "%02X", $0) }.joined(separator: " ") + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Private Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(privateKey.count) bytes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(privateKey.prefix(40).map { String(format: "%02X", $0) }.joined(separator: " ") + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Key Generation", systemImage: "key.fill")
        }
    }

    // MARK: - Encryption Section

    private var encryptionSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plain Text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter text to encrypt...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                }

                // Buttons
                HStack(spacing: 12) {
                    Button(action: encrypt) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Encrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputText.isEmpty || publicKey.isEmpty || isProcessing)

                    Button(action: decrypt) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(encryptedData.isEmpty || privateKey.isEmpty || isProcessing)
                }

                // Results
                if !encapsulatedSecret.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Encapsulated Secret")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(encapsulatedSecret.count) bytes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(encapsulatedSecret.prefix(30).map { String(format: "%02X", $0) }.joined(separator: " ") + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                if !encryptedData.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Encrypted Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(encryptedData.count) bytes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(encryptedData.prefix(30).map { String(format: "%02X", $0) }.joined(separator: " ") + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                if !decryptedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Decrypted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(decryptedText)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Encryption / Decryption", systemImage: "lock.rectangle.fill")
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        HStack {
            Image(systemName: statusMessage.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
            Text(statusMessage)
            Spacer()
        }
        .padding()
        .background(statusMessage.contains("Error") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        .foregroundColor(statusMessage.contains("Error") ? .red : .green)
        .cornerRadius(10)
    }

    // MARK: - Actions

    private func generateKeys() {
        isProcessing = true
        statusMessage = ""
        encryptedData = Data()
        encapsulatedSecret = Data()
        decryptedText = ""

        Task {
            do {
                let (pub, priv) = try await Quantum.generateKeyPair(
                    strength: selectedStrength,
                    generation: selectedGeneration
                )
                publicKey = pub
                privateKey = priv
                statusMessage = "Keys generated (\(selectedGeneration.rawValue))"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func encrypt() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                let (secret, encrypted) = try await inputText.encryptWithQuantum(publicKey: publicKey)
                encapsulatedSecret = secret
                encryptedData = encrypted
                statusMessage = "Encrypted successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func decrypt() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                decryptedText = try await encryptedData.decryptWithQuantum(
                    privateKey: privateKey,
                    secret: encapsulatedSecret
                )
                statusMessage = "Decrypted successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }
}

#Preview {
    QuantumTestView()
        .environmentObject(LicenseManager())
}
