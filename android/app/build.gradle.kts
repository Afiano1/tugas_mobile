plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus diletakkan setelah plugin Android dan Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projek_mobile_teori1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.projek_mobile_teori1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Tambahkan blok ini untuk dukungan Java 8+ dan desugaring
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // Masih menggunakan signing debug agar bisa run release dengan mudah
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tambahkan ini untuk fitur desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // Kotlin standar library
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
