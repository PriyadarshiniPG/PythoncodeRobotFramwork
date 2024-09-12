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

def transformIntoSanityStep(job, cpe, lab, cpe_fw_version, description, location) {
    return {
                build job: job, parameters: [string(name: 'CPE_ID', value: cpe),
                    string(name: 'LAB_NAME', value: lab), string(name: 'CPE_FW_VERSION', value: cpe_fw_version),
                    string(name: 'DESCRIPTION', value: description), string(name: 'LOCATION', value: location)]
    }
}

// ****************************************************************************************
// main script block
// could use eg. params.parallel build parameter to choose parallel/serial 
def runParallel = true
def buildStages

// Create List of build stages to suit
def prepareBuildStages(cpe_list, build_list_number = 1) {
   def buildList = []
   for (b=1; b<(build_list_number+1); b++) {
    def buildStages = [:]
    for (int i = 0; i < cpe_list.size(); i++) {
      def n = cpe_list[i]["name"]+" - "+cpe_list[i]["cpe"].replace("3C36E4-", "").replace("0000F0-", "")
      print "n:"+n
      buildStages.put(n, prepareOneBuildStage(cpe_list[i]))
    }
    buildList.add(buildStages)
  }
  print "buildList: "+buildList
  return buildList
}

def prepareOneBuildStage(cpe_data) {
  //print "cpe_data: "+cpe_data
  def cpe = cpe_data["cpe"]
  def cpe_name = cpe_data["name"]
  def name = cpe_name+" - "+cpe.replace("3C36E4-", "").replace("0000F0-", "")
  return {
    stage(name) {
      println("Building Stage: "+name)
      echo "-------------- Running - job: "+job+": "+cpe+" - "+Get_Timestap()+" --------------"
      Boolean active = (Boolean) cpe_data["active"];
      def stepsForParallel = [:]
      if (active) {
          String lab = (String) cpe_data["lab"];
          String description = (String) cpe_data["name"];
          if (cpe_data.containsKey("repo")) {
            repo = (String) cpe_data["repo"];
          }else{
            repo = ''
          }
          if (cpe_data.containsKey("cpe_fw_version")) {
            cpe_fw_version = (String) cpe_data["cpe_fw_version"];
          }else{
            cpe_fw_version = ''
          }
          if (cpe_data.containsKey("location")) {
            location = (String) cpe_data["location"];
          }else{
            location = ''
          }
          echo "Running - job: "+job+" on "+cpe_name+"["+cpe+"] Lab: "+lab+" - description: "+description+" - location: "+location
// If WE HAVE ONLY ONE JOB WE CAN DO IT LIKE THIS - Other way is more generic
//          build job: job, parameters: [string(name: 'CPE_ID', value: cpe),
//                        string(name: 'LAB_NAME', value: lab), string(name: 'CPE_FW_VERSION', value: cpe_fw_version),
//                        string(name: 'DESCRIPTION', value: description), string(name: 'LOCATION', value: location)]
          stepsForParallel[job+"_"+cpe_name+"_"+cpe] = transformIntoSanityStep(job, cpe, lab, cpe_fw_version, description, location)
      }else {
          print cpe+" - Not Active for pipeline"
      }
//      print "stepsForParallel: "+stepsForParallel
      parallel stepsForParallel
    }
  }
}

node('master') {
    buildResult= 'SUCCESS'
    print "------------------  START PIPELINE: "+Get_Timestap()+"  ------------------"

// Print Variables from Pipeline
    print "PIPELINE_CONFIG_BRANCH: $PIPELINE_CONFIG_BRANCH"
    print "PIPELINE_FILE: $PIPELINE_FILE"
    print "PIPELINE_GROOVY_FILE: $PIPELINE_GROOVY_FILE"
    print "PIPELINE_CPE_CONFIG_FILE: $PIPELINE_CPE_CONFIG_FILE"
    print "CPE_SANITY_JOB: $CPE_SANITY_JOB"

// Global VAR job
    job = "$CPE_SANITY_JOB"
    print "job: "+job

// Get Configuration file for Pipeline
    git branch: "$PIPELINE_CONFIG_BRANCH", credentialsId: '263e7fed-d1c2-4850-9bc7-87cff6f5402a', url: 'ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git'
    def json_conf_file = readFile(file:"$PIPELINE_CPE_CONFIG_FILE")
  // FOR DEBUG
    //json_conf_file = '[{"name":"R1_PI1","active":true,"cpe":"3C36E4-EOSSTB-003357916802","repo":"eos_srxx","lab":"labe2esuperset","cpe_fw_version":"063-ae"},{"name":"R1_PI2","active":true,"cpe":"3C36E4-EOSSTB-003469773406","repo":"eos_srxx","lab":"labe2esuperset","cpe_fw_version":"063-ae"}]'
    //json_conf_file = '[{"name":"SS-3","active":true,"cpe":"3C36E4-EOSSTB-003469693109","repo":"eos_srxx","lab":"labe2esuperset","cpe_fw_version":"063-ag"},{"name":"R1_PI12","active":true,"cpe":"3C36E4-EOSSTB-003504069802","repo":"eos_srxx","lab":"labe2esuperset","cpe_fw_version":"063-ae"}]'
    cpe_list = new JsonSlurperClassic().parseText( json_conf_file )
    print "Number of CPEs on config file $PIPELINE_CPE_CONFIG_FILE : "+cpe_list.size()
//    print "cpe_list: "+cpe_list
//    print "cpe_list[0] : "+cpe_list[0]
//    print "cpe_list[1] : "+cpe_list[1]

  stage('Initialise') {
    // Set up List<Map<String,Closure>> describing the builds
    //print "cpe_list in Initialise stage: "+cpe_list
    print "job GLOBAL var in Initialise stage: "+job
    //print "CPE_SANITY_JOB env var in Initialise stage: $CPE_SANITY_JOB"
    buildStages = prepareBuildStages(cpe_list)
    println("Initialised pipeline.")
  }

  for (builds in buildStages) {
    if (runParallel) {
      try {
        parallel(builds)
      } catch(err) {
        echo "---------- FAIL: "+Get_Timestap()+" (Check stages to see which failed) ----------"
        buildResult = 'FAILURE'
      }
    } else {
      // run serially (nb. Map is unordered! )
      print "Not runParallel so it will made the build.call() - so runParallel: False"
      for (build in builds.values()) {
        build.call()
      }
    }
  }

  stage('Finish') {
      println('Pipeline complete.')
      print "------------------  END PIPELINE: "+Get_Timestap()+"  ------------------"
  }
}