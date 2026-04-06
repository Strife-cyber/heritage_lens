# Unity Integration Setup Guide

This document details the manual configurations required to fix the "unknown property 'unity.androidNdkPath'" error. These steps must be reapplied if `local.properties` is deleted or if the `unityLibrary` folder is overwritten (e.g., when re-exporting from Unity).

## 1. Update `android/local.properties`

Ensure the following properties are present and point to your local Android SDK and NDK paths. 

> **Note:** The NDK version should match the one used in your project (currently `28.2.13676358`).

```properties
# Example paths for Windows
sdk.dir=C:\\Users\\<YourUser>\\AppData\\Local\\Android\\sdk
ndk.dir=C:\\Users\\<YourUser>\\AppData\\Local\\Android\\Sdk\\ndk\\28.2.13676358

# Required by unityLibrary build script
unity.androidNdkPath=C:\\Users\\<YourUser>\\AppData\\Local\\Android\\Sdk\\ndk\\28.2.13676358
unity.androidSdkPath=C:\\Users\\<YourUser>\\AppData\\Local\\Android\\sdk
```

## 2. Update `android/unityLibrary/build.gradle`

The `unityLibrary` module does not automatically load `local.properties` into the project extensions. You must add the following loading logic at the very top of the file:

```groovy
apply plugin: 'com.android.library'

// --- START MANUAL FIX ---
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localProperties.load(new FileInputStream(localPropertiesFile))
    localProperties.each { key, value ->
        project.ext.set(key, value)
    }
}
// --- END MANUAL FIX ---

apply from: './shared/keepUnitySymbols.gradle'
apply from: './shared/common.gradle'
// ... rest of the file
```

## Why is this necessary?
The `flutter_unity_widget` export from Unity generates a Gradle script that attempts to use `getProperty("unity.androidNdkPath")`. However, in modern Flutter/Android Gradle setups, properties defined in the root `local.properties` are not automatically injected into the `project.ext` of sub-modules unless explicitly loaded.

## 3. Update the `android.ndkVersion` in `android/unityLibrary/build.gradle`
When loaded the `unityLibrary` will also override android.ndkVersion to use the ndk that Unity uses by default. 

If your project is configured on a diffrent ndk version you should see this error:
```code
FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':unityLibrary'.
> com.android.builder.errors.EvalIssueException: [CXX1104] NDK from ndk.dir at C:\Users\dunam\AppData\Local\Android\Sdk\ndk\28.2.13676358 had version [28.2.13676358] which disagrees with android.ndkVersion [27.2.12479018]

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4s
```

To resolve this just change the ndkVersion here 
``` gradle
android {
    namespace "com.unity3d.player"
    // ndkPath "C:/Program Files/Unity/Hub/Editor/6000.3.11f1/Editor/Data/PlaybackEngines/AndroidPlayer/NDK"
    ndkVersion "27.2.12479018"               //<------- This is the ndk version here
    compileSdk 36
    buildToolsVersion = "36.0.0"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    defaultConfig {
        consumerProguardFiles "proguard-unity.txt"
        versionName "1.0"
        minSdk 29
        targetSdk 36
        versionCode 1

        ndk {
            abiFilters "arm64-v8a"
            debugSymbolLevel "symbol_table"
        }

        externalNativeBuild {
            cmake {
                arguments "-DANDROID_STL=c++_shared", "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
            }
        }
    }

    lint {
        abortOnError false
    }

    androidResources {
        ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
        noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp']
    }

    packaging {
        jniLibs {
            useLegacyPackaging true
        }
    }
}
```
to your ndk version.