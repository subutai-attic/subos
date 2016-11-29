#!groovy

notifyBuildDetails = ""
subosCommitId = ""
serenityReportDir = ""
snapBuildTime = ""
agentVersion = ""

try {
	// withCredentials([string(credentialsId: 'sysnet-bots-slack-token', variable: 'slackToken')]) {
	// 	notifyBuild('STARTED', notifyBuildDetails, slackToken)
	// }

	node() {
		/* Building snap */
		deleteDir()

		stage("Checkout source")
		/* checkout agent repo */
		notifyBuildDetails = "\nFailed on Stage - Checkout source"

		checkout scm

		subosCommitId = sh (script: "git rev-parse HEAD", returnStdout: true)
		serenityReportDir = "/var/lib/jenkins/www/serenity/${subosCommitId}"

		stage("Build snap package")
		/* Build snap package based on autobuild.sh script */
		notifyBuildDetails = "\nFailed on Stage - Build snap package"

		/* get agent version */
		agentVersion = sh (script: "cat subutai/etc/agent.gcfg | grep version | cut -d ' ' -f3",
			returnStdout: true)

		/* change export path to current directory */
		sh """
			sed 's/EXPORT_DIR=.*/EXPORT_DIR=./g' -i autobuild.sh
		"""

		/* build snap */
		String buildOutput = sh (script: """
			./autobuild.sh -b
			""", returnStdout: true).trim()

		snapBuildTime = sh (script: """
			echo ${buildOutput} | cut -d '-' -f2 | cut -d '_' -f1
			""", returnStdout: true)


		/* rename built snap */
		sh """
			mv (echo $out | cut -d \' -f 2) subutai_${agentVersion}_amd64-${env.BRANCH_NAME}.snap
		"""

		/* stash snap to use it in next node() */
		stash includes: 'subutai_*.snap', name: 'snap'

	}
	node() {
		/* Running Integration tests only on dev branch */
		deleteDir()
		lock('test-node') {
			if (env.BRANCH_NAME == 'jenkinsfile') {
				mvnHome = tool 'M3'

				stage("Update test node")
				/* Update test node */
				notifyBuildDetails = "\nFailed on Stage - Update test node"

				unstash 'snap'

				/* destroy existing management template on test node */
				sh """
					set +x
					ssh root@${env.SS_TEST_NODE} <<- EOF
					set -e
					subutai destroy everything
					if test -f /var/lib/apps/subutai/current/p2p.save; then rm /var/lib/apps/subutai/current/p2p.save; fi
					systemctl restart subutai_p2p_*.service
					rm /mnt/lib/lxc/tmpdir/management-subutai-template_*
				EOF"""

				/* copy built snap on test node */
				sh """
					set +x
					scp subutai_*.snap root@${env.SS_TEST_NODE}:/tmp/subutai_subos_builder.snap
				"""

				// install generated management template
				sh """
					set +x
					rm /var/lib/apps/subutai/current/agent.gcfg
					snappy install /tmp/subutai_subos_builder.snap --allow-unauthenticated
					ssh root@${env.SS_TEST_NODE} <<- EOF
					set -e
					echo y | subutai import management
				EOF"""

				/* wait until SS starts */
				timeout(time: 5, unit: 'MINUTES') {
					sh """
						set +x
						echo "Waiting SS"
						while [ \$(curl -k -s -o /dev/null -w %{http_code} 'https://${env.SS_TEST_NODE}:8443/rest/v1/peer/ready') != "200" ]; do
							sleep 5
						done
					"""
				}

				stage("Integration tests")
				/* Running test, copy tests result to www directory */
				notifyBuildDetails = "\nFailed on Stage - Integration tests\nSerenity Tests Results:\n${env.JENKINS_URL}serenity/${subosCommitId}"
				sh """
					set +e
					./run_tests_qa.sh -m ${env.SS_TEST_NODE}
					./run_tests_qa.sh -s all
					${mvnHome}/bin/mvn integration-test -Dwebdriver.firefox.profile=src/test/resources/profilePgpFF
					OUT=\$?
					${mvnHome}/bin/mvn serenity:aggregate
					cp -rl target/site/serenity ${serenityReportDir}
					if [ \$OUT -ne 0 ];then
						exit 1
					fi
				"""
			}
		}
	}
	node() {
		deleteDir()
		stage("Upload built snap to kurjun")
		notifyBuildDetails = "\nFailed on Stage - Upload built snap to kurjun"

		unstash 'snap'
		String filename = "subutai_${agentVersion}_amd64-${env.BRANCH_NAME}.snap"

		/* cdn auth creadentials */
		String url = "https://eu0.cdn.subut.ai:8338/kurjun/rest"
		String user = "jenkins"
		def authID = sh (script: """
			set +x
			curl -s -k ${url}/auth/token?user=${user} | gpg --clearsign --no-tty
			""", returnStdout: true)
		def token = sh (script: """
			set +x
			curl -s -k -Fmessage=\"${authID}\" -Fuser=${user} ${url}/auth/token
			""", returnStdout: true)

		/* Upload snap to kurjun */
		String responseSnap = sh (script: """
			set +x
			curl -s -k https://eu0.cdn.subut.ai:8338/kurjun/rest/raw/info?name=${filename}
			""", returnStdout: true)
		sh """
			set +x
			curl -s -k -Ffile=@${filename} -Ftoken=${token} ${url}/raw/upload
		"""

		/* delete old snap */
		if (responseSnap != "Not found") {
			def jsonSnap = jsonParse(responseSnap)
			sh """
				set +x
				curl -s -k -X DELETE ${url}/apt/delete?id=${jsonSnap["id"]}'&'token=${token}
			"""
		}
	}
} catch (e) { 
	currentBuild.result = "FAILED"
	throw e
} finally {
	// Success or failure, always send notifications
	// withCredentials([string(credentialsId: 'sysnet-bots-slack-token', variable: 'slackToken')]) {
	// 	notifyBuild(currentBuild.result, notifyBuildDetails, slackToken)
	// }
}

// https://jenkins.io/blog/2016/07/18/pipline-notifications/
def notifyBuild(String buildStatus = 'STARTED', String details = '', String token='') {
	// build status of null means successful
	buildStatus = buildStatus ?: 'SUCCESSFUL'

	// Default values
	def colorName = 'RED'
	def colorCode = '#FF0000'
	def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"  	
	def summary = "${subject} (${env.BUILD_URL})"

	// Override default values based on build status
	if (buildStatus == 'STARTED') {
		color = 'YELLOW'
		colorCode = '#FFFF00'  
	} else if (buildStatus == 'SUCCESSFUL') {
		color = 'GREEN'
		colorCode = '#00FF00'
	} else {
		color = 'RED'
		colorCode = '#FF0000'
		summary = "${subject} (${env.BUILD_URL})${details}"
	}
	// Get token
	// def slackToken = getSlackToken('sysnet-bots-slack-token')
	// Send notifications
	// withCredentials([string(credentialsId: 'sysnet-bots-slack-token', variable: 'slackToken')]) {
	slackSend (color: colorCode, message: summary, teamDomain: 'subutai-io', token: "${slackToken}")
	// }
}
