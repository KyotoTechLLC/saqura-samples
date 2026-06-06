plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "jp.co.kyototech.saqura.sample"
    compileSdk = 34

    defaultConfig {
        applicationId = "jp.co.kyototech.saqura.sample"
        minSdk = 24            // SaQura targets API 24+ (~98% of active devices)
        targetSdk = 34
        versionCode = 1
        versionName = "1.1.3"  // tracks the SaQura SDK version this sample pins
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    // The one line that matters — SaQura from Maven Central.
    implementation("jp.co.kyototech:saqura:1.1.3")

    // Standard Android app plumbing used by this sample.
    implementation("androidx.activity:activity-ktx:1.9.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
}
