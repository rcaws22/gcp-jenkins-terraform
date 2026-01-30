pipeline {
    agent {
        label 'slave'
    }
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'test', 'stage', 'prod'],
            description: 'Select Environment'
        )
        choice(
            name: 'ACTION',
            choices: "validate\nplan\napply\ndestroy",
            description: 'Choose terraform workflow'
        )
    }
    environment {
        GCS_BUCKET = "ancient-tractor-462500-u5-tf"
        GOOGLE_APPLICATION_CREDENTIALS = "${WORKSPACE}/sa-key.json"
        TFVARS_FILE = "${params.ENVIRONMENT}.tfvars"
    }
    stages {
        stage ('Setup GCE Auth') {
            steps {
                    withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'SA_KEY')]) {
                        sh '''
                            cp $SA_KEY $GOOGLE_APPLICATION_CREDENTIALS
                        '''
                    }
                }
        }
        stage('init') {
            steps {
                sh """
                    terraform init  -backend-config="bucket=${env.GCS_BUCKET}" -backend-config="prefix=${params.ENVIRONMENT}"
                """
            }
        }
        stage('validate') {
            when {
                expression {
                    params.ACTION == 'validate'
                }
            }
            steps {
                sh """
                    terraform validate  
                """
            }
        }
        stage ('Plan') {
            when {
                expression {
                    params.ACTION == 'plan'
                }
            }
            steps {
                sh """
                    terraform plan -var-file=${TFVARS_FILE}
                """
            }
        }
        stage ('apply') {
            when {
                expression {
                    params.ACTION == 'apply'
                }
            }
            steps {
                timeout (time: 300, unit: 'SECONDS') {
                    input message: 'Are you sure to apply changes ?', ok:'yes', submitter: 'i27academy,sreuser'
                }
                sh """
                    terraform apply -var-file=${TFVARS_FILE} --auto-approve 
                """
            }
        }
        stage ('destroy') {
            when {
                expression {
                    params.ACTION == 'destroy'
                }
            }
            steps {
                timeout (time: 300, unit: 'SECONDS') {
                    input message: 'Are you sure to destroy Infra ?', ok:'yes', submitter: 'i27academy,sreuser'
                }
                sh """
                    terraform destroy -var-file=${TFVARS_FILE} --auto-approve 
                """
            }
        }
    }
    post {
        always {
            echo "Cleaning the workspace"
            cleanWs()
        }
    }
}
