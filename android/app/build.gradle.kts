plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin harus diletakkan setelah Android dan Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projek_mobile_teori1"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.projek_mobile_teori1"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // aktifkan viewBinding
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

    // Tambahan library AndroidX
    implementation("androidx.activity:activity:1.8.0")
    implementation("androidx.fragment:fragment:1.6.1")
}
