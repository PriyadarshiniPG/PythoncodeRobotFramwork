// recepients = 'esuleyman@libertyglobal.com,rvdmoosdijk@libertyglobal.com,fecobos@libertyglobal.com,ipetrash.contractor@libertyglobal.com'
recepients = 'fecobos@libertyglobal.com'
admin = 'ipetrash.contractor@libertyglobal.com'
containerArgs = '--name Pipeline_EPG_images_validation'
/*containerArgs = '--add-host epg.prod.nl.dmdsdp.com:'+env.EPG_PROD_NL_IP+
                ' --add-host epg.prod.ch.dmdsdp.com:'+env.EPG_PROD_CH_IP+
                ' --add-host epg.prod.de.dmdsdp.com:'+env.EPG_PROD_DE_IP+
                ' --add-host staticqbr-nl-prod.prod.cdn.dmdsdp.com:'+env.STATICQBR_NL
                ' --add-host staticqbr-ch-prod.prod.cdn.dmdsdp.com:'+env.STATICQBR_CH
                ' --add-host staticqbr-de-prod.prod.cdn.dmdsdp.com:'+env.STATICQBR_DE
*/
//http://epg.prod.uk.dmdsdp.com/gb/en/events/segments/index
countries = ["NL", "CH", "GB", "DE", "IE", "PL", "AT", "CZ", "HU", "RO", "SK"]
countries = ["NL", "CH", "GB"]  // others are not ready
conf = [:]
conf["NL"] = [language: "nl", endpoint: "epg.prod.nl.dmdsdp.com", start: 7, finish: 7]
conf["CH"] = [language: "de", endpoint: "epg.prod.ch.dmdsdp.com", start: 7, finish: 7]
conf["GB"] = [language: "en", endpoint: "epg.prod.uk.dmdsdp.com", start: 7, finish: 7]
conf["DE"] = [language: "de", endpoint: "epg.prod.de.dmdsdp.com", start: 7, finish: 7]
conf["IE"] = [language: "en", endpoint: "epg.prod.ie.dmdsdp.com", start: 7, finish: 7]
conf["PL"] = [language: "pl", endpoint: "epg.prod.pl.dmdsdp.com", start: 7, finish: 7]
conf["AT"] = [language: "de", endpoint: "epg.prod.at.dmdsdp.com", start: 7, finish: 7]
conf["CZ"] = [language: "cz", endpoint: "epg.prod.cz.dmdsdp.com", start: 7, finish: 7]
conf["HU"] = [language: "hu", endpoint: "epg.prod.hu.dmdsdp.com", start: 7, finish: 7]
conf["RO"] = [language: "ro", endpoint: "epg.prod.ro.dmdsdp.com", start: 7, finish: 7]
conf["SK"] = [language: "sk", endpoint: "epg.prod.sk.dmdsdp.com", start: 7, finish: 7]
conf["BE"] = [language: "nl", endpoint: "epg.labe2esi.nl.dmdsdp.com", start: 7, finish: 7] // lab, oboposter endpoint gives 504 Gateway Timeout

def run_stage(folder, endpoint, country, language, start, finish) {
    msg = ""
    cmd = 'cd ' + folder + '; /usr/local/bin/python3.6 verify_images_urls.py --conf=' + env.CONF_FILE + ' -v --endpoint=' + endpoint + ' --country=' + country + ' --language=' + language + ' --start=' + start + ' --finish=' + finish + ' > /dev/null 1> result.out || exit $?'
    ret = sh (script: cmd, returnStatus: true)
    sh 'cat ' + folder + '/result.out'
    if (ret != 0) {
        def lines = new File(folder + '/result.out').readLines()
        msg = lines.get(lines.size() - 1)
    }
    return msg
}

node('master') {
    def results = []
    cleanWs() // clean workspace
    email_msg = ""
    docker.image('robot3').inside(containerArgs) {
        git branch: 'master',
            credentialsId: '263e7fed-d1c2-4850-9bc7-87cff6f5402a',
            url: 'ssh://git@bitbucket.upc.biz:7999/cha/e2e_si_automation.git'
        folder = sh (script: 'pwd', returnStdout: true).trim() + '/scripts/check_posters'
        for (int i = 0; i < countries.size(); i++) {
            stage(countries[i]) {
                stage_msg = run_stage(folder, conf[countries[i]]["endpoint"], countries[i], conf[countries[i]]["language"], conf[countries[i]]["start"], conf[countries[i]]["finish"])
                if (stage_msg == "") {   
                    result = 'passed' 
                }
                else {  
                    result = 'failed: ' + stage_msg
                    email_msg += '\n\t- for country ' + countries[i] + ': ' + stage_msg
                }

                reports_pdfs = 'scripts/check_posters/*' + countries[i] + '*.pdf'
                archiveArtifacts artifacts: reports_pdfs

               msg = 'Dear colleague,\n\nEPG Images validation for country '+ countries[i] + ' is completed (' + result + ').\nPlease find the reports attached and Kibana dashboard at http://odh.obo.appdev.io/kibana/app/kibana#/dashboard/e2erobot_EPG_Events\n\n\nBest Regards,\n   Jenkins.'
               emailext body: msg, subject: 'EPG images validation for country ' + countries[i] + ' ' + result, attachmentsPattern: reports_pdfs, to: recepients
                results.add(result)
            }
        } // for

    } // Docker

   if (email_msg != "" && env.CONF_FILE != "conf_debug.py") {
      email_msg = 'Dear colleague,\n\n'+ env.JOB_NAME + ' is completed.\nUnfortunately, not everything went successfully.\n\nBelow should be addressed:\n' + email_msg
      //email_msg += '\n\nPlease visit Jenkins at: ' + env.BUILD_URL
      email_msg += '\n\nPlease visit Kibana dashboard at http://odh.obo.appdev.io/kibana/app/kibana#/dashboard/e2erobot_EPG_Events'
      email_msg += '\n\nBest Regards,\n   Jenkins.'
      emailext body: email_msg, subject: 'Jenkins job ' + env.JOB_NAME + ' has issue(s)', to: admin
    //   sh 'echo "Post Build stages are done. Final e-mail message is: ' + email_msg + '"'
   }

    for (int i = 0; i < results.size(); i++) {
        if (results[i].contains("failed")) {
            currentBuild.result = 'FAILURE'
        }
    }

} // node master