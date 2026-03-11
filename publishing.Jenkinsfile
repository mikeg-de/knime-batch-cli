#!groovy

library "knime-pipeline@$DEFAULT_LIBRARY_VERSION"

properties([
	parameters([
        stringParam(
                name: "PRODUCT_VERSION",
                defaultValue: "5.8.1",
                description: "The product version to publish."
            ),
        run(
                filter: 'STABLE',
                name: 'STANDARD_BUILD',
                description: "The build of the <b><i>knime-ap-batch</i></b> that produced the artifacts to be published.",
                projectName: 'knime-ap-batch/' + BRANCH_NAME.replaceAll('/', '%2F')
        )
	]),
	buildDiscarder(logRotator(numToKeepStr: '5')),
    disableConcurrentBuilds()
])

try {
	timeout(time: 2, unit: 'HOURS') {
        String projectLocation = '/var/cache/jenkins/p2/knime/knime-ap-batch'
        // composite branch
        String branchLocation = "${projectLocation}/${env.BRANCH_NAME}"
        // update site that we are building
        String updateSiteLocation = "${branchLocation}/${STANDARD_BUILD_NUMBER}"
        def majorMinor = (PRODUCT_VERSION =~ /^(\d+\.\d+)/)[0][1]
        node('composite-updater') {
            try {
                stage('Create batch update site') {
                     mirrorToCDN(updateSiteLocation, "batch/$majorMinor/${PRODUCT_VERSION}")
                }
            }
            catch (ex) {
                    sh "rm -rf ${env.BRANCH_LOCATION}.*"
                    currentBuild.result = 'FAILURE'
                    throw ex
            }
            finally {
                notifications.notifyBuild(currentBuild.result)
            }

        }

	}
} catch (ex) {
   	currentBuild.result = 'FAILURE'
   	throw ex
   }
   finally {
    notifications.notifyBuild(buildStatus: currentBuild.result);
}


/**
* Mirror the given update site to the specified repo on update.knime.com.
* @param sourceLocation the location of the update site to mirror
* @param targetSite the target update site on update.knime.com (e.g. nightly, sprintbuild)
*/
void mirrorToCDN(String sourceLocation, String targetSite) {
    if (env.SYSTEM_ENVIRONMENT != "production") {
        echo "Skipping mirroring to update.knime.com as we are not in the production environment!"
        return
    }
    stage('Mirror to update.knime.com') {
        withCredentials([
            sshUserPrivateKey(credentialsId: 'download.knime.com', keyFileVariable: 'KEYFILE', usernameVariable: 'SSH_USER')
        ]) {
                withEnv(["LOCATION=${sourceLocation}", "SITE=${targetSite}"]) {
                    sh '''
                        cp -al "${LOCATION}" "${LOCATION}".mirror
                        cd "$LOCATION".mirror
                        mv knime-ap-batch.zip org.knime.update.batch_"${PRODUCT_VERSION}".zip

                        if [[ ! -f ~/.ssh/known_hosts ]]; then
                            mkdir -p ~/.ssh
                            ssh-keyscan update.production.knime.com >> ~/.ssh/known_hosts
                        fi

                        ssh -i "${KEYFILE}" ${SSH_USER}@update.production.knime.com "mkdir -p /var/www/update.knime.org/${SITE}"

                        rsync -e "ssh -i '${KEYFILE}'" -av --delete . ${SSH_USER}@update.production.knime.com:/var/www/update.knime.org/${SITE}/
                        cd ..
                        rm -rf "${LOCATION}".mirror
                    '''
                }
            }
    }

     stage('refresh CDN cache'){
            node('downloads') {
                withEnv(["SITE=${targetSite}"]) {
                    sh '''
                        aws cloudfront create-invalidation --distribution-id E1JI0ZFVH040DA --paths /${SITE}/*
                    '''
                }
            }
        }
}