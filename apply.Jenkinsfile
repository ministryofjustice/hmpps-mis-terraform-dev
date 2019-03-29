def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'
project.dcore     = 'hmpps-delius-core-terraform'
project.mis       = 'hmpps-mis-terraform-repo'

def environments = [
  'mis-nart-dev',
  'delius-mis-test',
]

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''
}

def plan_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}

def plan_submodule_deployment_type(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd env.MIS_DEPLOYMENT_TYPE/${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}


def apply_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
            cd ${submodule_name}; \
            terragrunt apply ${env_name}.plan"
        set -e
        """
    }
}

def apply_submodule_deployment_type(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
            cd env.MIS_DEPLOYMENT_TYPE/${submodule_name}; \
            terragrunt apply ${env_name}.plan"
        set -e
        """
    }
}

def confirm() {
    try {
        timeout(time: 15, unit: 'MINUTES') {
            env.Continue = input(
                id: 'Proceed1', message: 'Apply plan?', parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Apply Terraform']
                ]
            )
        }
    } catch(err) { // timeout reached or input false
        def user = err.getCauses()[0].getUser()
        env.Continue = false
        if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
            echo "Timeout"
            error("Build failed because confirmation timed out")
        } else {
            echo "Aborted by: [${user}]"
        }
    }
}

def do_terraform(config_dir, env_name, git_project, component) {
    if (plan_submodule(config_dir, env_name, git_project, component) == "2") {
        confirm()
        if (env.Continue == "true") {
            apply_submodule(config_dir, env_name, git_project, component)
        }
    }
    else {
        env.Continue = true
    }
}

def do_terraform_deployment_type(config_dir, env_name, git_project, component) {
    if (plan_submodule_deployment_type(config_dir, env_name, git_project, component) == "2") {
        confirm()
        if (env.Continue == "true") {
            apply_submodule_deployment_type(config_dir, env_name, git_project, component)
        }
    }
    else {
        env.Continue = true
    }
}

def debug_env() {
    sh '''
    #!/usr/env/bin bash
    pwd
    ls -al
    '''
}

pipeline {

    agent { label "jenkins_slave" }

    parameters {
        choice(
          name: 'environment_name',
          choices: environments,
          description: 'Select environment for creation or updating.'
        )
    }

    stages {

        stage('setup') {
            steps {
                slackSend(message: "Build started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }

                dir( project.mis ) {
                  git url: 'git@github.com:ministryofjustice/' + project.mis, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }

                prepare_env()
            }
        }

//        stage('Delius | MIS Common') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 'common')
//            }
//          }
//        }
//
//        stage('Delius | MIS Certs') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 'certs')
//            }
//          }
//        }
//
//        stage('Delius | MIS s3buckets') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 's3buckets')
//            }
//          }
//        }
//
//        stage('Delius | MIS iam') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 'iam')
//            }
//          }
//        }
//        stage('Delius | MIS security-groups') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 'security-groups')
//            }
//          }
//        }
//
//        stage('Delius | MIS Jumphost') {
//          steps {
//            script {
//              do_terraform(project.config, environment_name, project.mis, 'ec2-jumphost')
//            }
//          }
//        }
//
//        // stage('Delius | MIS ec2-ndl-ddb') {
//        //   steps {
//        //     script {
//        //       do_terraform(project.config, environment_name, project.mis, 'ec2-ndl-ddb')
//        //     }
//        //   }
//        // }
//
//        // stage('Delius | MIS ec2-ndl-bdb') {
//        //   steps {
//        //     script {
//        //       do_terraform(project.config, environment_name, project.mis, 'ec2-ndl-bdb')
//        //     }
//        //   }
//        // }

        stage('Delius | MIS ec2-ndl-dis') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-dis')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-dis-auto') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-dis-auto')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-bcs') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-bcs')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-bcs-auto') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-bcs-auto')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-bfs') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-bfs')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-bps') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-bps')
            }
          }
        }

        stage('Delius | MIS ec2-ndl-bws') {
          steps {
            script {
              do_terraform_deployment_type(project.config, environment_name, project.mis, 'ec2-ndl-bws')
            }
          }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "Build completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "Build failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}
