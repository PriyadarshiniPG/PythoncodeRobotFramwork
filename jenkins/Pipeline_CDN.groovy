import groovy.json.JsonSlurperClassic

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)
    
    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def transformIntoStep(job, lab, web_object) {
    return {
                build job: job, parameters: [string(name: 'LAB_NAME', value: lab), string(name: 'WEB_OBJECT', value: web_object)]
    }
}

def run_stage(job, labs, web_object) {
    def stepsForParallel = [:]
    stage(web_object) {
        echo "-------------- JOB: "+job+" WEB_OBJECT: "+web_object+" --------------"
        for (int h = 0; h < labs.size(); h++) {
            echo "Running "+job+": "+web_object+" - Lab: "+labs[h]
            stepsForParallel[web_object+"_"+labs[h]] = transformIntoStep(job, labs[h], web_object)
        }
        parallel stepsForParallel
    }
}



node {
    buildResult= 'SUCCESS'
    job = env.CDN_JOB //new JsonSlurperClassic().parseText("${CDN_JOB}")
    print "OTT_JOB:"+job
    labs = new JsonSlurperClassic().parseText("${LABs}")
    print "LABs : "+labs
    web_objects = new JsonSlurperClassic().parseText("${WEB_OBJECTS}")
    print "WEB_OBJECTS : "+web_objects
    for (int i = 0; i < web_objects.size(); i++) {
        try {
           run_stage(job, labs, web_objects[i])
        } catch(err) {
            echo "---------- FAIL: Feature: "+web_objects[i]+" (Check Job Build to see which testsuite of the feature fails) ----------"
            buildResult = 'FAILURE'
        }
    }
    currentBuild.result = buildResult
}
