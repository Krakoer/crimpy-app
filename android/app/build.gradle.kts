import com.android.build.api.variant.ResValue
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The upload keystore is not in the repository: local builds get it from
// android/key.properties, the release workflow writes that file from the
// repository secrets. Without it the release build stays unsigned rather than
// falling back to the debug key.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasUploadKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties()
if (hasUploadKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.crimpyclimbing.crimpy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications, which uses java.time on
        // API levels below 26.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.crimpyclimbing.crimpy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
        // Keeps the builds run from the editor off the application ids the beta
        // testers and production users carry, so running a device does not
        // uninstall their build and the local data behind it. Flutter declares
        // the profile build type itself, hence maybeCreate.
        debug {
            applicationIdSuffix = ".debug"
        }
        maybeCreate("profile").applicationIdSuffix = ".profile"
    }

    flavorDimensions += "default"
    productFlavors {
        create("beta") {
            dimension = "default"
            applicationIdSuffix = ".beta"
        }
        create("prod") {
            dimension = "default"
            // Production uses base applicationId without suffix
        }
    }
}

// The launcher label names both halves of the variant, so a phone carrying the
// beta test build, a production install and whatever the editor last pushed
// shows three distinct entries rather than three called Crimpy. Set per variant
// because a build type resValue would override the flavor's and lose the flavor
// half of the name.
androidComponents {
    onVariants { variant ->
        val marks = listOfNotNull(
            variant.flavorName?.takeIf { it != "prod" },
            variant.buildType?.takeIf { it != "release" },
        )
        val label = if (marks.isEmpty()) "Crimpy" else "Crimpy (${marks.joinToString(" ")})"
        variant.resValues.put(
            variant.makeResValueKey("string", "app_name"),
            ResValue(label))
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
