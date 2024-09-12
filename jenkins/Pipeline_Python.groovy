recepients = env.AUTHOR_EMAIL_ADDRESS + ',' + env.REVIEWERS_EMAIL_ADDRESSES
admin =  env.ADMIN_EMAIL_ADDRESS

def coverage(lib_dir, lib_list) {
    msg = ""
    lib_dir = lib_dir + "/"
    coverage_files_str = ""
    include_files_str = ""
    for (int i = 0; i < lib_list.size(); i++) {
        try {
            sh 'cd ' + lib_dir + lib_list[i] + ' && coverage run *.py'
            coverage_files_str = coverage_files_str + lib_list[i] + '/.coverage '
            include_files_str = include_files_str + lib_list[i] + '*,'
        }
        catch (err) {msg = msg + "\t - Error while calculating the coverage for " + lib_list[i] + " (" + err + ").\n"}
    } // for
    sh 'cd ' + lib_dir + ' && coverage combine ' + coverage_files_str + ' || true'
    sh 'cd ' + lib_dir + ' && coverage report --include=' + include_files_str + ' || true'
    sh 'cd ' + lib_dir + ' && coverage xml --include=' + include_files_str
    archiveArtifacts artifacts: lib_dir + 'coverage.xml'
    return msg
}

def unittests(lib_dir, lib_list) {
    msg = ""
    lib_dir = lib_dir + "/"
    for (int i = 0; i < lib_list.size(); i++) {
        sh 'p=`(pwd)` && export PYTHONPATH="$PYTHONPATH:$p/' + lib_dir + lib_list[i] + '"'
    } // for
    try{
        sh 'cd ' + lib_dir + ' && nosetests -vv -m ^test_* --with-xunit --xunit-file=junit.xml --with-html --html-file=nosetests.html'
    }
    catch (err) {msg = msg + "\n\t - Unit tests failed (" + err + ").\n"}
    archiveArtifacts artifacts: lib_dir + '*.*ml'
    return msg
}

def pylint(path_to_target_folder) {
    msg = ""
    path_list = path_to_target_folder.split("/")
    library = path_list[-1]
    path_size = path_list.size()
    path_steps = '../'.multiply(path_size)
    pylintrc_custom = path_steps + 'pylintrc_custom'

    sh 'p=`(pwd)` && export PYLINTHOME="$p/"'
    try {
        withEnv(['PYLINTHOME=.']) {
            sh 'cd ' + path_to_target_folder + ' && pylint -f parseable --rcfile '+ pylintrc_custom + ' --ignore=asyncplay.py *.py | tee ' + path_steps + 'pylint_' + library + '.txt'
            out = sh (
                    script: 'cd ' + path_to_target_folder + ' && cat ' + path_steps + 'pylint_' + library + '.txt',
                    returnStdout: true
            ).trim()
//            out = "Your code has been rated at 10.00/10"
            passed = out.contains("Your code has been rated at 10.00/10")
            if (!passed) {
                sh 'exit 1'
            }
        }
    }
    catch (err) {
        withEnv(['PYLINTHOME=.']) {
            out = sh (
                    script: 'cd ' + path_to_target_folder + ' && cat ' + path_steps + 'pylint_' + library + '.txt',
                    returnStdout: true
            ).trim()
        }
        msg = msg + "\t - PyLint failed for " + library + " (" + err + "):\n" + out + "\n\n"
    }

    archiveArtifacts artifacts: 'pylint_*.txt'
    return msg

}

def run_code_analysis(analysis_type, lib_dir, lib_list) {
    msg = ""
    lib_dir = lib_dir + "/"
    sh 'p=`(pwd)` && export PYLINTHOME="$p/"'
    for (int i = 0; i < lib_list.size(); i++) {
        withEnv(['PYLINTHOME=.']) {
            path_string_or_subdirs_list = return_path_to_target_directory(lib_dir, lib_list[i])
            if (path_string_or_subdirs_list instanceof java.lang.String) {
                path_to_target_folder = path_string_or_subdirs_list
                if (analysis_type == "pylint") {
                    msg = msg + pylint(path_to_target_folder)
                }
            } else {
                // Recursion:
                recursion_lib_dir = lib_dir + lib_list[i]
                recursion_lib_list = path_string_or_subdirs_list
                run_code_analysis(analysis_type, recursion_lib_dir, recursion_lib_list)
            }
        }
    }
    return msg
}

