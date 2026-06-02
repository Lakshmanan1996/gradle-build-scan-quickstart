pipeline {

    agent none

    tools {
        maven 'Maven'
        gradle 'Gradle'
        
        
    }

    environment {

        IMAGE1       = "gradle"
        DOCKERHUB_USER = "lakshvar96"
        GIT_REPO = "https://github.com/Lakshmanan1996/gradle-build-scan-quickstart.git"
    }
    
   /* =====================================================   
   CHECKOUT
    ===================================================== */

    stages {

        stage('Checkout Code') {
            agent { label 'workernode1' }
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[url: "${GIT_REPO}"]]
                ])
            }
        }


        stage('Stash Source') {
            agent { label 'workernode1' }
            steps {
                stash includes: '**/*', name: 'source-code'
            }
        }


        /* ===================== Build gradle Stage ===================== */
        stage('Build') {
            agent { label 'workernode1' }
            
                    
            steps {
                unstash 'source-code'
                sh 'gradle clean build -x test'
            }
        }

        /* =====================================================
           SONARQUBE ANALYSIS
        ===================================================== */

        stage('SonarQube Analysis') {
            agent { label 'workernode2' }
            steps {
                unstash 'source-code'
                script {
                    def scannerHome = tool 'SonarQubeScanner'
                    
                    withSonarQubeEnv('sonarqube') {
                        dir('EmployeeManagement') {
                        sh """
                             gradle clean build -x test \
                             -DskipTests \
                             -Dsonar.projectKey=gradle \
                             -Dsonar.projectName=gradle \
                        """
                        }
                        
                    }
                }
            }
        }

        /* =====================================================
           QUALITY GATE
        ===================================================== */

        stage('Quality Gate') {
            agent { label 'workernode2' }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* =====================================================
           OWASP DEPENDENCY CHECK
        ===================================================== */

        stage('OWASP Dependency Check') {
            agent { label 'workernode2' }

            steps {
                unstash 'source-code'

                dependencyCheck(
                    odcInstallation: 'OWASP-DC',
                    additionalArguments: '''
                        --scan ${WORKSPACE}
                        --format ALL
                        --out ${WORKSPACE}/dependency-check-report

                        --data /var/jenkins_home/odc-data
                        --noupdate

                        --nvdApiKey YOUR_NVD_API_KEY

                        --exclude **/node_modules/**
                        --exclude **/dist/**
                        --exclude **/target/**
                        --exclude **/.git/**
                    '''
                )   
            }
        }

        /* =====================================================
           DOCKER BUILD
        ===================================================== */

        stage('Docker Build') {
            agent { label 'workernode3' }
            steps {
                unstash 'source-code'
                
                echo "Build a image for gradle-project"
                
                
                sh """
                docker build -t ${DOCKERHUB_USER}/${IMAGE1}:${BUILD_NUMBER} .
                docker tag ${DOCKERHUB_USER}/${IMAGE1}:${BUILD_NUMBER} ${DOCKERHUB_USER}/${IMAGE1}:latest 
                """
                
                
                
            }
        }

        /* =====================================================
           TRIVY IMAGE SCAN
        ===================================================== */

        stage('Trivy Scan') {
            agent { label 'workernode3' }
            steps {
                sh """
                trivy image --exit-code 0 --severity HIGH,CRITICAL ${DOCKERHUB_USER}/${IMAGE1}:${BUILD_NUMBER}
                
                """
            }
        }

         /* =====================================================
           DOCKER PUSH
        ===================================================== */

        stage('Push Image') {
            agent { label 'workernode3' }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }

                sh """
                docker push ${DOCKERHUB_USER}/${IMAGE1}:${BUILD_NUMBER}
                docker push ${DOCKERHUB_USER}/${IMAGE1}:latest
                """

                                     
            }
        }
    }

    post {
        success {
            echo "✅ gradle CI Pipeline SUCCESS"
        }
        failure {
            echo "❌ gradle CI Pipeline FAILED"
        }
    }
}
