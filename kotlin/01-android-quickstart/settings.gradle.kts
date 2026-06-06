pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()   // SaQura is published here: jp.co.kyototech:saqura
    }
}

rootProject.name = "SaQuraAndroidQuickstart"
include(":app")
