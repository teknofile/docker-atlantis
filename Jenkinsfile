def loadConfigYaml()
{
  def valuesYaml = readYaml (file: './config.yaml')
  return valuesYaml;
}

pipeline {
  agent {
    // By default run stuff on a x86_64 node, when we get
    // to the parts where we need to build an image on a diff
    // architecture, we'll run that bit on a diff agent
    label 'X86_64'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
  }

  // Configuration for the variables used for this specific repo
  environment {
    CONTAINER_NAME = 'docker-atlantis'
  }

  stages {
    // Setup all the basic enviornment variables needed for the build
    stage("Setup ENV variables") {
      steps {
        script {
          env.EXIT_STATUS = ''
          env.CURR_DATE = sh(
            script: '''date '+%Y-%m-%d_%H:%M:%S%:z' ''',
            returnStdout: true).trim()
          env.GITHASH_SHORT = sh(
            script: '''git log -1 --format=%h''',
            returnStdout: true).trim()
          env.GITHASH_LONG = sh(
            script: '''git log -1 --format=%H''',
            returnStdout: true).trim()
        }
      }
    }

    stage('Build Containers') {
      agent {
        label 'X86_64'
      }
      steps {
        echo "Running on node: ${NODE_NAME}"

        git([url: 'https://github.com/teknofile/docker-atlantis.git', branch: env.BRANCH_NAME, credentialsId: 'TKFBuildBot'])

        script {
          configYaml = loadConfigYaml()
          env.BASE_TAG = configYaml.baseimage.version
          env.ATLANTIS_VERSION = configYaml.atlantis.version
          env.TG_ATLANTIS_CONFIG_VER = configYaml.tg_atlantis_config.version
          env.TF_VERSION = configYaml.terraform.version
          env.TG_VERSION = configYaml.terragrunt.version

          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker buildx create --bootstrap --use --name tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
              docker buildx build \
                --no-cache \
                --pull \
                --build-arg BASE_TAG=${BASE_TAG} \
                --build-arg ATLANTIS_VERSION=${ATLANTIS_VERSION} \
                --build-arg TG_ATLANTIS_CONFIG_VER=${TG_ATLANTIS_CONFIG_VER} \
                --build-arg TF_VERSION=${TF_VERSION} \
                --build-arg TG_VERSION=${TG_VERSION} \
                --platform linux/amd64,linux/arm64,linux/arm \
                -t teknofile/${CONTAINER_NAME}:${BUILD_ID} \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_LONG} \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_SHORT} \
                -t teknofile/${CONTAINER_NAME}:${BASE_TAG} \
                -t teknofile/${CONTAINER_NAME}:${BRANCH_NAME} \
                -t teknofile/${CONTAINER_NAME}:latest \
                -t teknofile/${CONTAINER_NAME} \
                . \
                --push

              docker buildx stop tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
              docker buildx rm tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
            '''
          }
        }
      }
    }
  }
  post {
    cleanup {
      cleanWs()
	    deleteDir()
    }
  }
}