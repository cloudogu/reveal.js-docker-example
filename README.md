![](https://cloudogu.com/assets/blog/2019/revealJS-711db5dd3e495fe26dda7ad44104542b1fceb456c11700a773a2f158bf2c8251.png)

# reveal.js-docker-example
[![Build Status](https://oss.cloudogu.com/jenkins/buildStatus/icon?job=cloudogu-github%2Freveal.js-docker-example%2Fmaster)](https://oss.cloudogu.com/jenkins/blue/organizations/jenkins/cloudogu-github%2Freveal.js-docker-example/branches/)
[![](https://img.shields.io/microbadger/layers/cloudogu/reveal.js-example)](https://hub.docker.com/r/cloudogu/reveal.js-example)
[![](https://img.shields.io/docker/image-size/cloudogu/reveal.js-example)](https://hub.docker.com/r/cloudogu/reveal.js-example)

Advanced example of [cloudogu/reveal.js-docker](https://github.com/cloudogu/reveal.js-docker), 
providing easy to use, opinionated reveal.js web apps - web-based slides/presentations.

Evolution of [cloudogu/continuous-delivery-slides](https://github.com/cloudogu/continuous-delivery-slides).

Provides

* [example slides](docs/slides) in markdown, showcasing the features (see [rendered version](https://cloudogu.github.io/reveal.js-docker-example)),
* scripts [linux](startPresentation.sh) / [windows](startPresentation.ps1) to start slide Development mode (changes on 
  the slides lead to automatic reloads in the browser):
  * Start with 
    * Linux: `./startPresentation.sh`
    * Windows: Right Click on `startPresentation.ps1` then `Run with PowerShell`.
  * Presentation is served at http://localhost:8000
  * This fails if either one of the port `8000` or `35729` is already blocked.
  * You can stop the presentation container by finding the `CONTAINER_ID` using `docker ps`,
    then `docker rm -f <CONTAINER_ID`.
  * Linux users can avoid port conflicts (e.g. with multiple presentations running) by using  
    `./startPresentation.sh internal`  
    which results in no port bindings to localhost. Instead, the internal IP of the docker container is used
* a [`Dockerfile`](Dockerfile) that creates an image containing a web-server that serves the presentation as a
  completely static website:  
  * Build with `docker build -t presentation`
  * Run with `docker run --rm -p 8080:8080 presentation`
  * Presentation is served at http://localhost:8080
  * For demo purposes have a look at the Image built by this repo:  
    `docker run --rm -p 8080:8080 cloudogu/reveal.js-example` 
* a [script for printing pdf locally](printPdf.sh)
* [Kubernetes Resources](k8s.yaml) for running the Docker Image on K8s securely
* a [maven POM](pom.xml) for deploying the presentation as a maven site into a Raw Nexus Repository and finally 
* a [Jenkins continuous delivery pipeline](Jenkinsfile) that showcases how to deploy 
  * to Nexus repo,
  * GitHub Pages and
  * Kubernetes.
* The pipeline also creates a PDF export of the slides.

See also our Blog Posts: Docs As Code - Continuous Delivery of Presentations with reveal.js and Jenkins
* [Part 1 - Intro and Deployment to GitHub Pages 🇬🇧](https://cloudogu.com/en/blog/continuous-delivery-with-revealjs) | [🇩🇪](https://cloudogu.com/de/blog/continuous-delivery-mit-revealjs)
* [Part 2 - Deployment to Nexus and Kubernetes 🇬🇧](https://cloudogu.com/en/blog/continuous-delivery-with-revealjs-part-2) | [🇩🇪](https://cloudogu.com/de/blog/continuous-delivery-mit-revealjs-teil-2)

You can view the latest version of the presentation 
* [as web-based presentation](https://cloudogu.github.io/reveal.js-docker-example) and
* as PDF [on the web](https://cloudogu.github.io/reveal.js-docker-example/pdf/Cloudogu%20-%20reveal.js-docker.pdf)
  or [on Jenkins](https://oss.cloudogu.com/jenkins/job/cloudogu-github/job/reveal.js-docker-example/job/master/lastSuccessfulBuild/artifact/)

With a git-based wiki such as [Smeagol](https://github.com/cloudogu/smeagol) 
(see [Blog Post](https://cloudogu.com/blog/smeagol)) you can edit the slides conveniently from the browser. A change there will trigger the  the [Jenkins](https://jenkins.io/) pipeline that deploys to 
* [Sonatype Nexus](https://www.sonatype.com/nexus-repository-oss) or 
* [Kubernetes](https://kubernetes.io/).

This example also shows how to deploy deploy your GitHub repo to [GitHub Pages](https://pages.github.com/).

The workflow with a Cloudogu Ecosystem and GitHub are shown bellow.

|Cloudogu Ecosystem  | GitHub   |
|--------------------|----------|
|[![Workflow with Cloudogu Ecosystem](http://www.plantuml.com/plantuml/svg/ZP1VQzim5CMVfqznc-t1WpX-3QM4bjIKDOazvWRsLbpfrj6YFqPNsbR6llkaLbd3nbZyO0xd_93EqINvtlcW5JiJ-2WDmdBTRg_Rc-tsqnfstezqNbMk_pORfD-5Xq3ek3KUZPzngokkR11s2DMeUfFEAGzEIQEJ7gdIFNbqx4mQheB0uDJn7HMtMbip6rE7Vp7fFAg-eDbBGwUWXnAdiCJrIPZ6Vh3g5DJWz_2VcjvQHTL-dZ7MM84mMURQK7DBJ-HHJw0du4XmSV7kC6gnW1_iJJhf_hPkLX-QhiXFCuNR5_4UtZu-VvdhbfiYxfn25EMcD_s0xYzcKr_TjEiY3utiY_YJQ-hFswvutZXjqlyL-CdONTkkxrVpheZRfh0A3-WCUZo2s1Ntre70hwZiY8wntnBASW7vVZY7IIsaXqv9WJHX1pyXNCVuOw0TYp8v-G6YU-VaCA1ZsKbXwfgYQnoLVNfDOhIV7mNi4eq8Mlq2)](http://www.plantuml.com/plantuml/uml/ZP1VQzim5CMVfqznc-t1WpX-3QM4bjIKDOazvWRsLbpfrj6YFqPNsbR6llkaLbd3nbZyO0xd_93EqINvtlcW5JiJ-2WDmdBTRg_Rc-tsqnfstezqNbMk_pORfD-5Xq3ek3KUZPzngokkR11s2DMeUfFEAGzEIQEJ7gdIFNbqx4mQheB0uDJn7HMtMbip6rE7Vp7fFAg-eDbBGwUWXnAdiCJrIPZ6Vh3g5DJWz_2VcjvQHTL-dZ7MM84mMURQK7DBJ-HHJw0du4XmSV7kC6gnW1_iJJhf_hPkLX-QhiXFCuNR5_4UtZu-VvdhbfiYxfn25EMcD_s0xYzcKr_TjEiY3utiY_YJQ-hFswvutZXjqlyL-CdONTkkxrVpheZRfh0A3-WCUZo2s1Ntre70hwZiY8wntnBASW7vVZY7IIsaXqv9WJHX1pyXNCVuOw0TYp8v-G6YU-VaCA1ZsKbXwfgYQnoLVNfDOhIV7mNi4eq8Mlq2) | [![Worflow with GitHub](http://www.plantuml.com/plantuml/svg/dPDlJren5CPVhv_YY7l14k7gJ0mnXgY8JZ5S9v8iMPQRSdkyTFIsT_qZCyk--tfBnyLiCsHzGKgVNv_dz70uDPPgwqf1TXW-Seamk4sd5-dLT7f_2tDhAtES99ekkmMtSpTp1dMkf4LfkxagarmenrJXaafGMVjqVfzqJAMvHPEKr5ZKXEnmcGl7q6cn6PBKi4c-ebnmQRgLztWTNMTkmvgyt0ehaHPAR8DA_ExCww1LIfXaqOlOkhNNWtIyNLkjgoZJXqrNkLSxZvvOj_NfeBlVtNzHG_HFl4EfP0Z_gyxmgVOpoIeyeyB-6mwXT8b6bLXVoCmtHpLkUM795xn2nccstFB6JAb5x1inVYGggca9L6krX1y4OA24qh2x7nRvkGb9nJ0mvpHV55evoIBz_f0UCbOhIZFKyVJWwAZNywSlNMXkbVuV6xXKqlvHthWkgZM8Cml3N9bdOx5i0L03EHeuENcRHxdVzy5lwZdAReRZqVLuqev_Z3suMMtUmUvZM94R3pzD9-qmbNlZ-hC1VBeCwLVSVd2pLXrOpA4ER7vv7ndvyERBi-pg-Y6RV9oUtG_RnLnZfVQ20zpxRQjn3-nvceuyLT42VOan2Exghn6DXP27DBtDHhr9Uz7pvCZDK4kqQ1gAh3hlfnE5gb2JLJfqFiyvOoY_z24c4HAx0fq-XAV3CLnW9THpetZ9HpK2MHi7BPeVGsl8k8M9uCpN73C34Pqyyg1vKQ3UJ8sLUF7EcJavHSbSANu1)](http://www.plantuml.com/plantuml/uml/dPDlJren5CPVhv_YY7l14k7gJ0mnXgY8JZ5S9v8iMPQRSdkyTFIsT_qZCyk--tfBnyLiCsHzGKgVNv_dz70uDPPgwqf1TXW-Seamk4sd5-dLT7f_2tDhAtES99ekkmMtSpTp1dMkf4LfkxagarmenrJXaafGMVjqVfzqJAMvHPEKr5ZKXEnmcGl7q6cn6PBKi4c-ebnmQRgLztWTNMTkmvgyt0ehaHPAR8DA_ExCww1LIfXaqOlOkhNNWtIyNLkjgoZJXqrNkLSxZvvOj_NfeBlVtNzHG_HFl4EfP0Z_gyxmgVOpoIeyeyB-6mwXT8b6bLXVoCmtHpLkUM795xn2nccstFB6JAb5x1inVYGggca9L6krX1y4OA24qh2x7nRvkGb9nJ0mvpHV55evoIBz_f0UCbOhIZFKyVJWwAZNywSlNMXkbVuV6xXKqlvHthWkgZM8Cml3N9bdOx5i0L03EHeuENcRHxdVzy5lwZdAReRZqVLuqev_Z3suMMtUmUvZM94R3pzD9-qmbNlZ-hC1VBeCwLVSVd2pLXrOpA4ER7vv7ndvyERBi-pg-Y6RV9oUtG_RnLnZfVQ20zpxRQjn3-nvceuyLT42VOan2Exghn6DXP27DBtDHhr9Uz7pvCZDK4kqQ1gAh3hlfnE5gb2JLJfqFiyvOoY_z24c4HAx0fq-XAV3CLnW9THpetZ9HpK2MHi7BPeVGsl8k8M9uCpN73C34Pqyyg1vKQ3UJ8sLUF7EcJavHSbSANu1)   |

# Build

See [`Jenkinsfile`](Jenkinsfile).

* Makes excessive use of the Jenkins shared library [ces-build-lib](https://github.com/cloudogu/ces-build-lib)
* Deploys the presentation to
  * GitHub Pages branch of this repo. To do so, username and password credentials `cesmarvin` need to be defined in Jenkins. 
    A best practice is to create an [access token](https://github.com/settings/tokens). These credentials must have write 
    access on the GitHub repo.  
    See [here](https://cloudogu.github.io/continuous-delivery-slides/) for the result.
  * Nexus site repo defined in [`pom.xml`](pom.xml). 
    * Username and password credentials `ces-nexus` need to be defined in Jenkins.  
    * These credentials must have write access to the maven site in Nexus:
      * `nx-repository-view-raw-<RepoName>-add` and 
      * `nx-repository-view-raw-<RepoName>-edit` 
      * Where `RepoName` is defined in `pom.xml`'s `url` and `distributionManagement.site.url`s (after `/repository/`)
      * In this example: `nx-repository-view-raw-Cloudogu-Docs-add`
    * We need a `raw` Repo called `Cloudogu-Docs` in Nexus. 
  * the Kubernetes cluster identified by the `kubeconfig` and the Docker registry defined in [`Jenkinsfile`](Jenkinsfile)
    * Docker Registry: Requires username and password credentials `hub.docker.com-cesmarvin` defined in Jenkins.  
      In this example the image `cloudogu/continuous-delivery-slides` is deployed to Docker Hub.
    * Kubernetes: Requires `kubeconfig` file defined as Jenkins file credential `kubeconfig-oss-deployer`. 
      An example for creating the kubeconfig (using `create-kubeconfig` from [zlabjp/kubernetes-scripts](https://github.com/zlabjp/kubernetes-scripts/blob/master/create-kubeconfig)):
      ```bash
      kubectl create namespace jenkins-ns
      kubectl create serviceaccount jenkins-sa --namespace=jenkins-ns
      kubectl create rolebinding jenkins-ns-admin --clusterrole=admin --namespace=jenkins-ns --serviceaccount=jenkins-ns:jenkins-sa
      ./create-kubeconfig jenkins-sa --namespace=jenkins-ns > kubeconfig
      ```
* Needs Docker available on the jenkins worker
* On failure, sends emails to git commiter.