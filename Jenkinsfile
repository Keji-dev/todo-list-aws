pipeline {
    agent any

    environment {
        GITHUB_TOKEN = credentials('github-token')
    }
    
    stages {
        stage('Clean Workspace') {
            steps{
                cleanWs()
            }
        }

        stage('Get Code') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        git clone https://$GITHUB_TOKEN@github.com/Keji-dev/todo-list-aws.git .
                        git checkout develop
                    '''
                }
            }
        }

        stage('Static Test') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '''
                        TIMEOUT=300
                        TIME_ELAPSED=0

                        python3 -m flake8 --exit-zero --format=pylint src > flake8.out

                        until [ -f flake8.out ]; do
                            if [ $TIME_ELAPSED -ge $TIMEOUT ]; then
                                echo "[ERROR] Unable to find flake8.out in the directory after $TIMEOUT seconds, stopping pipeline..."
                            fi
                            sleep 3
                        done
                        
                        # Executing Bandit test

                        bandit -r /src -f custom -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {msg}" || exit 0
                        
                        TIMEOUT=300
                        TIME_ELAPSED=0

                        until [ -f bandit.out ]; do
                            if [ $TIME_ELAPSED -ge $TIMEOUT ]; then
                                echo "[ERROR] Unable to find bandit.out in the directory after $TIMEOUT seconds, stopping pipeline..."
                            fi
                            sleep 3
                        done
                    '''
                    recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out')]
                    recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')]
                }
            }
        }

        stage('Deploy') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '''
                        sam build
                        sam deploy --config-env staging 
                    '''
                }
            }
        }

        stage('Rest Test') {
            steps {
                sh '''
                    python3 -m pytest test/integration/todoApiTest.py --maxfail=1
                '''
            }             
        }

        stage('Promote') {
            steps {
                script {
                    try {
                        sh '''
                            git checkout master
                            git pull origin master
                            git merge --no-ff -X theirs develop
                            git restore --source=master -- Jenkinsfile
                            git push origin master
                        '''
                    } catch (Exception e) {
                        error "Merge failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}