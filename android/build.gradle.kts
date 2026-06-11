allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround for the AGP App Links task ("outputDebugAppLinkSettings") failing
// with "deeplink.json does not exist" during Gradle's up-to-date check. Gradle
// itself suggests declaring the task as untracked.
subprojects {
    tasks.configureEach {
        if (name.endsWith("AppLinkSettings")) {
            doNotTrackState("AGP App Links task does not always create deeplink.json")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
