echo off
IF EXIST "Performance_Stat.json" (
    del "Performance_Stat.json"
)
set arg1=%1
set arg2=%2
robot --loglevel DEBUG --variable=RACK_SLOT_ID:KHU-RACK-SLOT-PROD-NL-18 --variable=LAB_NAME:prod_nl --variablefile=resources/stages/conf_oboprod.py --variablefile=resources/config/prod_nl_eos_config.py -i %arg2% %arg1%