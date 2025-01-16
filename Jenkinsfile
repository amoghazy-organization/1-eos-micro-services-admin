pipeline {
    agent {
        kubernetes {
              label 'agent'
            defaultContainer 'build'
   
        }
    }
    environment {
        IMAGE_NAME = "amoghazy/eos-micro-services-admin"
      
    }
    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: '', url: 'https://github.com/amoghazy-organization/1-eos-micro-services-admin', branch: 'main'
            }
        }

        stage('Build a Maven Project') {
            steps {
                container('build') {
                    sh './mvnw clean package'
                   
                }
            }
        }

        stage('Sonar Scan') {
            steps {
                container('build') {
                    withSonarQubeEnv('sonar') {
                        sh './mvnw verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=ecom_ecom'
                    }
                }
            }
        }

 
 

        stage('Artifactory Configuration') {
            steps {
                container('build') {
                    rtServer(
                        id: "jfrog",
                        url: "https://triallekevd.jfrog.io/artifactory",
                        credentialsId: "jfrog-cred"
                    )

                    rtMavenDeployer(
                        id: "MAVEN_DEPLOYER",
                        serverId: "jfrog",
                        releaseRepo:  "ecom-libs-release-local",
                        snapshotRepo: "ecom-libs-release-local"
                    )

                    rtMavenResolver(
                        id: "MAVEN_RESOLVER",
                        serverId: "jfrog",
                        releaseRepo: "ecom-libs-release",
                        snapshotRepo: "ecom-libs-release"
                    )
                }
            }
        }


        stage('Deploy Artifacts') {
            steps {
                container('build') {
                    withEnv(["JAVA_HOME=/opt/java/openjdk/jdk-21"]) {
                        rtMavenRun(
                            tool: "maven",
                            useWrapper: true,
                            pom: 'pom.xml',
                            goals: 'deploy',  
                            deployerId: "MAVEN_DEPLOYER",
                            resolverId: "MAVEN_RESOLVER"
                        )
                    }
                }
            }
        }

        

        stage('Publish Build Info') {
            steps {
                container('build') {
                    rtPublishBuildInfo(serverId: "jfrog")
                }
            }
        }
      

        stage('Docker Build & Push') {
            steps {
                container('build') {
                    withDockerRegistry(url: 'https://index.docker.io/v1/', credentialsId: 'docker') {
                        script {
                            
                            def customImage = docker.build("${IMAGE_NAME}:latest")
                            customImage.push()
                        }
                    }

                }
            }
        }


         stage('Helm Chart Deployment') {
            steps {
                container('build') {
                    dir('charts') {
                        withCredentials([usernamePassword(credentialsId: 'jfrog-cred', usernameVariable: 'username', passwordVariable: 'password')]) {
                          sh ''' 
                           
                            /usr/local/bin/helm package micro-services-admin
                            curl -u ecomadmin:$password -T /home/jenkins/agent/workspace/micro-svc-admin-build/charts/micro-services-admin-1.0.tgz "https://triallekevd.jfrog.io/artifactory/ecom-helm-local/micro-services-admin-1.0.tgz"
                            
                            '''


                        }
                    }
                }
            }
        }
    }
}
