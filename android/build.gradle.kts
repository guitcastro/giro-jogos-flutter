allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val rootBuildDir = File("../build")
rootProject.buildDir = rootBuildDir

subprojects {
    project.buildDir = File(rootBuildDir, project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
