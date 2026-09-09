plugins {
    id("com.android.application")
    id("kotlin-android")                                            // or org.jetbrains.kotlin.android
    id("org.jetbrains.kotlin.plugin.compose") version "2.1.0"    // ← Compose compiler plugin
    // Flutter plugin must come after Android + Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abik.vaidhya.flutter_native_hybrid"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
    }

    defaultConfig {
        applicationId = "com.abik.vaidhya.flutter_native_hybrid"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    // Compose BOM – keeps all Compose libraries in sync
    val composeBom = platform("androidx.compose:compose-bom:2024.10.00")
    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.compose.material:material-icons-extended")

    debugImplementation("androidx.compose.ui:ui-tooling")
}

flutter {
    source = "../.."
}
