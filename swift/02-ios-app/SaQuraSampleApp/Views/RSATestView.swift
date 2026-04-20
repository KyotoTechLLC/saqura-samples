// RSATestView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

struct RSATestView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var inputText = "Secret message"
    @State private var privateKey = ""
    @State private var publicKey = ""
    @State private var encryptedText = ""
    @State private var decryptedText = ""
    @State private var signature = ""
    @State private var signatureValid: Bool?
    @State private var statusMessage = ""
    @State private var isProcessing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Feature Check
                if !licenseManager.isRSAAvailable {
                    limitedCard
                }

                // Key Generation
                keyGenerationSection

                // Encryption
                encryptionSection

                // Signatures
                signatureSection

                // Status
                if !statusMessage.isEmpty {
                    statusCard
                }
            }
            .padding()
        }
        .navigationTitle("RSA Encryption")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "key.horizontal.fill")
                .font(.system(size: 40))
                .foregroundColor(.purple)

            Text("RSA Encryption")
                .font(.title2)
                .fontWeight(.bold)

            Text("Asymmetric encryption with automatic hybrid mode for large data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Limited Card

    private var limitedCard: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            Text("RSA is available in limited mode (free tier)")
                .foregroundColor(.blue)
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
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
                            Image(systemName: "key.fill")
                        }
                        Text("Generate RSA Key Pair")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isProcessing)

                if !publicKey.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Public Key (first 100 chars)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(publicKey.prefix(100)) + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Private Key (first 100 chars)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(privateKey.prefix(100)) + "...")
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
            Label("Key Generation", systemImage: "wand.and.stars")
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
                    .disabled(encryptedText.isEmpty || privateKey.isEmpty || isProcessing)
                }

                // Results
                if !encryptedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encrypted (Base64, first 100 chars)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(encryptedText.prefix(100)) + "...")
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

    // MARK: - Signature Section

    private var signatureSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Buttons
                HStack(spacing: 12) {
                    Button(action: signData) {
                        HStack {
                            Image(systemName: "signature")
                            Text("Sign")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(inputText.isEmpty || privateKey.isEmpty || isProcessing)

                    Button(action: verifySignature) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Verify")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(signature.isEmpty || publicKey.isEmpty || isProcessing)
                }

                // Results
                if !signature.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Signature (Base64, first 100 chars)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(signature.prefix(100)) + "...")
                            .font(.system(.caption2, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                if let valid = signatureValid {
                    HStack {
                        Image(systemName: valid ? "checkmark.seal.fill" : "xmark.seal.fill")
                        Text(valid ? "Signature is VALID" : "Signature is INVALID")
                        Spacer()
                    }
                    .padding()
                    .background(valid ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .foregroundColor(valid ? .green : .red)
                    .cornerRadius(10)
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Digital Signatures", systemImage: "signature")
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

        Task {
            do {
                let (priv, pub) = try await RSAKey.newKeyPair()
                privateKey = priv
                publicKey = pub
                statusMessage = "Keys generated successfully"
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
                encryptedText = try await inputText.encryptWithRSA(publicKey: publicKey)
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
                decryptedText = try await encryptedText.decryptWithRSA(privateKey: privateKey)
                statusMessage = "Decrypted successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func signData() {
        isProcessing = true
        statusMessage = ""
        signatureValid = nil

        Task {
            do {
                signature = try await inputText.signWithRSA(privateKey: privateKey)
                statusMessage = "Signed successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func verifySignature() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                signatureValid = try await inputText.verifyRSASignature(signature: signature, publicKey: publicKey)
                statusMessage = signatureValid == true ? "Signature verified" : "Invalid signature"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
                signatureValid = false
            }
            isProcessing = false
        }
    }
}

#Preview {
    RSATestView()
        .environmentObject(LicenseManager())
}
