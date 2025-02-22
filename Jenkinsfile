pipeline {
    agent any

    environment {
        BASE_URL = credentials('BASE_URL')
    }

    stages {
        stage('Get Code') {
            steps {
                git url: 'https://github.com/Keji-dev/todo-list-aws.git', branch: 'master'
                sh 'wget https://raw.githubusercontent.com/Keji-dev/todo-list-aws-config/production/samconfig.toml'
            }
        }

        stage('Deploy') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '''
                        sam build
                        sam deploy --config-env production
                    '''
                }
            }
        }

        stage('Rest Test') {
            steps {
                sh '''
                    python3 -m pytest test/integration/todoApiTest.py -m read --maxfail=1
                '''
            }             
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}