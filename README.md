# e2e_si_automation Repository - RobotFramework + Jenkins + Scripts

## Introduction
-------------------

STB Performance Testing 

Folders
-------------------
- jenkins => Jenkins: Groovy Pipelines Code + Pipelinea Configuration files
- scripts => Scripts: Bitbucket, Reporting, Check Posters, Check Manifests Chunks
- robot =>  Robot Framework Code `Robot Framework <http://robotframework.org>`
- robot/resources/stages/conf_{ENV}.py => All configuration variables per Tenant, one file per ENV: obolabecx, obopreprod, oboprod
- robot/Libraries => All Libraries of backend componentes or util used on Keywords/Tests
- robot/Keywords => All keywords used on Tests
- robot/Keywords/CPE => All CPE keywords
- robot/Tests =>  All Robot Framework Test Cases (Tests Suites)
- robot/Tests/CPE =>  CPE Robot Framework Tests Cases

## Where to add a new Target
-------------------
     robot/resources/Rack_Details/${LAB_NAME}.yml =>  Configuration File with all CPE/SLOTs per Tenant [${LAB_NAME}]

Examples: 
- robot/resources/Rack_Details/preprod_nl.yml
- robot/resources/Rack_Details/prod_nl.yml

#### Tests Case in Development = NOT Done

Every tests that it is in progress or needs improvements, those that are NOT DONE, Should be tagged as ```IN_PROGRESS``` using Force Tags.
On Jenkins, We have ```--exclude IN_PROGRESS``` so the Jenkins job will exclude those to be run.

#### Rack_Details

Check ```robot/resources/Rack_Details/_Rack_Details_Schema.yml``` to see requeries keys and default values

###### OSD_LANGUAGE:
It will be an Environment variable, Use on Jenkins if need it. If the ENV var is not defined the Rack details Key/Value will be used, if there is no ENV var and no RackDetails Key/Value then by default will be set to "en" English.
The UI language will be set it automatically on Suite Setup ```Default Suite Setup``` to the value of OSD_LANGUAGE Suite variable

## How to run Robot Framework
-------------------
Go to robot folder (cd robot)
#### Run CPE Tests Example:
```
robot --loglevel DEBUG  --variable=RACK_SLOT_ID:FCOBOS-RACK-SLOT-LABSUPERSET-2 --variable=LAB_NAME:labe2esuperset --variablefile=resources/stages/conf_debug.py Tests/03_Profile/HES-2867_Profile_creation_wizard.robot
```

##### It is also possible to use tags:
-  ```--variable=KEY:VALUE```
-  ```--variablefile=resources/stages/conf_obolabecx.py```
-  ```--variable=RACK_SLOT_ID:FCOBOS-RACK-SLOT-PROD-NL-1```

##### CPE Suite Setup and Teardown:
- ```Suite Setup       Default Suite Setup```
- ```Suite Teardown    Default Suite Teardown```

##### CPE Tests Setup (First):
- ```[Setup]    Default First TestCase Setup```

##  Servers involved
-------------------

### OBO Lab ECX:  [```obolab.ecx.e2erobot.inventory.yml```](https://bitbucket.upc.biz/projects/CHA/repos/e2e_robot_deployment/browse/high_availability/obolab.ecx.e2erobot.inventory.yml)
- MT_tst_e2erobot_01 = lg-l-p-obo00333
- 5A_tst_e2erobot_proxy_01 = lg-l-p-obo00366
- 5A_tst_e2erobot_proxy_02 = lg-l-p-obo00367

### OBO PREPROD:  [```oboprod_pre.inventory.yml```](https://bitbucket.upc.biz/projects/CHA/repos/e2e_robot_deployment/browse/high_availability/oboprod_pre.inventory.yml)
- **TBD**

### OBO PROD:  [```oboprod.inventory.yml```](https://bitbucket.upc.biz/projects/CHA/repos/e2e_robot_deployment/browse/high_availability/oboprod.inventory.yml)
- **TBD**

### Roles
-------------------

| Roles | Path |
| ------ | ------ |
| Jenkins | [jenkins][R_je] |
| Scripts | [scripts][R_sc] |
| Robot | [robot][R_rf] |
| Libraries | [robot/Libraries][R_li] |

### Contributors
-------------------

 
 ### Author
-------------------

