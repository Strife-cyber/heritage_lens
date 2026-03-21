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
