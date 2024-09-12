import yaml
from robot.libraries.BuiltIn import BuiltIn
import os

def update_test_config(variable_name, value):
    affiliate_environment = BuiltIn().get_variable_value("${LAB_NAME}")
    product = BuiltIn().get_variable_value("${PRODUCT}")
    file_name = "temp/{0}_{1}_config.yaml".format(affiliate_environment, product).lower()
    config = yaml.load(open(file_name, "r",encoding="utf-8"), Loader=yaml.FullLoader) if os.path.exists(file_name) else {}
    config[variable_name] = value
    with open(file_name, "w+",encoding="utf-8") as fp:
        yaml.dump(config, fp, allow_unicode=True)