import groovy.json.JsonSlurperClassic

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)

    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def transformIntoStep(job, lab, cpe_id, tests_folder) {
    return {
        build job: job, parameters: [string(name: 'LAB_NAME', value: lab),string(name: 'CPE_ID', value: cpe_id), string(name: 'TESTS_FOLDER', value: tests_folder), string(name: 'RELEASE_VERSION', value: env.RELEASE_VERSION)]
    }
}

def run_stage(job, labs, labs_cpes, tests_folder) {
    def stepsForParallel = [:]
    stage(tests_folder) {
        echo "-------------- JOB: "+job+" TESTS_FOLDER: "+tests_folder+" --------------"
        for (int k = 0; k < labs.size(); k++) {
            if (labs[k] in labs_cpes.keySet()){
                cpes=labs_cpes.get(labs[k]).get("CPEs")
                for (int h = 0; h < cpes.size(); h++) {
                    echo "Running "+job+": "+tests_folder+" - Lab: "+labs[k]+" - CPE_ID: "+cpes[h]
                    stepsForParallel[tests_folder+"_"+labs[k]+"_"+cpes[h]] = transformIntoStep(job, labs[k], cpes[h], tests_folder)
                }
                cpes=[]
            }else{
                print "\nERROR "+labs[k]+" NOT IN "+jsonInput.keySet()
            }
        }
        parallel stepsForParallel
    }
}



node {
    buildResult= 'SUCCESS'
    job = env.API_JOB //new JsonSlurperClassic().parseText("${API_JOB}")
    print "API_JOB:"+job
    labs = new JsonSlurperClassic().parseText("${LABs}")
    print "LABs : "+labs
    tests_folders = new JsonSlurperClassic().parseText("${TESTS_FOLDERS}")
    print "TESTS_FOLDERS : "+tests_folders

    print "PIPELINE_FILE: $PIPELINE_FILE"
    print "PIPELINE_GROOVY_FILE: $PIPELINE_GROOVY_FILE"
    print "PIPELINE_CPE_CONFIG_FILE: $PIPELINE_CPE_CONFIG_FILE"

  // GIT PARAMETERS
    print "PIPELINE_GIT_REPO: $PIPELINE_GIT_REPO"
    //ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git
    //ssh://jenkins@172.17.0.1/var/lib/jenkins/repositories/e2e_si_automation.git
    print "PIPELINE_GIT_CONFIG_BRANCH: $PIPELINE_GIT_CONFIG_BRANCH"
    print "PIPELINE_GIT_CREDENTIALS_ID: $PIPELINE_GIT_CREDENTIALS_ID"
    //263e7fed-d1c2-4850-9bc7-87cff6f5402a
    
// Get Configuration file for Pipeline - From GIT REPO
    //git branch: "$PIPELINE_GIT_CONFIG_BRANCH", credentialsId: "$PIPELINE_GIT_CREDENTIALS_ID", url: 'ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git'
    //From Local
    //git branch: "$PIPELINE_GIT_CONFIG_BRANCH", credentialsId: "$PIPELINE_GIT_CREDENTIALS_ID", url: 'ssh://jenkins@172.17.0.1/var/lib/jenkins/repositories/e2e_si_automation.git'
    git branch: "$PIPELINE_GIT_CONFIG_BRANCH", credentialsId: "$PIPELINE_GIT_CREDENTIALS_ID", url: "$PIPELINE_GIT_REPO"
    
// FOR DEBUG
//    json ='''{
//    "labe2esi": {
//        "CPEs": ["3C36E4-EOSSTB-003470339106","0000F0-HZNSTB-000010923041"]
//    },
//    "labe2esuperset": {
//        "CPEs": ["3C36E4-EOSSTB-003470339106","0000F0-HZNSTB-000010923041"]
//    }
//    }'''
//    print "json: "+json
//    cpes_json = parseJson(json)
//    print "cpes_json: "+cpes_json
//    print "cpes_json KEYS: "+cpes_json.keySet()
//    if ("labe2esi" in cpes_json.keySet()){
//       print "\nYES"
//    }
//    cpes = cpes_json.get("labe2esi").get("CPEs")
//    print "cpes: "+cpes
//    print "cpes[1]: "+cpes[1]
//    print "cpes.size(): "+cpes.size()
//    for (int b = 0; b < cpes.size(); b++) {
//       print "cpes"+b+": "+cpes[b]
//    }

//Read Config JSON File
    def json = readFile(file:"$PIPELINE_CPE_CONFIG_FILE")
 
    cpes_json = parseJson(json)
    print "cpes_json: "+cpes_json
    print "cpes_json KEYS: "+cpes_json.keySet()

    for (int i = 0; i < tests_folders.size(); i++) {
        try {
           run_stage(job, labs, cpes_json, tests_folders[i])
        } catch(err) {
            if (err.toString().contains('UNSTABLE')){
                echo "---------- UNSTABLE: Feature: "+tests_folders[i]+" (Check Job Build to see which testsuite of the feature is unstable)"
                echo "Error is: "+ err
                buildResult = 'UNSTABLE'
            }else{
                echo "---------- FAIL: Feature: "+tests_folders[i]+" (Check Job Build to see which testsuite of the feature fails)"
                echo "Error is: "+ err
                buildResult = 'FAILURE'
            }
        }
    }
    currentBuild.result = buildResult
}