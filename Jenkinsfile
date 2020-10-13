#!groovy

//Keep this version in sync with the one used in Maven.pom-->
@Library('github.com/cloudogu/ces-build-lib@1.35.1')
import com.cloudogu.ces.cesbuildlib.*

node('docker') {

    properties([
            // Keep only the last 10 build to preserve space
            buildDiscarder(logRotator(numToKeepStr: '10')),
            // Don't run concurrent builds for a branch, because they use the same workspace directory
            disableConcurrentBuilds(),
            parameters([
                    booleanParam(name: 'deployToNexus', defaultValue: false,
                            description: 'Deploying to Nexus takes about 3 Min since Nexus 3. That\'s why we skip it be default'),
                    booleanParam(name: 'deployToK8s', defaultValue: false,
                            description: 'Deploys to Kubernetes. We deploy to GitHub pages, so skip deploying to k8s by default.'),
                    booleanParam(defaultValue: false, name: 'forceDeployGhPages',
                            description: 'GH Pages are deployed on Master Branch only. If this box is checked it\'s deployed no what Branch is built.')
            ])
    ])

    def introSlidePath = 'docs/slides/01-intro.md'

    String dockerRegistry = ""
    String imageBaseName = "cloudogu/reveal.js-example"
    String dockerRegistryCredentials = 'hub.docker.com-cesmarvin'
    String ghPageCredentials = 'cesmarvin'
    String kubeconfigCredentials = 'kubeconfig-oss-deployer'
    
    String mavenGroupId = "com.cloudogu.slides"
    String mavenArtifactId = "reveal.js-docker-example"
    String mavenSiteUrl = "https://ecosystem.cloudogu.com/nexus/content/sites/Cloudogu-Docs"

    headlessChromeImage = 'buildkite/puppeteer:5.2.1'
    String mavenVersion = "3.6.2-jdk-8"
    
    Git git = new Git(this, ghPageCredentials)
    Docker docker = new Docker(this)
    Maven mvn = new MavenInDocker(this, mavenVersion)

    catchError {

        stage('Checkout') {
            checkout scm
            git.clean('')
        }

        String pdfName = createPdfName()

        String versionName = createVersion(mvn)
        String imageName = "${imageBaseName}:${versionName}"
        String packagePath = 'dist'
        forceDeployGhPages = Boolean.valueOf(params.forceDeployGhPages)
        def image

        stage('Build') {
            writeVersionNameToIntroSlide(versionName, introSlidePath)
            image = docker.build imageName
        }

        stage('Print PDF & Package WebApp') {
            String pdfPath = "${packagePath}/${pdfName}"
            printPdfAndPackageWebapp image, pdfName, packagePath
            archiveArtifacts pdfPath
            
            // Make world readable (useful when accessing from docker)
            sh "chmod og+r '${pdfPath}'"
            
            // Use a constant name for the PDF for easier URLs, for deploying
            String finalPdfPath = "pdf/${createPdfName(false)}"
            sh "mkdir -p ${packagePath}/pdf/ pdf"
            sh "mv '${pdfPath}' '${packagePath}/${finalPdfPath}'"
            sh "cp '${packagePath}/${finalPdfPath}' '${finalPdfPath}'"
            // Build image again, so PDF is added
            image = docker.build imageName
        }

        stage('Deploy GH Pages') {

            if (env.BRANCH_NAME == 'master' || forceDeployGhPages) {
                git.pushGitHubPagesBranch(packagePath, versionName)
            } else {
                echo "Skipping deploy to GH pages, because not on master branch"
            }
        }

        stage('Deploy Nexus') {
            if (params.deployToNexus) {
                mvn.useDeploymentRepository([
                        // Must match the one in pom.xml!
                        id           : 'ecosystem.cloudogu.com',
                        credentialsId: 'ces-nexus'
                ])
                mvn.deploySiteToNexus(
                        "-Dgroup=${mavenGroupId} " +
                        "-Dartifact=${mavenArtifactId} " + 
                        "-DsiteUrl=${mavenSiteUrl} "
                )
            } else {
                echo "Skipping deployment to Nexus because parameter is set to false."
            }
        }

        stage('Deploy Kubernetes') {
            if (params.deployToK8s) {
                deployToKubernetes(dockerRegistry, dockerRegistryCredentials, kubeconfigCredentials, image)
            } else {
                echo "Skipping deployment to Kubernetes because parameter is set to false."
            }
        }
    }

    mailIfStatusChanged(git.commitAuthorEmail)
}

