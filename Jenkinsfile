pipeline {
  
  agent { label 'generic' }

  options {
    timeout(time: 3, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  parameters {
    choice(name: 'MODE', choices: "clean\nupdate", description: '')
    choice(name: 'PLATFORM', choices: "centos6", description: '')
    string(name: 'VM_IMAGE', defaultValue: 'centos-6-1804-x86_64-generic-gpfs-client-certs', description: 'Cloud VM machine image source')
    string(name: 'VM_NAME', defaultValue: 'cloud-vm127', description: 'Cloud VM machine name')
    string(name: 'VM_FLOATING_IP', defaultValue: '131.154.96.127', description: 'Floating IP')
    string(name: 'VM_FLAVOR', defaultValue: 'm1.medium', description: 'Machine flavor')
    string(name: 'VM_FQDN', defaultValue: 'cloud-vm127.cloud.cnaf.infn.it', description: 'Machine FQDN hostname')
  }

  environment {
    REPOSITORY = "https://github.com/italiangrid/storm-deployment-test"
    BRANCH = "gpfs"
    VM_IMAGE = "${params.VM_IMAGE}"
    VM_NAME = "${params.VM_NAME}"
    VM_FLOATING_IP = "${params.VM_FLOATING_IP}"
    VM_FLAVOR = "${params.VM_FLAVOR}"
    VM_FQDN = "${params.VM_FQDN}"
    STORAGE_ROOT_DIR = "/storage/${BUILD_TAG}"
  }

  stages {
    stage('create-and-run'){
      steps {
        container('generic-runner') {
          withCredentials([
            usernamePassword(credentialsId: 'openstack-mw-devel-user', passwordVariable: 'mw_password', usernameVariable: 'mw_username')
          ]) {
            sh """
cat <<EOF >>deployment.tfvars
mw_username = "${mw_username}"
mw_password = "${mw_password}"
mode = "${params.MODE}"
platform = "${params.PLATFORM}"
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
  }
}
