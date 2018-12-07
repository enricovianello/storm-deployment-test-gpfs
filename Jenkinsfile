def testsuite_job

pipeline {

  agent { label 'generic' }

  options {
    timeout(time: 3, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
  }

  parameters {
    choice(name: 'MODE', choices: "clean\nupdate", description: '')

    string(name: 'TESTSUITE_BRANCH', defaultValue: 'nightly', description: 'Testsuite branch')
    string(name: 'TESTSUITE_EXCLUDE', defaultValue: "to-be-fixedORcdmi", description: '')
    string(name: 'TESTSUITE_SUITE', defaultValue: "tests", description: '')

    string(name: 'STORM_REPO', defaultValue: "https://repo.cloud.cnaf.infn.it/repository/storm/nightly/storm-nightly-centos6.repo", description: '')
  }

  environment {
    REPOSITORY = "https://github.com/italiangrid/storm-deployment-test"
    BRANCH = "gpfs"
    VM_IMAGE = "centos-6-1804-x86_64-generic-gpfs-client-certs"
    VM_NAME = "cloud-vm127"
    VM_FLOATING_IP = "131.154.96.127"
    VM_FLAVOR = "m1.medium"
    VM_FQDN = "cloud-vm127.cloud.cnaf.infn.it"
    STORAGE_ROOT_DIR = "/storage/${BUILD_TAG}"
    PLATFORM = "centos6"
  }

  stages {
    stage('destroy-vm'){
      steps {
        container('generic-runner') {
          sh "sh scripts/delete-if-exists.sh ${env.VM_NAME}"
        }
      }
    }
    stage('deploy'){
      steps {
        container('generic-runner') {
          withCredentials([
            usernamePassword(credentialsId: 'openstack-mw-devel-user', passwordVariable: 'mw_password', usernameVariable: 'mw_username')
          ]) {
            sh """
cat <<EOF >>deployment.tfvars
storm_repo = "${params.STORM_REPO}"
mw_username = "${mw_username}"
mw_password = "${mw_password}"
mode = "${params.MODE}"
platform = "${env.PLATFORM}"
storage_root_dir = "${env.STORAGE_ROOT_DIR}"
EOF
terraform init -input=false
terraform plan -var-file='deployment.tfvars' -out=tfplan -input=false
terraform apply -input=false tfplan
"""
          }
        }
      }
    }
    stage("tests") {
      steps {
        script {
          testsuite_job = build job: "storm-testsuite_runner/${params.TESTSUITE_BRANCH}", parameters: [
            string(name: 'TESTSUITE_BRANCH', value: params.TESTSUITE_BRANCH),
            string(name: 'STORM_BE_HOST', value: env.VM_FQDN),
            string(name: 'TESTSUITE_EXCLUDE', value: params.TESTSUITE_EXCLUDE),
            string(name: 'STORM_STORAGE_ROOT_DIR', value: env.STORAGE_ROOT_DIR)
          ], propagate: false, wait: true
          currentBuild.result=testsuite_job.result
        }
        step ([$class: 'CopyArtifact',
          projectName: 'storm-testsuite_runner',
          selector: [$class: 'SpecificBuildSelector', buildNumber: "${testsuite_job.getNumber()}"]
        ])
        archiveArtifacts "reports/**"
        step([$class: 'RobotPublisher',
          disableArchiveOutput: false,
          logFileName: 'log.html',
          otherFiles: '*.png',
          outputFileName: 'output.xml',
          outputPath: "reports",
          passThreshold: 100,
          reportFileName: 'report.html',
          unstableThreshold: 90])
      }
    }
    stage('get-logs'){
      steps {
        container('generic-runner') {
          sh("ssh -o 'StrictHostKeyChecking=no' -i /home/jenkins/.ssh/id_rsa -C centos@${env.VM_FQDN} 'sudo chmod -R 777 /var/log/storm'")
          sh("ssh -o 'StrictHostKeyChecking=no' -i /home/jenkins/.ssh/id_rsa -C centos@${env.VM_FQDN} 'tar -zcvf storm-deployment-logs.tar.gz /var/log/storm/*.log /var/log/storm/webdav/*.log'")
          sh("scp -o 'StrictHostKeyChecking=no' -i /home/jenkins/.ssh/id_rsa centos@${env.VM_FQDN}:storm-deployment-logs.tar.gz .")
          sh("tar -xvzf storm-deployment-logs.tar.gz")
          archiveArtifacts "var/**"
        }
      }
    }
  }
}
