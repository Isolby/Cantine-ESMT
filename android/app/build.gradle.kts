plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Ajout du plugin Google Services pour Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.projet_flutter"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.projet_flutter"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        
        // Support pour MultiDex (nécessaire pour Firebase)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Optimisations pour le release
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    
    // Packaging options pour éviter les conflits
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Support MultiDex
    implementation("androidx.multidex:multidex:2.0.1")

    // Core Library Desugaring pour les API Java 8+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}