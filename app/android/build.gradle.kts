allprojects {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:unchecked")
        options.isFork = true
        options.forkOptions.jvmArgs = listOf("-Dfile.encoding=UTF-8")
        sourceCompatibility = "1.8" // Or a compatible version (e.g., "1.8", "11")
        targetCompatibility = "1.8"   // Match sourceCompatibility
    }    
}

// dependencyResolutionManagement {
//     repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
//     repositories {
//         google()
//         mavenCentral()
//         maven {
//             url = uri("https://storage.googleapis.com/download.flutter.io")
//         }
//     }
// }

//rootProject.name = "ink.qbit.app" // Replace with your app name

//include(":app")

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