def return_path_to_target_directory(lib_dir, first_level_directory) {
    sh 'p=`(pwd)` && export PYLINTHOME="$p/"'
    withEnv(['PYLINTHOME=.']) {

        first_level_path = lib_dir + first_level_directory
        sh 'cd ' + first_level_path
        sub_directories = sh(
                script: 'cd ' + first_level_path + ' && for i in $(ls -d */ || echo ""); do echo ${i%%/}; done',
                returnStdout: true
        ).trim().split()
        python_files = sh(
                script: 'cd ' + first_level_path + ' && for i in $(ls -l *.py | awk \'{print $9}\' || echo ""); do echo ${i%%/}; done',
                returnStdout: true
        ).trim().split()
        files_to_check = []
        if (python_files.size() > 0) {
            for (int index = 0; index < python_files.size(); index++) {
                if (python_files[index] != "__init__.py") {
                    files_to_check.add(python_files[index])
                }
            }
            if (files_to_check.size() > 0) {
                return first_level_path
            }
        }
        return sub_directories
    }
}

def radon_cc(lib_dir) {
    msg = ""
    sh 'cd ' + lib_dir + ' && declare -x RADONFILESENCODING="UTF-8" && radon cc -n C --total-average --show-complexity --xml . > radon_cc.xml'
    sh 'cd ' + lib_dir + ' && declare -x RADONFILESENCODING="UTF-8" && radon cc -n C --total-average --show-complexity . > radon_cc.txt'
    try {
        sh 'cd ' + lib_dir + ' && if [[ $(cat radon_cc.txt | head -n -3) ]]; then exit 1; else exit 0; fi'
    }
    catch (err) {
        out = sh (
                script: 'cd ' + lib_dir + ' && cat radon_cc.txt | head -n -3',
                returnStdout: true
        ).trim()
        msg = '\t - Radon Cyclomatic Complexity is high:\n' + out + '\n\n'
    }
    archiveArtifacts artifacts: lib_dir + '/radon_cc.*'
    return msg
}

def radon_mi(lib_dir) {
    msg = ""
    sh 'cd ' + lib_dir + ' && declare -x RADONFILESENCODING="UTF-8" && radon mi --show . > radon_mi.txt'
    try {
        sh 'cd ' + lib_dir + ' && declare -x RADONFILESENCODING="UTF-8" && if [[ $(radon mi -n B --show .) ]]; then exit 1; else exit 0; fi'
    }
    catch (err) {
        out = sh (
                script: 'cd ' + lib_dir + ' && cat radon_mi.txt',
                returnStdout: true
        ).trim()
        msg = '\t - Radon Maintainability Index is high:\n' + out + '\n\n'
    }
    archiveArtifacts artifacts: lib_dir + '/radon_mi.txt'
    return msg
}

