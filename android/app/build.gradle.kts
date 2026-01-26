import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.andromo.dev717025.app1043119"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.andromo.dev717025.app1043119"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // Helper function to load properties
        fun loadKeyProperties(filename: String): Properties? {
            val propsFile = rootProject.file(filename)
            if (propsFile.exists()) {
                val props = Properties()
                props.load(FileInputStream(propsFile))
                return props
            }
            return null
        }

        create("winit") {
            val p = loadKeyProperties("key.properties") ?: loadKeyProperties("key_winit.properties")
            if (p != null) {
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
                storeFile = if (p.getProperty("storeFile") != null) file(p.getProperty("storeFile")) else null
                storePassword = p.getProperty("storePassword")
            }
        }
        
        create("perks") {
            val p = loadKeyProperties("key_perks.properties")
            if (p != null) {
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
                storeFile = if (p.getProperty("storeFile") != null) file(p.getProperty("storeFile")) else null
                storePassword = p.getProperty("storePassword")
            }
        }

        create("swag") {
            val p = loadKeyProperties("key_swag.properties")
            if (p != null) {
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
                storeFile = if (p.getProperty("storeFile") != null) file(p.getProperty("storeFile")) else null
                storePassword = p.getProperty("storePassword")
            }
        }

        create("codblox") {
            val p = loadKeyProperties("key_codblox.properties")
            if (p != null) {
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
                storeFile = if (p.getProperty("storeFile") != null) file(p.getProperty("storeFile")) else null
                storePassword = p.getProperty("storePassword")
            }
        }

        create("crypto") {
            val p = loadKeyProperties("key_crypto.properties")
            if (p != null) {
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
                storeFile = if (p.getProperty("storeFile") != null) file(p.getProperty("storeFile")) else null
                storePassword = p.getProperty("storePassword")
            }
        }
    }

    flavorDimensions += "app"
    productFlavors {
        create("winit") {
            dimension = "app"
            applicationId = "com.andromo.dev717025.app1043119"
            resValue("string", "app_name", "WinIt")
            signingConfig = signingConfigs.getByName("winit")
        }
        create("perks") {
            dimension = "app"
            applicationId = "com.andromo.dev717025.app994579"
            resValue("string", "app_name", "Perks")
            signingConfig = signingConfigs.getByName("perks")
        }
        create("swag") {
            dimension = "app"
            applicationId = "net.andromo.dev717025.app859913"
            resValue("string", "app_name", "Swag")
            signingConfig = signingConfigs.getByName("swag")
        }
        create("codblox") {
            dimension = "app"
            applicationId = "com.newandromo.dev9693.app884425"
            resValue("string", "app_name", "Codblox")
            signingConfig = signingConfigs.getByName("codblox")
        }
        create("crypto") {
            dimension = "app"
            applicationId = "com.newandromo.dev9693.app1383025"
            resValue("string", "app_name", "Crypto")
            signingConfig = signingConfigs.getByName("crypto")
        }
    }

    buildTypes {
        release {
            // Signing config is now set per-flavor
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.activity:activity-ktx:1.9.3")
    implementation("androidx.multidex:multidex:2.0.1")
}
