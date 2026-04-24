import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.appdistribution")
}

// ── Load signing credentials ──────────────────────────────────────────────────
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { stream ->
        keyProperties.load(stream as java.io.InputStream)
    }
}

val signingKeyAlias: String      = keyProperties.getProperty("keyAlias") ?: System.getenv("KEY_ALIAS") ?: ""
val signingKeyPassword: String   = keyProperties.getProperty("keyPassword") ?: System.getenv("KEY_PASSWORD") ?: ""
val signingStorePassword: String = keyProperties.getProperty("storePassword") ?: System.getenv("KEY_STORE_PASSWORD") ?: ""
val signingStorePath: String     = keyProperties.getProperty("storeFile") ?: System.getenv("KEY_PATH") ?: "kukufiti-release.jks"

android {
    namespace = "com.fredrick.kukufiti"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.fredrick.kukufiti"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias      = signingKeyAlias
            keyPassword   = signingKeyPassword
            storeFile     = if (signingStorePath.isNotEmpty()) file(signingStorePath) else null
            storePassword = signingStorePassword
        }
    }

    buildTypes {
        release {
            // Only apply signing if we have the credentials
            signingConfig = if (signingKeyAlias.isNotEmpty()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            isMinifyEnabled   = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
