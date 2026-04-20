// AESTestView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

struct AESTestView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var inputText = "Hello, SaQura!"
    @State private var encryptionKey = ""
    @State private var encryptedText = ""
    @State private var decryptedText = ""
    @State private var statusMessage = ""
    @State private var isProcessing = false

    // Password-based encryption
    @State private var password = ""
    @State private var salt = "my-unique-salt"
    @State private var passwordEncrypted = ""
    @State private var passwordDecrypted = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Feature Check
                if !licenseManager.isAESAvailable {
                    unavailableCard
                }

                // Key-based Encryption
                keyEncryptionSection

                // Password-based Encryption
                passwordEncryptionSection

                // Status
                if !statusMessage.isEmpty {
                    statusCard
                }
            }
            .padding()
        }
        .navigationTitle("AES Encryption")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text("AES-256 Encryption")
                .font(.title2)
                .fontWeight(.bold)

            Text("Fast symmetric encryption for any data size")
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
            Text("AES encryption requires a Standard or higher license")
                .foregroundColor(.orange)
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Key Encryption Section

    private var keyEncryptionSection: some View {
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

                // Key
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Encryption Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Generate") {
                            encryptionKey = AESKey.newKey()
                            statusMessage = "New key generated"
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                    }
                    TextField("Key (Base64)", text: $encryptionKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }

                // Buttons
                HStack(spacing: 12) {
                    Button(action: encryptWithKey) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Encrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputText.isEmpty || encryptionKey.isEmpty || isProcessing)

                    Button(action: decryptWithKey) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(encryptedText.isEmpty || encryptionKey.isEmpty || isProcessing)
                }

                // Results
                if !encryptedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encrypted (Base64)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(encryptedText)
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .textSelection(.enabled)
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
            Label("Key-Based Encryption", systemImage: "key.fill")
        }
    }

    // MARK: - Password Encryption Section

    private var passwordEncryptionSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Enter password...", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                // Salt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Salt (unique per user/context)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Salt value...", text: $salt)
                        .textFieldStyle(.roundedBorder)
                }

                // Buttons
                HStack(spacing: 12) {
                    Button(action: encryptWithPassword) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Encrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(inputText.isEmpty || password.isEmpty || isProcessing)

                    Button(action: decryptWithPassword) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(passwordEncrypted.isEmpty || password.isEmpty || isProcessing)
                }

                // Results
                if !passwordEncrypted.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encrypted (Base64)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(passwordEncrypted)
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                    }
                }

                if !passwordDecrypted.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Decrypted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(passwordDecrypted)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Password-Based Encryption", systemImage: "ellipsis.rectangle.fill")
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

    private func encryptWithKey() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                encryptedText = try await inputText.encryptWithAES(key: encryptionKey)
                statusMessage = "Encrypted successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func decryptWithKey() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                decryptedText = try await encryptedText.decryptWithAES(key: encryptionKey)
                statusMessage = "Decrypted successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func encryptWithPassword() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                passwordEncrypted = try await inputText.encryptWithPassword(password: password, salt: salt)
                statusMessage = "Encrypted with password"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func decryptWithPassword() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                passwordDecrypted = try await passwordEncrypted.decryptWithPassword(password: password, salt: salt)
                statusMessage = "Decrypted with password"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }
}

#Preview {
    AESTestView()
        .environmentObject(LicenseManager())
}