node('master') {
    cleanWs() // clean workspace
    lib_folder = "robot/Libraries"
    email_msg = ""
    docker.image('robot3').inside() {
        git branch: env.GIT_BRANCH_FOR_CHECK,
                credentialsId: '263e7fed-d1c2-4850-9bc7-87cff6f5402a',
                url: 'ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git'
        libraries = sh (
                script: 'cd ' + lib_folder + ' && for i in $(ls -d */); do echo ${i%%/}; done',
                returnStdout: true
        ).trim().split()

//        parallel(
        stage("Unit Tests (nosetests)") {
            email_msg = email_msg + unittests(lib_folder, libraries)
        }
        stage("Static Code Analysis (pylint)") {
            email_msg = email_msg + run_code_analysis("pylint", lib_folder, libraries)
        }

        // stage("Cyclomatic Complexity (radon cc)") {
        //     email_msg = email_msg + radon_cc(lib_folder)
        // }
        // stage("Maintainability Index (radon mi)") {
        //     email_msg = email_msg + radon_mi(lib_folder)
        // }
        // stage("Code Coverage (coverage)") {
        //     email_msg = email_msg + coverage(lib_folder, libraries)
        // }
//        ) // Parallel
    } // Docker
    sh 'echo "Build stages done."'
    if (email_msg != "") {
        echo 'Message is: "' + email_msg + '"\n\n'
    } else {
        sh 'echo "No fails was detected"'
    }
    try {
        junit lib_folder + '/junit.xml'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: lib_folder, reportFiles: 'nosetests.html', reportName: 'HTML Report', reportTitles: ''])
        warnings canComputeNew: false, canResolveRelativePaths: false, categoriesPattern: '', defaultEncoding: '', excludePattern: '', healthy: '', includePattern: '', messagesPattern: '', parserConfigurations: [[parserName: 'PyLint', pattern: 'pylint_*.txt']], unHealthy: ''
        // TODO: uncomment together with radon_cc running lines
        // step([$class: 'CcmPublisher', pattern: lib_folder + '/radon_cc.xml'])
        // TODO: uncomment together with coverage running lines
        // step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: lib_folder + '/coverage.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
    } // try
    catch(err) {
        email_msg = email_msg + "\nAt least one of post build actions failed.\n"
    } //catch
    if (email_msg != "") {
        env.BUILD_URL
        refs = '\n\nFor information related to pylint and radon usage, please refer to:\n'
        refs = refs + '\t * http://pylint-messages.wikidot.com/all-messages\n'
//        TODO: uncomment together with radon_cc running lines
//        refs = refs + '\t * http://radon.readthedocs.io/en/latest/intro.html\n'
//        TODO: uncomment together with coverage running lines
//        refs = refs + '\t * http://radon.readthedocs.io/en/latest/commandline.html\n'
        emailext body: 'Dear colleague,\n\n'+ env.JOB_NAME + ' is completed.\nUnfortunately, not everything went successfully.\n\nBelow should be addressed:\n' + email_msg + '\n\nPlease visit Jenkins at: ' + env.BUILD_URL + refs + '\n\nBest Regards,\n   Jenkins.', subject: 'Jenkins job ' + env.JOB_NAME + ' has issue(s)', to: admin
    } // if
    docker.image('robot3').inside() {
        git branch: env.SOURCE_CODE_GIT_BRANCH,
                credentialsId: '263e7fed-d1c2-4850-9bc7-87cff6f5402a',
                url: 'ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git'

        folder = sh (script: 'pwd', returnStdout: true).trim() + '/scripts/bitbucket'
        if (env.GIT_BRANCH_FOR_CHECK != "master") {
            if (email_msg == "") {
                pull_request_comment = "\"Static code analysis was PASSED\""
                // Add comment to recently checked pull request
                comment_cmd = 'python3.6 ' + folder + '/jenkins_bitbucket_trigger.py --set_pull_request_general_comment ' + pull_request_comment
                // Set APPROVED status to recently checked pull request
                status_command = 'python3.6 ' + folder + '/jenkins_bitbucket_trigger.py --approve_pull_request'
            }
            else {
                pull_request_comment = "\"Static code analysis was FAILED. See details at " + env.JENKINS_URL + "view/Pipelines/job/" + env.JOB_NAME + "/" + env.BUILD_ID + "/\""
                // Add comment to recently checked pull request
                comment_cmd = 'python3.6 ' + folder + '/jenkins_bitbucket_trigger.py --set_pull_request_general_comment ' + pull_request_comment
                // Set NEEDS_WORK status to recently checked pull request
                status_command = 'python3.6 ' + folder + '/jenkins_bitbucket_trigger.py --needs_work_pull_request'
            }
            comment_exit_code = sh (script: comment_cmd, returnStatus: true)
            status_exit_code = sh (script: status_command, returnStatus: true)
        }
    }

    if (email_msg != "") {
//        sh 'echo "Post Build stages done. Final e-mail message is: ' + email_msg + '"'
        currentBuild.result = 'FAILURE'
    }

} // node master