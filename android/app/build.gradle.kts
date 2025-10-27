import java.util.Propertiesimport java.util.Propertiesplugins {



val localProperties = Properties()    id("com.android.application")

val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {val localProperties = Properties()    id("kotlin-android")

    localPropertiesFile.inputStream().use { localProperties.load(it) }

}val localPropertiesFile = rootProject.file("local.properties")    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.



val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"if (localPropertiesFile.exists()) {    id("dev.flutter.flutter-gradle-plugin")

val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

    localPropertiesFile.inputStream().use { localProperties.load(it) }}

plugins {

    id("com.android.application")}

    id("kotlin-android")

    id("dev.flutter.flutter-gradle-plugin")android {

    id("com.google.gms.google-services")

}val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"    namespace = "giro.giro_jogos"



android {val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"    compileSdk = flutter.compileSdkVersion

    namespace = "giro.jogos"

    compileSdk = 34    ndkVersion = flutter.ndkVersion



    compileOptions {plugins {

        sourceCompatibility = JavaVersion.VERSION_1_8

        targetCompatibility = JavaVersion.VERSION_1_8    id("com.android.application")    compileOptions {

    }

    id("kotlin-android")        sourceCompatibility = JavaVersion.VERSION_11

    kotlinOptions {

        jvmTarget = "1.8"    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.        targetCompatibility = JavaVersion.VERSION_11

    }

    id("dev.flutter.flutter-gradle-plugin")    }

    sourceSets {

        getByName("main").java.srcDirs("src/main/kotlin")    // START: FlutterFire Configuration

    }

    id("com.google.gms.google-services")    kotlinOptions {

    defaultConfig {

        applicationId = "giro.jogos"    // END: FlutterFire Configuration        jvmTarget = JavaVersion.VERSION_11.toString()

        minSdk = flutter.minSdkVersion

        targetSdk = 34}    }

        versionCode = flutterVersionCode.toInt()

        versionName = flutterVersionName

        multiDexEnabled = true

    }android {    defaultConfig {



    buildTypes {    namespace = "giro.jogos"        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).

        release {

            signingConfig = signingConfigs.getByName("debug")    compileSdk = 34        applicationId = "giro.giro_jogos"

        }

    }        // You can update the following values to match your application needs.

}

    compileOptions {        // For more information, see: https://flutter.dev/to/review-gradle-config.

flutter {

    source = "../.."        sourceCompatibility = JavaVersion.VERSION_1_8        minSdk = flutter.minSdkVersion

}

        targetCompatibility = JavaVersion.VERSION_1_8        targetSdk = flutter.targetSdkVersion

dependencies {

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0")    }        versionCode = flutter.versionCode

}
        versionName = flutter.versionName

    kotlinOptions {    }

        jvmTarget = "1.8"

    }    buildTypes {

        release {

    sourceSets {            // TODO: Add your own signing config for the release build.

        getByName("main").java.srcDirs("src/main/kotlin")            // Signing with the debug keys for now, so `flutter run --release` works.

    }            signingConfig = signingConfigs.getByName("debug")

        }

    defaultConfig {    }

        applicationId = "giro.jogos"}

        minSdk = flutter.minSdkVersion

        targetSdk = 34flutter {

        versionCode = flutterVersionCode.toInt()    source = "../.."

        versionName = flutterVersionName}

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0")
}
