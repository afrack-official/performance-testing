library('iac-pos') _
library('common') _
pipeline {
  agent {
    label 'POS_PerformanceTesting'
  }
  environment {
    PRIVATE_KEY_PATH = 'C:\\Users\\Administrator\\Desktop\\pos-auth\\orbis-pos-prl-jmeter-slaves.pem'
    USERNAME = 'ubuntu'
    JOBNAME = 'jmeter'
    PRIVATE_IPS_DELIMITER = ',' // Change this to your preferred delimiter
    MARKER_LINE = 'Apply complete!' // Change this to the line that marks the beginning of private IPs of slaves
  }
  parameters {
    string(name: 'PROVISION_INSTANCE_COUNT', defaultValue: '0', description: 'Number of LoadGens/Instances to provision')
    string(name: 'DESTROY_INSTANCE_COUNT', defaultValue: '0', description: 'Use 0 to destroy all LoadGens/Instances')
    text(name: 'TEST_PLAN_TO_EXECUTE', defaultValue: '', description: 'Comma-separated list of test plans (e.g., RONTEC_POS_PerformanceTesting,RONTEC_OW_PerformanceTesting,RONTEC_HHT_PerformanceTesting)')
    text(name: 'TEST_PLAN_PROPERTY_FILE', defaultValue: '', description: 'Comma-separated list of property files (e.g., EnduranceTest,LoadTest,StressTest,Test)')
  }
  options {
    skipDefaultCheckout()
    parallelsAlwaysFailFast()
    disableConcurrentBuilds()
  }

  stages {
    stage('CheckOut') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [
            [name: 'master']
          ],
          doGenerateSubmoduleConfigurations: false,
          extensions: [cloneOption(timeout: 60), [$class: 'RelativeTargetDirectory', relativeTargetDir: '.']],
          submoduleCfg: [],
          userRemoteConfigs: [
            [credentialsId: 'ado-account', url: "https://pdidev.visualstudio.com/DefaultCollection/pos-solutions/_git/orbis-performance-testing-d7"]
          ]
        ])
      }
    }
    stage('Provision LoadGen') {
      steps {
        tfcRun([
          organization: 'PDISoftware',
          workspace: 'pos-prl-testexecutions-eucentral1-test',
          applyRun: true,
          runMessage: 'Update',
          variables: ['instance_count': [value: "${params.PROVISION_INSTANCE_COUNT}"]],
          withAwsCredentials: [secretName: 'common-secrets', secretKey: 'tf-cloud-api-key']
        ])
      }
    }
    stage('Configure LoadGen') {
      when {
        expression {
          params.PROVISION_INSTANCE_COUNT.toInteger() != 0
        }
      }
      steps {
        script {
          // Simulated console output (replace this with the actual console output)
          def consoleOutput = currentBuild.rawBuild.getLog(1000).join('\n')

          // Find the index of the marker line
          def markerIndex = consoleOutput.indexOf(MARKER_LINE)

          // If the marker line is found, extract private IPs after that line
          if (markerIndex != -1) {
            def privateIpPattern = /"(\d+\.\d+\.\d+\.\d+)"/
            def privateIpMatcher = consoleOutput.substring(markerIndex) =~ privateIpPattern
            def privateIPs = privateIpMatcher.collect {
              it[1]
            }

            // Print all private IPs
            echo "Private IPs: ${privateIPs.join(PRIVATE_IPS_DELIMITER)}"

            // Set private IPs as environment variable for future stages
            env.PRIVATE_IPS = privateIPs.join(PRIVATE_IPS_DELIMITER)

          } else {
            echo "Marker line not found. No private IPs extracted."
            error "Marker line not found in console output"
          }

          // Setup
          sleep(time: 60, unit: "SECONDS")
          def downloadDir = "C:\\SHELL_FPOS_HHT_ORBISWEB_v0.1\\OrbisPosD7\\downloaded-artifacts"
          stash includes: 'TestData/**/*', name: 'TestData'
          stash includes: 'TestPlan/**/*', name: 'TestPlan'
          stash includes: 'Configurations/**/*', name: 'Configurations'
          // Delete existing download directory if it exists and create
          bat "if exist \"${downloadDir}\" rmdir /s /q \"${downloadDir}\""
          bat "mkdir ${downloadDir}"
          // Unstash the artifacts to the download directory
          unstash 'TestData'
          unstash 'TestPlan'
          unstash 'Configurations'
          // Copy the archived artifacts to the download directory
          bat "xcopy \"${env.WORKSPACE}/TestData\" \"${downloadDir}\\TestData\" /e /i"
          bat "xcopy \"${env.WORKSPACE}/TestPlan\" \"${downloadDir}\\TestPlan\" /e /i"
          bat "xcopy \"${env.WORKSPACE}/Configurations\" \"${downloadDir}\\Configurations\" /e /i"
          bat "dir ${downloadDir}"
          // Status check
          sleep(time: 60, unit: "SECONDS")

          // Split the private IPs into a list
          def privateIPsList = env.PRIVATE_IPS.split(',')

          // Process each private IP
          for (def privateIP in privateIPsList) {
            echo "Processing Private IP: ${privateIP}"

            def SCRIPT_TO_RUN = "/home/ubuntu/TestData/orbis-pos-prl-jmeter-slaves.pem"

            // Remove existing SSH key for the current private IP
            bat "ssh-keygen -R ${privateIP}"

            // Copy artifacts to the remote machine
            bat "scp -o StrictHostKeyChecking=no -i ${PRIVATE_KEY_PATH} -r ${downloadDir}\\TestData ${USERNAME}@${privateIP}:/home/ubuntu/"
            bat "scp -o StrictHostKeyChecking=no -i ${PRIVATE_KEY_PATH} -r ${downloadDir}\\Configurations ${USERNAME}@${privateIP}:/home/ubuntu/"
            bat "scp -o StrictHostKeyChecking=no -i ${PRIVATE_KEY_PATH} -r ${downloadDir}\\TestPlan ${USERNAME}@${privateIP}:/home/ubuntu/"

            sleep(time: 60, unit: "SECONDS")
          }
        }
      }
    }
    stage('Perf Test Execution') {
      when {
        expression {
          params.PROVISION_INSTANCE_COUNT.toInteger() != 0
        }
      }
      steps {
        script {
          // Split the test plans and property files into lists
          def testPlans = params.TEST_PLAN_TO_EXECUTE.split(',')
          def propertyFiles = params.TEST_PLAN_PROPERTY_FILE.split(',')

          // Ensure the number of property files matches the number of test plans
          if (testPlans.size() != propertyFiles.size()) {
            error "The number of test plans does not match the number of property files."
          }

          def privateIPsList = env.PRIVATE_IPS.split(',')
          def parallelSteps = [: ]

          // Iterate over each test plan and create parallel tasks
          for (int i = 0; i < testPlans.size(); i++) {
            def privateIP = privateIPsList[i]
            def testPlan = testPlans[i] + '.jmx'
            def propertyFile = propertyFiles[i] + '.properties'
            def timestamp = new Date().format("dd-MM-yyyy_HH:mm", TimeZone.getTimeZone("Asia/Kolkata"))
            parallelSteps["Test Plan ${i + 1}"] = {
              dir('C:\\Users\\Administrator\\Downloads') {
                echo "Private IP: ${privateIP}"
                echo "Test Plan File: ${testPlan}"
                echo "Property File: ${propertyFile}"
                echo "Timestamp: ${timestamp}"
                bat "echo y | plink.exe -ssh -i \"C:\\Users\\Administrator\\Desktop\\pos-auth\\orbis-pos-prl-jmeter-slaves.ppk\" ubuntu@${privateIP} \"chmod -R 755 /home/ubuntu/TestData\""
                bat "echo y | plink.exe -ssh -i \"C:\\Users\\Administrator\\Desktop\\pos-auth\\orbis-pos-prl-jmeter-slaves.ppk\" ubuntu@${privateIP} \"chmod -R 755 /home/ubuntu/TestPlan\""
                bat "echo y | plink.exe -ssh -i \"C:\\Users\\Administrator\\Desktop\\pos-auth\\orbis-pos-prl-jmeter-slaves.ppk\" ubuntu@${privateIP} \"chmod -R 755 /home/ubuntu/Configurations\""
                sleep(time: 480, unit: "SECONDS")
                bat "echo y | plink.exe -ssh -i \"C:\\Users\\Administrator\\Desktop\\pos-auth\\orbis-pos-prl-jmeter-slaves.ppk\" ubuntu@${privateIP} \"cd /home/ubuntu/apache-jmeter-5.6.2/bin && sudo ./jmeter.sh -n -t /home/ubuntu/TestPlan/${testPlan} -l /mnt/share/OrbisPos/${testPlan}.jtl -Dserver.rmi.ssl.disable=true -q /home/ubuntu/Configurations/${propertyFile} -Dtimestamp=${timestamp}\""
              }
            }
          }
          parallel parallelSteps
        }
      }
    }
  }
  post {
    always {
      script {
        tfcRun([
          organization: 'PDISoftware',
          workspace: 'pos-prl-testexecutions-eucentral1-test',
          applyRun: true,
          runMessage: 'Update',
          variables: ['instance_count': [value: "${params.DESTROY_INSTANCE_COUNT}"]],
          withAwsCredentials: [secretName: 'common-secrets', secretKey: 'tf-cloud-api-key']
        ])
      }
    }
  }
}