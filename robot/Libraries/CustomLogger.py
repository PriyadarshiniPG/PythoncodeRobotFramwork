import json
import os
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn

class PerfDataLogger():
    __instance = None

    @staticmethod
    def get_instance():
        if PerfDataLogger.__instance == None:
            PerfDataLogger()
        return PerfDataLogger.__instance

    def __init__(self):
        self.context = None
        test_cycle = os.getenv('TEST_CYCLE')
        test_cycle = test_cycle if test_cycle else "1"
        cpe_build = BuiltIn().get_variable_value("${ACTUAL_CPE_VERSION}")
        app_version = BuiltIn().get_variable_value("${ACTUAL_APP_VERSION}")
        affiliate_environment = BuiltIn().get_variable_value("${LAB_NAME}").replace("_","")

        cpe_id = BuiltIn().get_variable_value("${CPE_ID}").replace("_", "")
        product = BuiltIn().get_variable_value("${PRODUCT}").replace("_", "")
        tag = BuiltIn().get_variable_value("${LAB_NAME}").upper().replace("_","-") + "-" +product.upper()
        model = BuiltIn().get_variable_value("${EXACT_PLATFORM}")
        base_dir = f"{app_version}/{tag}/{cpe_build}/cycle-{test_cycle}"
        dir_name = base_dir + "/{0}_{1}_{2}_{3}".format(affiliate_environment,product,model,cpe_id)
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)

        self.file_name = "{0}/{1}__{2}__{3}__{4}.json".format(dir_name, os.getenv('CONNECTION'),
                                                          os.getenv('LOCATION'),
                                                          os.getenv('RECORDING_LEVEL'),
                                                          os.getenv('BUILD_NUMBER'))
        if PerfDataLogger.__instance is None:
            PerfDataLogger.__instance = self

    def set_context(self, context):
        if context.lower() == "none":
            self.context = None
        else:
            self.context = context

    def log_action(self, action):
        if self.context is None:
            BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'False')
            return
        if os.path.exists(self.file_name):
            node = json.load(open(self.file_name,"r"));
        else:
            node = {"tests":{}}
        if self.context in node["tests"]:
            if "_Done" in action:
                prev_action = node["tests"][self.context][-1]["action"]
                if (prev_action+"_Done") != action:
                    BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'False')
                    return
                last_http_time = BuiltIn().get_variable_value("${LAST_HTTP_TIME}")
                perf_check_xap_timedout = BuiltIn().get_variable_value("${PERF_CHECK_XAP_TIMEDOUT}")
                if perf_check_xap_timedout == 'False':
                    node["tests"][self.context].append(
                        {"time": datetime.now().strftime("%Y-%m-%d, %H:%M:%S.%f"), "action": action,
                         "last_http_time": float(last_http_time)})
                BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'False')
            else:
                BuiltIn().set_global_variable("${PERF_CHECK_XAP_TIMEDOUT}", 'False')
                #Reset http elapsed time
                BuiltIn().set_suite_variable("${LAST_HTTP_TIME}", 0)
                node["tests"][self.context].append(
                        {"time": datetime.now().strftime("%Y-%m-%d, %H:%M:%S.%f"), "action": action})
                BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'True')
        else:
            if "_Done" in action:
                BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'False')
                return
            node["tests"][self.context] = [({"time": datetime.now().strftime("%Y-%m-%d, %H:%M:%S.%f"), "action": action})]
            BuiltIn().set_global_variable("${XAP_TIMEOUT}", 'True')
            BuiltIn().set_global_variable("${PERF_CHECK_XAP_TIMEDOUT}", 'False')
        with open(self.file_name, "w+") as fp:
            json.dump(node,fp)


def set_context(context):
    perf_logger = PerfDataLogger.get_instance()
    perf_logger.set_context(context)


def log_action(action):
    perf_logger = PerfDataLogger.get_instance()
    perf_logger.log_action(action)

