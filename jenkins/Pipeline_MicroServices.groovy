import groovy.json.JsonSlurperClassic

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)

    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def transformIntoStep(job, lab) {
    return {
                build job: job, parameters: [string(name: 'LAB_NAME', value: lab)]
    }
}

def run_stage(job, labs) {
    def stepsForParallel = [:]
    stage(job) {
        echo "-------------- JOB: "+job+" --------------"
        for (int h = 0; h < labs.size(); h++) {
            echo "Running: "+job+" - Lab: "+labs[h]
            stepsForParallel[job+"_"+labs[h]] = transformIntoStep(job, labs[h])
        }
        parallel stepsForParallel
    }
}



node {
    buildResult= 'SUCCESS'
    jobs = new JsonSlurperClassic().parseText("${MSERVICES_JOBS}")
    print "OTT_JOBS:"+jobs
    labs = new JsonSlurperClassic().parseText("${LABs}")
    print "LABs : "+labs
    for (int i = 0; i < jobs.size(); i++) {
        try {
           run_stage(jobs[i],labs)
        } catch(err) {
            echo "---------- FAIL: Feature: "+jobs[i]+" (Check Job Build to see which testsuite of the feature fails) ----------"
            buildResult = 'FAILURE'
        }
    }
    currentBuild.result = buildResult
}