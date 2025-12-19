#!groovy

//Keep this version in sync with the one used in Maven.pom-->
@Library('github.com/cloudogu/ces-build-lib@1.48.0')
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
                            description: 'GH Pages are deployed on main Branch only. If this box is checked it\'s deployed no what Branch is built.')
            ])
    ])

    def introSlidePath = 'docs/slides/01-intro.md'

    // Build image versions
    String mavenVersion = "3.8.3-openjdk-17-slim"

    // Params for Nexus deployment
    String mavenGroupId = "com.cloudogu.slides"
    String mavenArtifactId = "reveal.js-docker-example"
    String mavenSiteUrl = "https://ecosystem.cloudogu.com/nexus/content/sites/Cloudogu-Docs"

    // Params for Kubernetes deployment
    String dockerRegistry = ""
    String dockerRegistryCredentials = 'hub.docker.com-cesmarvin'
    String kubeconfigCredentials = 'kubeconfig-oss-deployer'

    // Params for GitHub pages deployment
    String ghPageCredentials = 'cesmarvin'

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
        String imageName = "${env.JOB_NAME}:${versionName}"
        String packagePath = 'target'
        forceDeployGhPages = Boolean.valueOf(params.forceDeployGhPages)
        def image

        stage('Build') {
            writeVersionNameToIntroSlide(versionName, introSlidePath)
            image = docker.build imageName

            // Extract rendered reveal webapp from container
            sh "tempContainer=\$(docker create ${image.id}) && " +
                    "docker cp \${tempContainer}:/usr/share/nginx/html ${packagePath} && " +
                    "docker rm \${tempContainer}"
        }

        stage('Print PDF & Package WebApp') {
            String pdfPath = "${packagePath}/${pdfName}"
            printPdf pdfPath
            // Avoid "ERROR: No artifacts found that match the file pattern " by using *.
            // Has the risk of archiving other PDFs that might be there
            archiveArtifacts "${packagePath}/*.pdf"

            // Make world readable (useful when accessing from docker)
            sh "chmod og+r '${pdfPath}'"

            // Use a constant name for the PDF for easier URLs, for deploying
            String finalPdfPath = "pdf/${createPdfName(false)}"
            sh "mkdir -p ${packagePath}/pdf/ pdf"
            sh "mv '${pdfPath}' '${packagePath}/${finalPdfPath}'"
            sh "cp '${packagePath}/${finalPdfPath}' '${finalPdfPath}'"
        }

        stage('Deploy GH Pages') {

            if (env.BRANCH_NAME == 'main' || forceDeployGhPages) {
                git.pushGitHubPagesBranch(packagePath, versionName)
            } else {
                echo "Skipping deploy to GH pages, because not on main branch"
            }
        }

        stage('Deploy Nexus') {
            if (params.deployToNexus) {
                mvn.useRepositoryCredentials([
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

String createPdfName(boolean includeDate = true) {
    String forbiddenChars = "[\\\\/:*?\"<>|]"
    String title = sh (returnStdout: true, script: 'grep -r \'TITLE\' Dockerfile | sed "s/.*TITLE=\'\\(.*\\)\'.*/\\1/" ')
            .trim()
            .replaceAll(forbiddenChars, '')

    String pdfName = ''
    if (includeDate) {
        pdfName = "${new Date().format('yyyy-MM-dd')}-"
    }
    pdfName += "${title}.pdf"
    return pdfName
}

String createVersion(Maven mvn) {
    // E.g. "201708140933-1674930"
    String versionName = "${new Date().format('yyyyMMddHHmm')}-${new Git(this).commitHashShort}"

    if (env.BRANCH_NAME == "main") {
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

void printPdf(String pdfPath) {
    sh (returnStdout: true, script: "COMPRESS=true ./printPdf.sh | xargs -I{} mv {} '${pdfPath}'").trim()
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
