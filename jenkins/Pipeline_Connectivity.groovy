import groovy.json.JsonSlurperClassic

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)

    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def transformIntoStep(job, lab, test_fname) {
    return {
                build job: job, parameters: [string(name: 'ENV_NAME', value: lab), string(name: 'FLOWS', value: test_fname)]
    }
}

def run_stage(job, lab, tests_fnames) {
    def stepsForParallel = [:]
    stage(lab) {
        echo "-------------- JOB: "+job+" ENVIRONMENT: "+lab+" --------------"
        for (int h = 0; h < tests_fnames.size(); h++) {
            echo "Running "+job+": "+tests_fnames[h]+" - Env: "+lab
            stepsForParallel[tests_fnames[h]+"_"+lab] = transformIntoStep(job, lab, tests_fnames[h])
        }
        parallel stepsForParallel
    }
}



node {
    buildResult= 'SUCCESS'
    job = env.CONNECTIVITY_JOB //new JsonSlurperClassic().parseText("${CONNECTIVITY_JOB}")
    print "CONNECTIVITY_JOB:"+job
    labs = new JsonSlurperClassic().parseText("${LABs}")
    print "LABs : "+labs
    tests_fnames = new JsonSlurperClassic().parseText("${FLOWS}")
    print "FLOWS : "+tests_fnames
    for (int i = 0; i < labs.size(); i++) {
        try {
           run_stage(job, labs[i], tests_fnames)
        } catch(err) {
            echo "---------- FAIL: Connectivity flows in "+labs[i]+" (Check Job Build to see which testsuite of the feature fails) ----------"
            buildResult = 'FAILURE'
        }
    }
    currentBuild.result = buildResult
}