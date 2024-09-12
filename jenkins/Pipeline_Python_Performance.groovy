recepients = 'ipetrash.contractor@libertyglobal.com'

def coverage(folder) {
    msg = ""
    try {
        sh 'cd ' + folder + ' && coverage run *.py'
    }
    catch (err) {msg = msg + "\t - Error while calculating the coverage in folder " + folder + " (" + err + ").\n"}
    sh 'cd ' + folder + ' && coverage report || true'
    sh 'cd ' + folder + ' && coverage xml'
    archiveArtifacts artifacts: folder + '/coverage.xml'
    return msg
}

def unittests(folder) {
    msg = ""
    sh 'p=`(pwd)` && export PYTHONPATH="$PYTHONPATH:$p/' + folder + '"'
    try {
        sh 'cd ' + folder + ' && nosetests -vv -m ^test_* --with-xunit --xunit-file=junit.xml --with-html --html-file=nosetests.html'
    }
    catch (err) {
        msg = msg + "\n\t - Unit tests failed (" + err + ").\n"
    }
    archiveArtifacts artifacts: folder + '/*.*ml'
    return msg
}

def pylint(folder) {
    msg = ""
    sh 'p=`(pwd)` && export PYLINTHOME="$p/"'
    try {
        sh 'cd ' + folder + ' && OUT=$(pylint -f parseable --rcfile ../pylint/pylintrc_custom *.py | tee pylint.txt ; exit ${PIPESTATUS[0]})'
    }
    catch (err) {
        out = sh (script: 'cat ' + folder + '/pylint.txt', returnStdout: true).trim()
        msg = msg + "\t - PyLint failed (" + err + "):\n" + out + "\n\n"

    }
    archiveArtifacts artifacts: folder + '/pylint.txt'
    return msg
}

def radon_cc(folder) {
    msg = ""
    sh 'cd ' + folder + ' && declare -x RADONFILESENCODING="UTF-8" && radon cc -n C --total-average --show-complexity --xml *.py > radon_cc.xml'
    sh 'cd ' + folder + ' && declare -x RADONFILESENCODING="UTF-8" && radon cc -n C --total-average --show-complexity *.py > radon_cc.txt'
    try {
        sh 'cd ' + folder + ' && if [[ $(cat radon_cc.txt | head -n -3) ]]; then exit 1; else exit 0; fi'
    }
    catch (err) {
        out = sh (
            script: 'cd ' + folder + ' && cat radon_cc.txt | head -n -3',
            returnStdout: true
        ).trim()
        msg = '\t - Radon Cyclomatic Complexity is high:\n' + out + '\n\n'
    }
    archiveArtifacts artifacts: folder + '/radon_cc.*'
    return msg
}

def radon_mi(folder) {
    msg = ""
    sh 'cd ' + folder + ' && declare -x RADONFILESENCODING="UTF-8" && radon mi --show *.py > radon_mi.txt'
    try {
        sh 'cd ' + folder + ' && declare -x RADONFILESENCODING="UTF-8" && if [[ $(radon mi -n B --show *.py) ]]; then exit 1; else exit 0; fi'
    }
    catch (err) {
        out = sh (
            script: 'cd ' + folder + ' && cat radon_mi.txt',
            returnStdout: true
        ).trim()
        msg = '\t - Radon Maintainability Index is high:\n' + out + '\n\n'
    }
    archiveArtifacts artifacts: folder + '/radon_mi.txt'
    return msg
}

node('master') {
    cleanWs() // clean workspace
    email_msg = ""
    folder = 'loadrunner'
    docker.image('robot').inside() {
        git credentialsId: '263e7fed-d1c2-4850-9bc7-87cff6f5402a', url: 'ssh://git@bitbucket.upc.biz:7999/cha/performance-tests.git'
        //folder = sh (script: 'pwd', returnStdout: true).trim() + '/loadrunner'
//        parallel(
            stage("Unit Tests (nosetests)") {
                email_msg = email_msg + unittests(folder)
            }
            stage("Static Code Analysis (pylint)") {
                email_msg = email_msg + pylint(folder)
            }
            stage("Cyclomatic Complexity (radon cc)") {
                email_msg = email_msg + radon_cc(folder)
            }
            stage("Maintainability Index (radon mi)") {
                email_msg = email_msg + radon_mi(folder)
            }
            stage("Code Coverage (coverage)") {
                email_msg = email_msg + coverage(folder)
            }
//        ) // Parallel
    } // Docker
    sh 'echo "Build stages done. Message is: ' + email_msg + '\n\n"'
    try {
        junit folder + '/junit.xml'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: folder, reportFiles: folder + '/nosetests.html', reportName: 'HTML Report', reportTitles: ''])
        warnings canComputeNew: false, canResolveRelativePaths: false, categoriesPattern: '', defaultEncoding: '', excludePattern: '', healthy: '', includePattern: '', messagesPattern: '', parserConfigurations: [[parserName: 'PyLint', pattern: folder + '/pylint.txt']], unHealthy: ''
        step([$class: 'CcmPublisher', pattern: folder + '/radon_cc.xml'])
        step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: folder + '/coverage.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
    } // try
    catch(err) {
        email_msg = email_msg + "\nAt least one of post build actions failed:\n" + err
    } //catch
    if (email_msg != "") {
       env.BUILD_URL
       refs = '\n\nFor information related to pylint and radon usage, please refer to:\n'
       refs = refs + '\t * http://pylint-messages.wikidot.com/all-messages\n'
       refs = refs + '\t * http://radon.readthedocs.io/en/latest/intro.html\n'
       refs = refs + '\t * http://radon.readthedocs.io/en/latest/commandline.html\n'
       emailext body: 'Dear colleague,\n\n'+ env.JOB_NAME + ' is completed.\nUnfortunately, not everything went successfully.\n\nBelow should be addressed:\n' + email_msg + '\n\nPlease visit Jenkins at: ' + env.BUILD_URL + refs + '\n\nBest Regards,\n   Jenkins.', subject: 'Jenkins job ' + env.JOB_NAME + ' has issue(s)', to: recepients
    } // if
    sh 'echo "Post Build stages done. Final e-mail message is: ' + email_msg + '"'
} // node master
