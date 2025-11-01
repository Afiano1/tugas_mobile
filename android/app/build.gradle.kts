shrinkResourcesplugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin harus selalu diletakkan terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projek_mobile_teori1"

    // Gunakan compileSdk minimal 33 agar image_picker dan kamera berfungsi
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.projek_mobile_teori1"
        minSdk = 21
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    kotlin {
        jvmToolchain(17)
    }

buildTypes {
    getByName("release") {
        isMinifyEnabled = true       // aktifkan R8 shrinker
        isShrinkResources = true     // hanya boleh aktif kalau R8 aktif
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("debug")
    }
}


    // ✅ Aktifkan viewBinding untuk plugin seperti image_picker, camera, dll
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")

    // ✅ Tambahkan dependensi AndroidX modern (dibutuhkan oleh image_picker)
    implementation("androidx.activity:activity:1.8.0")
    implementation("androidx.fragment:fragment:1.6.1")
}
