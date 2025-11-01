plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
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

    // ✅ Gunakan Java 17 (hilangkan warning source 8)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // ✅ Pastikan Kotlin juga pakai Java 17
    kotlinOptions {
        jvmTarget = "17"
    }

    // ✅ Tambahkan jvmToolchain agar Gradle modern bisa auto pilih versi Java yang benar
    kotlin {
        jvmToolchain(17)
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
