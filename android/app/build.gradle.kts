plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.enscribe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.enscribe"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Replace with your release config
        }
    }
}

flutter {
    source = "../.."
}

afterEvaluate {
    tasks.matching { it.name.startsWith("assemble") && it.name.endsWith("Release") }.configureEach {
        doLast {
            val versionName = android.defaultConfig.versionName
            val versionCode = android.defaultConfig.versionCode

            val outputDir = file("$buildDir/outputs/flutter-apk")
            if (outputDir.exists()) {
                outputDir.listFiles()?.forEach { file ->
                    if (file.extension == "apk") {
                        val abi = when {
                            "armeabi-v7a" in file.name -> "armeabi-v7a"
                            "arm64-v8a" in file.name -> "arm64-v8a"
                            "x86_64" in file.name -> "x86_64"
                            "universal" in file.name -> "universal"
                            else -> null
                        }

                        abi?.let {
                            val newName = "enscribe-${versionName}-${versionCode}-$abi.apk"
                            val renamed = file.resolveSibling(newName)
                            file.renameTo(renamed)
                            println("Renamed ${file.name} -> ${renamed.name}")
                        }
                    }
                }
            }
        }
    }
}
