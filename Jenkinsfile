pipeline {
    agent any

    stages {
        stage('Get Code') {
            git url: 'https://github.com/Keji-dev/todo-list-aws.git', branch: 'master'
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
                    python3 -m pytest test/integration/todoApiTest.py -m api --maxfail=1 --disable-warnings
                '''
            }             
        }
    }
}