String headlessChromeImage

String createPdfName(boolean includeDate = true) {
    String title = sh (returnStdout: true, script: 'grep -r \'TITLE\' Dockerfile | sed "s/.*TITLE=\'\\(.*\\)\'.*/\\1/" ').trim()
    String pdfName = '';
    if (includeDate) {
        pdfName = "${new Date().format('yyyy-MM-dd')}-"
    }
    pdfName += "${title}.pdf"
    return pdfName
}

String createVersion(Maven mvn) {
    // E.g. "201708140933-1674930"
    String versionName = "${new Date().format('yyyyMMddHHmm')}-${new Git(this).commitHashShort}"

    if (env.BRANCH_NAME == "master") {
        mvn.additionalArgs = "-Drevision=${versionName} "
        currentBuild.description = versionName
        echo "Building version $versionName on branch ${env.BRANCH_NAME}"
    } else {
        versionName += '-SNAPSHOT'
    }
    return versionName
}

void writeVersionNameToIntroSlide(String versionName, String introSlidePath) {
    def distIntro = "${introSlidePath}"
    String filteredIntro = filterFile(distIntro, "<!--VERSION-->", "Version: $versionName")
    sh "cp $filteredIntro $distIntro"
    sh "mv $filteredIntro $introSlidePath"
}

void printPdfAndPackageWebapp(def image, String pdfName, String distPath) {
    Docker docker = new Docker(this)

    image.withRun("-v ${WORKSPACE}:/workspace -w /workspace") { revealContainer ->

        // Extract rendered reveal webapp from container for further processing
        sh "docker cp ${revealContainer.id}:/reveal '${distPath}'"

        def revealIp = docker.findIp(revealContainer)
        
        docker.image(headlessChromeImage)
                // Chromium writes to $HOME/local, so we need an entry in /etc/pwd for the current user
                .mountJenkinsUser()
                // Try to avoid OOM for larger presentations by setting larger shared memory
                .inside("--shm-size=4G") {
                    // --no-optional -> Don't install chrome, it's already inside the image
                    sh 'npm install --no-optional puppeteer-cli'
                    sh "wait-for-it.sh ${revealIp}:8080 -- node_modules/.bin/puppeteer --sandbox=false print http://${revealIp}:8080/?print-pdf '${distPath}/${pdfName}'"
                }
    }
}

void deployToKubernetes(String dockerRegistry, String dockerRegistryCredentials, String kubeconfigCredentials, image) {

    docker.withRegistry(dockerRegistry ? "https://${dockerRegistry}" : '', dockerRegistryCredentials) {
        image.push()
        image.push('latest')
    }

    withCredentials([file(credentialsId: kubeconfigCredentials, variable: 'kubeconfig')]) {

        withEnv(["IMAGE_NAME=${image.imageName()}"]) {

            kubernetesDeploy(
                    credentialsType: 'KubeConfig',
                    kubeConfig: [path: kubeconfig],

                    configs: 'k8s.yaml',
                    enableConfigSubstitution: true
            )
        }
    }
}

/**
 * Filters a {@code filePath}, replacing an {@code expression} by {@code replace} writing to new file, whose path is returned.
 *
 * @return path to filtered file
 */
String filterFile(String filePath, String expression, String replace) {
    String filteredFilePath = filePath + ".filtered"
    // Fail command (and build) if file not present
    sh "test -e ${filePath} || (echo Title slide ${filePath} not found && return 1)"
    sh "cat ${filePath} | sed 's/${expression}/${replace}/g' > ${filteredFilePath}"
    return filteredFilePath
}
