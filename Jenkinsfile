#!groovy
library "knime-pipeline@$DEFAULT_LIBRARY_VERSION"

properties([
    pipelineTriggers([upstream(
        'knime-core/' + env.BRANCH_NAME.replaceAll('/', '%2F')
    )]),
    parameters(workflowTests.getConfigurationsAsParameters()),
    buildDiscarder(logRotator(numToKeepStr: '5')),
    disableConcurrentBuilds()
])

try {
    timeout(time: 2, unit: 'HOURS') {
        node('maven && java21') {
            echo "Running on ${env.NODE_NAME}"
            withEnv(['SKIP_COMPOSITES=true']) {
                knimetools.defaultTychoBuild(updateSiteProject: 'org.knime.update.ap.batch')
            }

            stage('Sonarqube analysis') {
                env.lastStage = env.STAGE_NAME
                workflowTests.runSonar(withOutNode: true)
            }
        }
    }
} catch (ex) {
    currentBuild.result = 'FAILURE'
    throw ex
} finally {
    notifications.notifyBuild(currentBuild.result)
}
/* vim: set shiftwidth=4 expandtab smarttab: */
