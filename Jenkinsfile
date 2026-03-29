pipeline {
    agent any

    environment {
        IMAGE_NAME        = "george-koufie-portfolio"
        CONTAINER_NAME    = "portfolio"
        PORTFOLIO_SERVER  = credentials('PORTFOLIO_SERVER_IP')   // EC2 IP stored in Jenkins credentials
        SSH_KEY           = credentials('PORTFOLIO_SSH_KEY')     // .pem file stored in Jenkins credentials
        SONAR_TOKEN       = credentials('SONAR_TOKEN')           // SonarQube token stored in Jenkins credentials
        SONAR_HOST_URL    = "http://sonarqube:9000"
    }

    stages {

        // ── Stage 1: Checkout ──────────────────────────────
        stage('Checkout') {
            steps {
                echo '>>> Checking out source code...'
                checkout scm
            }
        }

        // ── Stage 2: SonarQube Scan ────────────────────────
        stage('SonarQube Scan') {
            steps {
                echo '>>> Running SonarQube analysis...'
                withSonarQubeEnv('SonarQube') {
                    sh """
                        sonar-scanner \
                            -Dsonar.projectKey=george-koufie-portfolio \
                            -Dsonar.projectName="George Koufie Portfolio" \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/node_modules/**,**/assets/fonts/**,resume/**,scripts/** \
                            -Dsonar.inclusions=**/*.html,**/*.css,**/*.js \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.token=${SONAR_TOKEN}
                    """
                }
            }
        }

        // ── Stage 3: Quality Gate ──────────────────────────
        stage('Quality Gate') {
            steps {
                echo '>>> Checking SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ── Stage 4: Build Docker Image ────────────────────
        stage('Build Docker Image') {
            steps {
                echo '>>> Building Docker image...'
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
                echo ">>> Image built: ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }

        // ── Stage 5: Deploy to Portfolio EC2 ──────────────
        stage('Deploy') {
            steps {
                echo '>>> Deploying to portfolio server...'
                sh """
                    # Save the Docker image as a tar file
                    docker save ${IMAGE_NAME}:latest | gzip > portfolio-image.tar.gz

                    # Copy image to portfolio EC2
                    scp -i ${SSH_KEY} \
                        -o StrictHostKeyChecking=no \
                        portfolio-image.tar.gz \
                        ubuntu@${PORTFOLIO_SERVER}:~/portfolio-image.tar.gz

                    # SSH into portfolio EC2 and deploy
                    ssh -i ${SSH_KEY} \
                        -o StrictHostKeyChecking=no \
                        ubuntu@${PORTFOLIO_SERVER} '
                            docker load < ~/portfolio-image.tar.gz
                            docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                            docker run -d \
                                -p 80:80 \
                                --name ${CONTAINER_NAME} \
                                --restart always \
                                ${IMAGE_NAME}:latest
                            rm -f ~/portfolio-image.tar.gz
                            echo "Container running:"
                            docker ps | grep ${CONTAINER_NAME}
                        '

                    # Clean up tar on CI server
                    rm -f portfolio-image.tar.gz
                """
            }
        }

        // ── Stage 6: Health Check ──────────────────────────
        stage('Health Check') {
            steps {
                echo '>>> Running health check...'
                sh """
                    sleep 5
                    HTTP_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://${PORTFOLIO_SERVER})
                    echo "HTTP Status: \$HTTP_STATUS"
                    if [ "\$HTTP_STATUS" != "200" ]; then
                        echo "Health check FAILED — HTTP \$HTTP_STATUS"
                        exit 1
                    fi
                    echo "Health check PASSED"
                """
            }
        }
    }

    // ── Post Actions ────────────────────────────────────────
    post {
        success {
            echo """
            ================================================
              Pipeline PASSED
              Build:  #${BUILD_NUMBER}
              Site:   http://${PORTFOLIO_SERVER}
            ================================================
            """
        }
        failure {
            echo """
            ================================================
              Pipeline FAILED at stage: ${STAGE_NAME}
              Build: #${BUILD_NUMBER}
              Check the logs above for details.
            ================================================
            """
        }
        always {
            // Clean up dangling Docker images on CI server
            sh 'docker image prune -f || true'
        }
    }
}