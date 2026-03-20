import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")                  // Firebase
    id("com.google.firebase.appdistribution")             // Firebase App Distribution
}

// ── Read signing credentials from environment variables ──────────────────────
val keyAlias     = System.getenv("KEY_ALIAS")          ?: "kukufiti"
val keyPassword  = System.getenv("KEY_PASSWORD")       ?: ""
val storePassword = System.getenv("KEY_STORE_PASSWORD") ?: ""
val storePath    = System.getenv("KEY_PATH")           ?: "debug.keystore"

android {
    namespace = "com.fredrick.kukufiti"       // changed from com.example.mobile
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.fredrick.kukufiti"   // changed from com.example.mobile
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Signing configuration ─────────────────────────────────────────────
    signingConfigs {
        create("release") {
            this.keyAlias      = keyAlias
            this.keyPassword   = keyPassword
            this.storeFile     = file(storePath)
            this.storePassword = storePassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")   // was "debug"

            isMinifyEnabled   = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // ── Firebase App Distribution ─────────────────────────────────
            firebaseAppDistribution {
                releaseNotesFile = "release_notes.txt"
                groups           = "internal-testers"
            }
        }

        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}