allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.android.support" && !requested.name.startsWith("multidex")) {
                useVersion("28.0.0")
            }
        }
    }
}

subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            android.compileSdkVersion(35)
        }
    }
}

subprojects {
    if (project.path != ":app") {
        evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
