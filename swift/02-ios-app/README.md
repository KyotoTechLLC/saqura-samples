# swift/02-ios-app

A SwiftUI app that wraps every SaQura feature in a tabbed UI — License, AES, RSA, Password, Quantum. Works on iOS and macOS from the same codebase.

Use it as a playground while you're figuring out how your app should integrate SaQura, or as a reference for wiring `ApiLicense` into a SwiftUI `ObservableObject`.

## Run

```bash
cd swift/02-ios-app
open Package.swift
```

Xcode opens the package. Pick an iOS Simulator (or "My Mac") and hit run.

Or from the command line for macOS:

```bash
swift run
```

## Activating a license in the app

Three ways, in order of convenience:

1. **Bundled file** — drop `SaQura_Sample_standard.lic` into `SaQuraSampleApp/Resources/Licenses/` and tap **Activate Bundled Standard License**. The folder is `.gitignore`d.
2. **File picker** — tap **Load License File (.lic)** and pick the file from disk.
3. **JSON paste** — tap **Enter License JSON** and paste the contents of your `.lic` file. Useful for testing the embedded-license path before you ship.

The activated license is cached by SaQura across app launches, so you only need to do this once per device.

## Project structure

```
swift/02-ios-app/
├── Package.swift
└── SaQuraSampleApp/
    ├── SaQuraSampleAppApp.swift    # @main entry point
    ├── ContentView.swift           # Tab/sidebar navigation
    ├── LicenseManager.swift        # ObservableObject wrapping ApiLicense
    ├── Views/
    │   ├── LicenseView.swift
    │   ├── AESTestView.swift
    │   ├── RSATestView.swift
    │   ├── PasswordTestView.swift
    │   └── QuantumTestView.swift
    └── Resources/
        └── Licenses/               # put your .lic files here (gitignored)
```

## Requirements

- iOS 17.0+ or macOS 14.0+ (sample uses `NavigationSplitView` and the two-closure `onChange`)
- Xcode 15.0+ / Swift 5.9+

> The SaQura SDK itself supports iOS 15+ / macOS 12+ — only this sample app requires the newer SwiftUI APIs.
