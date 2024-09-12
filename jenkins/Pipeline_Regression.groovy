import groovy.json.JsonSlurperClassic
import java.text.SimpleDateFormat

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)

    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def Get_Timestap() {
    Date now = new Date()
    SimpleDateFormat timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
    return timestamp.format(now)
}

def run_stage(job, jsonInput) {
    stage(job) {
        echo "-------------- Running - Stage/job: "+job+" - "+Get_Timestap()+" --------------"
        def stepsForParallel = [:]
        labs = jsonInput.keySet()
        print "labs : "+labs
        for (int b = 0; b < labs.size(); b++) {
            lab = labs[b]
            print "lab: "+lab
            lab_release_version = jsonInput.get(lab).get("RELEASE_VERSION")
            print lab+" - RELEASE_VERSION: "+lab_release_version
            lab_cpes = jsonInput.get(lab).get("CPEs")
            lab_cpes_rack_slot_id = lab_cpes.keySet()
            print lab+" - lab_cpes: "+lab_cpes
            //print lab+" - lab_cpes_rack_slot_id: "+lab_cpes_rack_slot_id
            for (int k = 0; k < lab_cpes_rack_slot_id.size(); k++) {
                rack_slot_id = lab_cpes_rack_slot_id[k]
                Boolean cpe_active = lab_cpes[lab_cpes_rack_slot_id[k]]
                //print lab+" - cpe["+k+"]: "+rack_slot_id+" - active: "+cpe_active
                if (cpe_active) {
                    //print lab+" - "+rack_slot_id+" - Active for pipeline"
                    stepsForParallel_name = job+"_"+lab+"_"+rack_slot_id
                    print "steps: "+stepsForParallel_name+" - added For Parallel"
                    stepsForParallel[stepsForParallel_name] = transformIntoStep(job, lab, rack_slot_id, lab_release_version, "$PIPELINE_ID")
                }else {
                    print lab+" - "+rack_slot_id+" - NOT Active for pipeline"
                }
            }
        }
        parallel stepsForParallel
    }
}

def transformIntoStep(job, lab, rack_slot_id, release_version, pipeline_id) {
    return {
                build job: job, parameters: [string(name: 'LAB_NAME', value: lab),
                    string(name: 'RACK_SLOT_ID', value: rack_slot_id), string(name: 'RELEASE_VERSION', value: release_version),
                    string(name: 'PIPELINE_ID', value: pipeline_id)]
    }
}

node('master') {
    buildResult= 'SUCCESS'

    print "------------------  START PIPELINE: "+Get_Timestap()+"  ------------------"

// Print Variables from Pipeline
    print "PIPELINE_FILE: $PIPELINE_FILE"
    // jenkins/Pipeline_Regression
    print "PIPELINE_GROOVY_FILE: $PIPELINE_GROOVY_FILE"
    // jenkins/Pipeline_Regression.groovy
    print "PIPELINE_CONFIG_FILE: $PIPELINE_CONFIG_FILE"
    // ${PIPELINE_FILE}.json
    // jenkins/Pipeline_Regression_OBOLAB.json
    // jenkins/Pipeline_Regression_OBOPROD.json
    print "CPE_SANITY_JOB: $CPE_SANITY_JOB"
    // CPE_Sanity_Regression
    print "REGRESSION_JOB: $REGRESSION_JOB"
    // Regression
    print "PIPELINE_ID: $PIPELINE_ID"
    // PIPELINE_REGRESSION

  // GIT PARAMETERS
    print "PIPELINE_GIT_REPO: $PIPELINE_GIT_REPO"
    //ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git
    //ssh://jenkins@172.17.0.1/var/lib/jenkins/repositories/e2e_si_automation.git
    print "PIPELINE_GIT_CONFIG_BRANCH: $PIPELINE_GIT_CONFIG_BRANCH"
    // fcobos/hybrid_onem or master
    print "PIPELINE_GIT_CREDENTIALS_ID: $PIPELINE_GIT_CREDENTIALS_ID"

// Get Configuration file for Pipeline
    git branch: "$PIPELINE_GIT_CONFIG_BRANCH", credentialsId: "$PIPELINE_GIT_CREDENTIALS_ID", url: "$PIPELINE_GIT_REPO"
    def json = readFile(file:"$PIPELINE_CONFIG_FILE")
    jsonInput = parseJson(json)

// **************** START FOR DEBUG ****************
//    json ='''{
//    "labe2esi": {
//        "RELEASE_VERSION": "fcobos/Regression_Pipeline",
//        "CPEs": {
//              "FCOBOS-LOCAL-LABE2ESI-1": true,
//        }
//    },
//    "labe2esuperset": {
//        "RELEASE_VERSION": "fcobos/Regression_Pipeline",
//        "CPEs": {
//              "FCOBOS-LOCAL-LABSUPERSET-1": true,
//              "FCOBOS-LOCAL-LABSUPERSET-2": true,
//              "FCOBOS-LOCAL-LABSUPERSET-3": false
//        }
//    }
//}'''
    print "json: "+json
//    jsonInput = parseJson(json)
//    print "jsonInput: "+jsonInput
//    labs = jsonInput.keySet()
//
//    print "labs : "+labs
//    print "labs KEYS0: "+labs[0]
//    print "labs SIZE: "+labs.size()
//    for (int b = 0; b < labs.size(); b++) {
//        print "labs["+b+"]: "+labs[b]
//        lab_release_version = jsonInput.get(labs[b]).get("RELEASE_VERSION")
//        print labs[b]+" - RELEASE_VERSION: "+lab_release_version
//        lab_cpes = jsonInput.get(labs[b]).get("CPEs")
//        lab_cpes_rack_slot_id = lab_cpes.keySet()
//        print "lab_cpes: "+lab_cpes
//        print "lab_cpes_rack_slot_id: "+lab_cpes_rack_slot_id
//
//        for (int k = 0; k < lab_cpes_rack_slot_id.size(); k++) {
//            rack_slot_id = lab_cpes_rack_slot_id[k]
//            Boolean cpe_active = lab_cpes[lab_cpes_rack_slot_id[k]]
//            if (cpe_active) {
//               print rack_slot_id+" - Active for pipeline"
//            }else {
//               print rack_slot_id+" - NOT Active for pipeline"
//            }
//            print labs[b]+" - cpe["+k+"]: "+rack_slot_id+" - active: "+cpe_active
//        }
//    }
// **************** END FOR DEBUG ****************

// **************** CPE_SANITY STAGE ****************
    try {
        echo "---------- START: job: $CPE_SANITY_JOB - Stage: SANITY"+" - "+Get_Timestap()+" --------"
        run_stage("$CPE_SANITY_JOB", jsonInput)
        echo "---------- END: job: $CPE_SANITY_JOB - Stage: SANITY"+" - "+Get_Timestap()+" --------"
    } catch(err) {
        echo "---------- FAIL: job: $CPE_SANITY_JOB - Stage: SANITY"+" - "+Get_Timestap()+" (Check Job Build to see which testsuite of the feature fails) ----------"
        buildResult = 'FAILURE'
    }

// **************** REGRESSION STAGE ****************
//ON GOING
// **************** END REGRESSION STAGE ****************


    print "------------------  END PIPELINE: "+Get_Timestap()+"  ------------------"
    currentBuild.result = buildResult
}