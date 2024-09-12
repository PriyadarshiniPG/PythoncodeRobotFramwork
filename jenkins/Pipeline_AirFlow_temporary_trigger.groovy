/*
This trigger supposes to work while we support two DAGs types:
- csi_lab_create_obo_assets_workflow
- csi_lab_create_obo_assets_transcoding_driven_workflow
 */
import groovy.json.JsonSlurperClassic
import java.text.SimpleDateFormat
import java.util.Calendar
def dateFormat
def date
def currentDate
def timeunits
def formattedDate

recipients = env.EMAIL_RECIPIENTS

def get_gmt_time() {
    date = Calendar.getInstance();
    timeunits= date.getTimeInMillis();
    currentDate=new Date(timeunits);
    dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    dateFormat.timeZone = java.util.TimeZone.getTimeZone( 'GMT' )
    formattedDate = dateFormat.format(currentDate)
    return formattedDate
}

def parseJson(jsonString) {
    // Would like to use readJSON step, but it requires a context, even for parsing just text.
    def lazyMap = new JsonSlurperClassic().parseText(jsonString)

    // JsonSlurper returns a non-serializable LazyMap, so copy it into a regular map before returning
    def m = [:]
    m.putAll(lazyMap)
    return m
}

def transformIntoStep(job, lab, dag, pause) {
    return {
        stage_name = dag
        stage(stage_name) {
            echo "-------------- JOB: "+job+" TEST for DAG: "+dag+" --------------"
            sleep pause
            build job: job, parameters: [string(name: 'LAB', value: lab), string(name: 'EXPECTED_DAG', value: dag)]
        }
    }
}

def run_tests_in_parallel(job, lab, dags, pauses) {
    def stepsForParallel = [:]
    for (int i = 0; i < dags.size(); i++) {
        stepsForParallel[dags[i]] = transformIntoStep(job, lab, dags[i], pauses[i])
    }
    parallel stepsForParallel
}



node {
    start_time = get_gmt_time()
    print start_time
    buildResult= 'SUCCESS'
    job = env.AIRFLOW_PIPELINE
    print "AIRFLOW_PIPELINE:"+job
    lab = env.LAB
    print "LAB : "+lab
    dags = new JsonSlurperClassic().parseText("${DAG_TYPES}")
    pauses = new JsonSlurperClassic().parseText("${PAUSES}")
    print "DAGs : "+dags
    try {
        run_tests_in_parallel(job, lab, dags, pauses)
    } catch(err) {
        echo "---------- FAIL!!! Error is: "+err+""
        buildResult = 'FAILURE'
    }
    sleep 2

    end_time = get_gmt_time()
    print end_time
    kibana_results_link = "http://odh.ecx.appdev.io/kibana6/app/kibana#/dashboard/025995b0-6573-11e8-b117-895ab33416ff?\
_a=(description:'Monitoring%20dashboard%20for%20the%20Tests%20that%20are%20running%20on%20E2EROBOT%20on%20OBO%20Lab:%20Reported%20by%20Testcase',\
filters:!(('\$state':(store:appState),meta:(alias:!n,disabled:!f,index:b0b0a3f0-918e-11e8-b640-2f3d7e50490a,key:lab,negate:!f,\
params:(query:labobocsi,type:phrase),type:phrase,value:labobocsi),query:(match:(lab:(query:labobocsi,type:phrase))))),\
fullScreenMode:!f,options:(darkTheme:!f,useMargins:!f),panels:!((gridData:(h:52,i:'1',w:48,x:0,y:0),\
id:'17047560-6574-11e8-be43-13e2d78e635f',panelIndex:'1',type:visualization,version:'6.3.1'),(embeddableConfig:(vis:(params:(sort:(columnIndex:!n,direction:!n)))),\
gridData:(h:15,i:'2',w:48,x:0,y:52),id:aa514f60-6573-11e8-afca-79ca09929893,panelIndex:'2',type:visualization,version:'6.3.1')),\
query:(language:lucene,query:(match_all:())),timeRestore:!t,title:e2erobot_Testcase_Monitor,viewMode:view)&_g=(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'" + start_time + "',mode:absolute,to:'" + end_time + "'))"

    print kibana_results_link
    emailext body: 'Dear colleague,\n\n'+ env.JOB_NAME + ' daily job run is completed.\n\nPlease visit Kibana at:\n' + kibana_results_link + '\n\nBest Regards,\nJenkins.', subject: 'Jenkins job ' + env.JOB_NAME + ' daily results report', to: recipients


    currentBuild.result = buildResult
}