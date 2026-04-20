// PasswordTestView.swift
// SaQura Test Application
// Copyright (c) 2025-2026 KyotoTech LLC. All rights reserved.

import SwiftUI
import SaQura

struct PasswordTestView: View {
    @EnvironmentObject var licenseManager: LicenseManager
    @State private var password = "MySecurePassword123!"
    @State private var passwordHash = ""
    @State private var verifyPassword = ""
    @State private var verificationResult: Bool?
    @State private var strengthResult: PasswordStrengthResult?
    @State private var statusMessage = ""
    @State private var isProcessing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Password Strength
                strengthSection

                // Hash & Verify
                hashSection

                // Status
                if !statusMessage.isEmpty {
                    statusCard
                }
            }
            .padding()
        }
        .navigationTitle("Password Hashing")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "ellipsis.rectangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Password Security")
                .font(.title2)
                .fontWeight(.bold)

            Text("Industry-standard secure password storage")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Strength Section

    private var strengthSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Password Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter password...", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { _, newValue in
                            analyzeStrength()
                        }
                }

                // Strength Analysis
                if let strength = strengthResult {
                    VStack(spacing: 12) {
                        // Score Bar
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Strength Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(strength.score)/100")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(strengthColor(for: strength.score))
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)

                                    Rectangle()
                                        .fill(strengthColor(for: strength.score))
                                        .frame(width: geometry.size.width * CGFloat(strength.score) / 100, height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }

                        // Level Badge
                        HStack {
                            Text("Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(strengthLevelText(strength.level))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(strengthColor(for: strength.score).opacity(0.2))
                                .foregroundColor(strengthColor(for: strength.score))
                                .cornerRadius(8)
                        }

                        // Suggestions
                        if !strength.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Suggestions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                ForEach(strength.suggestions, id: \.self) { suggestion in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(suggestion)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Password Strength", systemImage: "shield.fill")
        }
        .onAppear {
            analyzeStrength()
        }
    }

    // MARK: - Hash Section

    private var hashSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Hash Button
                Button(action: hashPassword) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "number.square.fill")
                        }
                        Text("Hash Password")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(password.isEmpty || isProcessing)

                // Hash Result
                if !passwordHash.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password Hash (JSON)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(passwordHash)
                                .font(.system(.caption2, design: .monospaced))
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 100)
                    }

                    Divider()

                    // Verify Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verify Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter password to verify...", text: $verifyPassword)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button(action: verifyPasswordHash) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Verify")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(verifyPassword.isEmpty || passwordHash.isEmpty || isProcessing)

                    // Verification Result
                    if let result = verificationResult {
                        HStack {
                            Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(result ? "Password MATCHES" : "Password does NOT match")
                            Spacer()
                        }
                        .padding()
                        .background(result ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .foregroundColor(result ? .green : .red)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Hash & Verify", systemImage: "lock.rectangle.fill")
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

    // MARK: - Helpers

    private func strengthColor(for score: Int) -> Color {
        switch score {
        case 0..<20: return .red
        case 20..<40: return .orange
        case 40..<60: return .yellow
        case 60..<80: return .green
        default: return .blue
        }
    }

    private func strengthLevelText(_ level: PasswordStrengthLevel) -> String {
        switch level {
        case .veryWeak: return "Very Weak"
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .strong: return "Strong"
        case .veryStrong: return "Very Strong"
        }
    }

    // MARK: - Actions

    private func analyzeStrength() {
        strengthResult = password.analyzePasswordStrength()
    }

    private func hashPassword() {
        isProcessing = true
        statusMessage = ""
        verificationResult = nil

        Task {
            do {
                passwordHash = try await password.hashPassword()
                statusMessage = "Password hashed successfully"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
            }
            isProcessing = false
        }
    }

    private func verifyPasswordHash() {
        isProcessing = true
        statusMessage = ""

        Task {
            do {
                verificationResult = try await verifyPassword.verifyPassword(hash: passwordHash)
                statusMessage = verificationResult == true ? "Verification successful" : "Password does not match"
            } catch {
                statusMessage = "Error: \(error.localizedDescription)"
                verificationResult = false
            }
            isProcessing = false
        }
    }
}

#Preview {
    PasswordTestView()
        .environmentObject(LicenseManager())
}
