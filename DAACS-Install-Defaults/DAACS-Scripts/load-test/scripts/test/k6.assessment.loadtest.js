// https://grafana.com/docs/k6/latest/using-k6/k6-options/reference/#summary-mode



// https://grafana.com/docs/k6/latest/results-output/end-of-test/custom-summary/


// scripts/test/k6.assessment.loadtest.js
// data/input/teststudents.csv
// output=file=data/output/k6.log

/**
  k6 run k6.assessment.loadtest.js --env ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"

  k6 run k6.assessment.loadtest.js --env ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365"
  
  ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" k6 run k6.assessment.loadtest.js 
 
  k6 run k6.assessment.loadtest.js --env ASSESSMENT_ID="e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"
k6 run k6.assessment.loadtest.js --env ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"
ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f,46997151-21a3-4eef-b657-e7dcdd913481" k6 run k6.assessment.loadtest.js


ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" k6 run --out csv=test_results.csv k6.assessment.loadtest.js
ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" k6 run --out csv=test_results.csv k6.assessment.loadtest.js
ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" k6 run k6.assessment.loadtest.js

ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365" k6 run k6.assessment.loadtest.js


ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" k6 run k6.assessment.loadtest.js

ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s k6 run k6.assessment.loadtest.js

ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s k6 run k6.assessment.loadtest.js


ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html k6 run k6.assessment.loadtest.js



ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" k6 run k6.assessment.loadtest.js



ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" K6_SUMMARY_MODE="full" LOGGING_STATUS=1 k6 run k6.assessment.loadtest.js --log-output=file=./k6.log


 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" K6_SUMMARY_MODE="full" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html  k6 run k6.assessment.loadtest.js --log-output=file=./k6.log  --out json=k6.json


 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html  k6 run k6.assessment.loadtest.js --log-output=file=./k6.log  --out json=k6.json

 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html MAX_LOGIN_SLEEP=15  k6 run k6.assessment.loadtest.js --log-output=file=./k6.log  --out json=k6.json


 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED=fase k6 run k6.assessment.loadtest.js --out json=k6.json


 VUS TEST
 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED=fast LOAD_TEST_TYPE_SCENRIO="vus" VUS=1 INTERATION=1 k6 run k6.assessment.loadtest.js --out json=k6.json


 STAGES TEST 

 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-1" k6 run k6.assessment.loadtest.js --out json=k6.json


 ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="slow" LOAD_TEST_TYPE_SCENRIO="stages-ramping-vus" STAGES="30s:100,30s:200,30s:500,30s:200,30s:0" GRACEFUL_STOP="300s" GRACEFUL_RAMP_DOWN="300s" RUN_GET_PDF=false RUN_GET_ASSESSMENT_RESULTS=true MAX_LOGIN_SLEEP=30 INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json


 *  */ 

//  const metrics = {
//   getUserResponseTime: new Trend("get_user_response_time", true),
//   updateUserResponseTime: new Trend("update_user_response_time", true),
//   deleteUserResponseTime: new Trend("delete_user_response_time", true),
// };

// https://www.google.com/search?q=k6+metrics+per+vu&rlz=1C5OZZY_enUS1152US1152&oq=k6+metrics+per+vu&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQIRiPAjIHCAIQIRiPAtIBCDM0MjFqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8
// https://oneuptime.com/blog/post/2026-01-28-k6-scenarios/view
// https://github.com/clinicjs/node-clinic


import { check, sleep } from 'k6';
import http from 'k6/http';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

import { Gauge, Counter, Rate } from 'k6/metrics';

const myTrend = new Counter('total_byes');
    const basePath = __ENV.PWD +'/../'


export let options = {
  assessment_id: __ENV.ASSESSMENT_ID,
  max_login_sleep: __ENV.MAX_LOGIN_SLEEP == undefined ? 15 : __ENV.MAX_LOGIN_SLEEP,
  max_view_start_page_sleep: __ENV.MAX_VIEW_START_PAGE_SLEEP == undefined ? 15 : __ENV.MAX_VIEW_START_PAGE_SLEEP,
  max_pdf_check_sleep: __ENV.MAX_PDF_CHECK_SLEEP == undefined ? 5 : __ENV.MAX_PDF_CHECK_SLEEP,
  logging_status: __ENV.LOGGING_STATUS == undefined ? 0 : parseInt(__ENV.LOGGING_STATUS),
  host: __ENV.HOST,
  test: __ENV.TEST,
  student_file: __ENV.STUDENT_FILE,
  admin_credentials: __ENV.ADMIN_CREDENTIALS,
  run_get_PDF: __ENV.RUN_GET_PDF == "true" ? true : false,
  run_get_assessment_results: __ENV.RUN_GET_ASSESSMENT_RESULTS == "true" ? true : false,
  load_test_type_speed: __ENV.LOAD_TEST_TYPE_SPEED,
  insecureSkipTLSVerify:  __ENV.INSECURE_SKIP_TLS == "true" ? true : false,
  // httpDebug: 'full',
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 0%
    http_req_duration: ['p(99)<500'], // 100% of requests should be below 500ms
    
  },
  assessmentTypeOptions: {
    "cat": {
      answerType: "RANDOM",
      min_sleep: 1,
      max_sleep: 3,
    },
    "writing": {
      min_sleep: 1,
      max_sleep: 3,
    },
    "likert": {
      answerType: "RANDOM",
      min_sleep: 1,
      max_sleep: 3,
    }

  },
  userAssessmentOptions:{
    user_results:{
      min_sleep: 1,
      max_sleep: 3,
    }
  }
};



let total_total = 0;

  let sharedData = new SharedArray("Shared Logins", function () {
    let data = papaparse.parse(open(`${basePath}data/input/${options.student_file}`), { header: true }).data;

    data.map( e => {
      e.used = false;
    })
    return data;
  });



  switch(options.load_test_type_speed){

    //fast 
    case "fast": 
      options.userAssessmentOptions.user_results.min_sleep = 1;
      options.userAssessmentOptions.user_results.max_sleep = 2;

      options.assessmentTypeOptions.cat.min_sleep = 1;
      options.assessmentTypeOptions.cat.max_sleep = 2;
      options.assessmentTypeOptions.writing.min_sleep = 1; 
      options.assessmentTypeOptions.writing.max_sleep = 2;
      options.assessmentTypeOptions.likert.min_sleep = 1;
      options.assessmentTypeOptions.likert.max_sleep = 2;

    break;


    case "medium":
      options.userAssessmentOptions.user_results.min_sleep = 1;
      options.userAssessmentOptions.user_results.max_sleep = 5;

      options.assessmentTypeOptions.cat.min_sleep = 1;
      options.assessmentTypeOptions.cat.max_sleep = 5;
      options.assessmentTypeOptions.writing.min_sleep = 1; 
      options.assessmentTypeOptions.writing.max_sleep = 5;
      options.assessmentTypeOptions.likert.min_sleep = 1;
      options.assessmentTypeOptions.likert.max_sleep = 5;
    break;

    case "slow":
      options.userAssessmentOptions.user_results.min_sleep = 15;
      options.userAssessmentOptions.user_results.max_sleep = 30;

      options.assessmentTypeOptions.cat.min_sleep = 1;
      options.assessmentTypeOptions.cat.max_sleep =  10;
      options.assessmentTypeOptions.writing.min_sleep = 1; 
      options.assessmentTypeOptions.writing.max_sleep =  10;
      options.assessmentTypeOptions.likert.min_sleep = 1;
      options.assessmentTypeOptions.likert.max_sleep =  10;
    break;

    case "human":
      options.userAssessmentOptions.user_results.min_sleep = 20;
      options.userAssessmentOptions.user_results.max_sleep = 35;
      options.assessmentTypeOptions.cat.min_sleep = 20;
      options.assessmentTypeOptions.cat.max_sleep =  45;
      options.assessmentTypeOptions.writing.min_sleep = 5; 
      options.assessmentTypeOptions.writing.max_sleep =  15;
      options.assessmentTypeOptions.likert.min_sleep = 30;
      options.assessmentTypeOptions.likert.max_sleep =  45;
      // options.maxDuration = "1h";
      // options.duration = "1h";
      // options.iterations = 1
    break;


    case "human-human":
      options.userAssessmentOptions.user_results.min_sleep = 30;
      options.userAssessmentOptions.user_results.max_sleep = 60;
      options.assessmentTypeOptions.cat.min_sleep = 30;
      options.assessmentTypeOptions.cat.max_sleep =  120;
      options.assessmentTypeOptions.writing.min_sleep = 10; 
      options.assessmentTypeOptions.writing.max_sleep =  20;
      options.assessmentTypeOptions.likert.min_sleep = 30;
      options.assessmentTypeOptions.likert.max_sleep =  60;
    break;
  }



  let stages, vus, duration, preAllocatedVUs, timeUnit, iterations = undefined;
  switch(__ENV.LOAD_TEST_TYPE_SCENRIO){

    case "stages-constant-vus":
      // VUS=1 DURATION="2m"
      // ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-constant-vus" VUS=20 RUN_GET_PDF=true RUN_GET_ASSESSMENT_RESULTS=true DURATION="60s" INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json
      
      vus = parseInt(__ENV.VUS);
      duration = __ENV.DURATION;

      options.scenarios = {
        contacts: {
          executor: 'constant-vus',
          vus:vus,
          duration: duration,
          
        }
      } 

    break;


    case "stages-ramping-vus":
      // START_VUS=0 STAGES="30s:5,30s:10,40s:5,20s:20,30s:0" GRACEFUL_STOP="120s" GRACEFUL_RAMP_DOWN="120s" 
      // ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="slow" LOAD_TEST_TYPE_SCENRIO="stages-ramping-vus" STAGES="30s:100,1m:200,5m:500,30s:0" GRACEFUL_STOP="120s" GRACEFUL_RAMP_DOWN="120s" RUN_GET_PDF=false RUN_GET_ASSESSMENT_RESULTS=true MAX_LOGIN_SLEEP=30 INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json
      
      let start_vus = __ENV.START_VUS == undefined ? 0 :  __ENV.START_VUS;
      stages = map_stages(__ENV.STAGES);

      options.scenarios = {
        contacts: {
          executor: 'ramping-vus',
          startvus: start_vus,
          stages: stages,
        },
      } 

      //does this do anything?
      if(__ENV.GRACEFUL_STOP != undefined){
        options.scenarios.contacts.gracefulStop = __ENV.GRACEFUL_STOP;
      }

      if(__ENV.GRACEFUL_RAMP_DOWN != undefined){
        options.scenarios.contacts.gracefulRampDown = __ENV.GRACEFUL_RAMP_DOWN;
      }

    break;



    case "stages-constant-arrival-rate":
      // DURATION="1m" RATE=30 TIME_UNIT="1s" PRE_ALLOCATED_VUS=2 MAX_VUS=50
      // ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-constant-arrival-rate" DURATION="1m" RATE=30 TIME_UNIT="1s" PRE_ALLOCATED_VUS=0 MAX_VUS=50 RUN_GET_PDF=true RUN_GET_ASSESSMENT_RESULTS=true k6 run k6.assessment.loadtest.js --out json=k6.json

      duration = __ENV.DURATION;
      let rate = parseInt(__ENV.RATE);
      timeUnit = __ENV.TIME_UNIT;
      preAllocatedVUs = parseInt(__ENV.PRE_ALLOCATED_VUS);
      let maxVUs = parseInt(__ENV.MAX_VUS);

      options.scenarios = {
        contacts: {
          executor: 'constant-arrival-rate',
          // How long the test lasts
          duration: duration,

          // How many iterations per timeUnit
          rate: rate,

          // Start `rate` iterations per second
          timeUnit: timeUnit,

          // Pre-allocate 2 VUs before starting the test
          preAllocatedVUs: preAllocatedVUs,

          // Spin up a maximum of 50 VUs to sustain the defined
          // constant arrival rate.
          maxVUs: maxVUs,

        }
      } 

    break;

    case "stages-ramping-arrival-rate":
      // TIME_UNIT="1m" PRE_ALLOCATED_VUS=50 START_RATE=300 STAGES="30s:5,30s:10,40s:5,20s:20,30s:0"
      // ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-ramping-arrival-rate" STAGES="30s:5,30s:10,40s:5,20s:20,30:0" TIME_UNIT="1m" PRE_ALLOCATED_VUS=50 START_RATE=300 RUN_GET_PDF=true RUN_GET_ASSESSMENT_RESULTS=true k6 run k6.assessment.loadtest.js --out json=k6.json
      
      preAllocatedVUs = __ENV.PRE_ALLOCATED_VUS;
      timeUnit = __ENV.TIME_UNIT;
      let startRate = __ENV.START_RATE;
      stages = map_stages(__ENV.STAGES);

      options.scenarios = {
        contacts: {
          executor: 'ramping-arrival-rate',
          stages: stages,

           // Start iterations per `timeUnit`
          startRate: startRate,

          // Start `startRate` iterations per minute
          timeUnit: timeUnit,

          // Pre-allocate necessary VUs.
          preAllocatedVUs: preAllocatedVUs,

        }
      } 

    break;

    case "per-vu-iterations":
      default:


        options.scenarios =  { scenarios: {
        // single_interaction: {
          executor: 'per-vu-iterations',
          vus: parseInt(__ENV.VUS),
          iterations: 1, // Exactly 1 interaction/iteration per VU
          maxDuration: '1h',
        // },
      }
    }

      // options.vus = parseInt(__ENV.VUS);

      // options.iterations =iterations; 

      // options.maxDuration = "1h";
      // options.duration = "1h";
      // options.iterations = 1;
    break;

  }

// export function handleSummary(data) {
//   // return {
//   //   'summary.json': JSON.stringify(data), //the default data object
//   // };

//   // const med_latency = data.metrics.iteration_duration.values.med;
//   // const latency_message = `The median latency was ${data.metrics.iteration_duration.values.med}\n`;
//   // const latency_message1 = ` The http_reqs count is ${data.metrics.http_reqs.values.count}\n`;


//   const latency_message = `
//   The median latency was ${data.metrics.iteration_duration.values.med}\n
//   The http_reqs count is ${data.metrics.http_reqs.values.count}\n
//   `
//   return {
//     stdout: latency_message
//   };
// }

function map_stages(stages){

  return stages.split(",").map(e => e.split(":")).map(e => { if(e[0] == undefined || e[0].length == 0  ) { throw new Error("Invalid duration")} if(e[1] == undefined || e[0].length == 0 ) { throw new Error("Invalid target")}  return {duration: e[0], target: e[1]}})
}

export async function  setup() {
  // console.log(options)
  let [admin_username, admin_password] = options.admin_credentials.split(",")
  let admin_user = await login(admin_username, admin_password);
  options.assessment_id = options.assessment_id.split(",")

  if(options.assessment_id.length >  0){

      let promises1 = [];
      let promises2 = [];
      
      options.assessment_id.forEach(async (e) => {
        if(e.length > 0){

          //get answers
          promises1.push(get_basic_assessment_data(admin_user, e));
          promises2.push(get_answers_for_assessment(admin_user, e));

        }
      });

      let woof1 = {assessments:  await Promise.all(promises1)}
      let woof2 = {assessments:  await Promise.all(promises2)}
      for(let data of woof1.assessments){
        data.data.attributes.itemGroups = woof2.assessments.find( e => e.id == data.slug )

      }
      return {assessments:  woof1.assessments}

  }
}
  

export default async function (data) {

  let username = sharedData[__VU - 1].username
  let password = sharedData[__VU - 1].password
  const login_sleep = rando_sleep(1,  options.max_login_sleep);

  if(options.logging_status >= 1){
    log_student_data_to_console(username, `has logged in and is viewing dashboard page for ${login_sleep} seconds.`)
  }

  sleep(login_sleep);

  //login  
  let student_user = await login(username, password);
  add_length_to_trend(get_JSON_request_length(student_user));

  //Do assessments in order that was passed in command line


  //Dashboard
  let dashboard_data = await my_dashboard(student_user)
  log_user_events(student_user,  options.host + "/s", new Date() , `Dashboard`)

  switch(options.test){

    case "classroom":
      await run_classroom_program(student_user, options, dashboard_data, data)
    break;

    
    case "random":
// https://grafana.com/docs/k6/latest/examples/distribute-workloads/
// https://grafana.com/docs/k6/latest/examples/track-transmitted-data-per-url/

    break;

    case "dashboard":
    default:
      await run_dashboard_program(student_user, options, dashboard_data, data)

    break;

    
  }


  return;

}

async function run_dashboard_program(student_user, options, dashboard_data, data){

  log_user_events(student_user,  options.host + "/s", new Date() , `Dashboard`)

  total_total += student_user.total_kb;

  // //SRL has to be done first then lets randomize the order of assessments (Math, reading, writing)
  for (const ee of   options.assessment_id.split(",")) {

    await run_program(student_user, data.assessments ,  ee ) 

    if(options.run_get_assessment_results == true){
    const assessment = data.assessments.find(e => e.data.attributes.slug == ee)

      await run_user_assessment_results_program(student_user,  data.assessments.find(e => e.data.attributes.slug == ee) )
    }

    total_total += student_user.total_kb;

  }
}

async function run_classroom_program(student_user, options,  dashboard_data, data ){

    for (const cc of dashboard_data.data.attributes.classrooms) {
      const classroomSlug = cc.slug 
      const student_classroom_data = await get_student_classroom_data(student_user, classroomSlug)
      log_user_events(student_user,  options.host + `/s/classroom/${classroomSlug}`, new Date() , `Classroom - ${student_classroom_data.data.attributes.classrooms.title}`)

      //Do assessments in order that was passed in command line
      for (const gg of student_classroom_data.data.attributes.classrooms.assessments) {
        const assessmentSlug = gg.slug 
        await run_program(student_user, data.assessments, assessmentSlug, classroomSlug ) 

        if(options.run_get_assessment_results == true){ 
          await run_user_assessment_results_program(student_user, data.assessments.find(e => e.data.attributes.slug == assessmentSlug), classroomSlug )
        }

        total_total += student_user.total_kb;
          
      }
    }

}

async function get_assessment_start_data(user,assessmentId, classroomSlug){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    try{
      
      let response;

      if(classroomSlug != undefined){
        response = await http.post(renderURL("/api/classroom-assessment-start"), JSON.stringify({assessmentID: assessmentId, classroomslug: classroomSlug}), params);

      }else{
        response = await http.post(renderURL("/api/assessment-start"), JSON.stringify({assessmentID: assessmentId}), params);

      }

    check(response, {
      'status is 200': (r) => r.status === 200
    });
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);

        return resolve(res_json);

      }catch(e){
        console.log(e)
        throw new Error("SDFSDF")
      }

  });
}



async function get_student_classroom_data(user, classroomSlug){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    try{
      
    
    const response = await http.get(renderURL(`/api/student-classroom-by-id/${classroomSlug}`), params);
    // const response = await http.post(renderURL("/api/user-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);

    check(response, {
      'status is 200': (r) => r.status === 200
    });
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);

        return resolve(res_json);

      }catch(e){
        console.log(e)
        throw new Error("SDFSDF")
      }

  });
}


async function my_dashboard(user){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    try{
      
    
    const response = await http.get(renderURL("/api/my-dashboard"), params);
    // const response = await http.post(renderURL("/api/user-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);

    check(response, {
      'status is 200': (r) => r.status === 200
    });
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);

        return resolve(res_json);

      }catch(e){
        console.log(e)
        throw new Error("SDFSDF")
      }

  });
}

const range = (start, end, step = 1) => {
  return Array.from({ length: Math.ceil((end - start) / step) }, (_, i) => start + i * step);
};



async function get_real_pdf(pdf_url){
  return new Promise(async (resolve, reject) => {

    const response = await http.file(renderURL(`https:${pdf_url}`));        
    check(response, {
      'status is 200': (r) => r.status === 200
    });
                
    return resolve(true);

  });
}


async function run_user_assessment_results_program(student_user, data, classroomSlug){
  const assessmentTitle = data.data.attributes.title;
  const username = student_user.user.username;

  if(options.logging_status >= 1){
    log_student_data_to_console(username, `is getting results for ${ assessmentTitle} assessment.`)
  }

  let assessment_id = data.data.attributes.slug;

  //If we are writing then we have to check if grade is available and if not keep checking until it is... then get user assessment summary
  if(data.data.attributes.assessmentType == "WRITING_PROMPT"){

    let is_writing_graded = "WAITING_FOR_WRITING_GRADE";

    do{

      is_writing_graded = await get_student_q_status(student_user);
      log_student_data_to_console(username, `writing assessment is not graded yet. Checking in 10 seconds STATUS: ${is_writing_graded}`)
      sleep(10)

    }while(is_writing_graded == "WAITING_FOR_WRITING_GRADE" );
    
  }

  let user_assessment_summaries_data = await get_user_assessment_summaries_data(student_user, assessment_id, classroomSlug);

  log_user_events(student_user,  `${options.host}/assessments/${assessment_id}/0`, new Date() , `Assessment - ${assessment_id}`)

  let count = user_assessment_summaries_data.data.attributes.lastUserAssessmentSummary.domainScores.map((d) => {
        return d.subDomainScores
    }).reduce(function(pre, cur) {
        return pre.concat(cur);
    }, [])

    count = count.length + user_assessment_summaries_data.data.attributes.lastUserAssessmentSummary.domainScores.length;
    
    let range_ = range(1, count)
    let is_pdf_ready = false;

    //no longer need to keep getting summary data since we don't do that anymore
    for (const index of range_) {
      log_user_events(student_user,  `${options.host}/assessments/${assessment_id}/${index}`, new Date() , `Assessment - ${assessment_id}`)

      const view_results_page_sleep = rando_sleep(options.userAssessmentOptions.user_results.min_sleep, options.userAssessmentOptions.user_results.max_sleep);
      log_student_data_to_console(username, `viewing assessment results for - ${assessment_id} - Domain: ${index} - Viewing time: ${view_results_page_sleep} seconds`);
      sleep(view_results_page_sleep);

      if(options.run_get_PDF == true && is_pdf_ready === false){
      log_student_data_to_console(username, `is checking for PDF URL`);

        is_pdf_ready = await do_pdf_check(student_user, classroomSlug);

        if(is_pdf_ready === true){
          log_student_data_to_console(username, `pdf URL is: ${student_user.pdf_url}. Don't need to check anymore`);
        }else{
          log_student_data_to_console(username, `pdf URL is not ready. Will check again`);
        }
      }
    }

    //force get PDF if we never got it.
    if(options.run_get_PDF == true && is_pdf_ready === false){

      do{

        is_pdf_ready = await do_pdf_check(student_user, classroomSlug);

        if(is_pdf_ready === true){
          log_student_data_to_console(username, `pdf URL is: ${student_user.pdf_url}. Don't need to check anymore`);
        }else{
          log_student_data_to_console(username, `pdf URL is not ready. Will check again in 10 seconds`);
        }

        sleep(10);

      }while(is_pdf_ready == false)
    
    }

    if(options.logging_status >= 1){
      log_student_data_to_console(student_user.user.username, `finished viewing ${ assessmentTitle} results.`)
    }
}


async function do_pdf_check(student_user, classroomSlug){

  var is_pdf_ready = false;
  let pdf_url = "";

    //check to see if PDF is ready
    pdf_url = await get_pdf_url(student_user, classroomSlug)

    if (pdf_url.length == 0 || pdf_url == "IN_PROGRESS") {
      is_pdf_ready = false;
    }else{
      student_user.pdf_url = pdf_url
      is_pdf_ready = true;
    }

    return is_pdf_ready;

}

async function run_program(student_user, assessments, assessmentSlug, classroomSlug){

  if(assessments == undefined){
    throw new Error("COULD NOT FIND ASSESSMENT LIST!! PLEASE LOAD THEM IN COMMAND LINE")
  }

  const data = assessments.find(e => e.data.attributes.slug == assessmentSlug);

  if(data == undefined){
    throw new Error(`COULD NOT FIND ASSESSMENT!! PLEASE LOAD IT IN COMMAND LINE ${assessmentSlug}`)
  }
  
  let assessmentId = data.data.attributes.slug;
  let title = data.data.attributes.title;
  let username = student_user.user.username;

  let start_data = await get_assessment_start_data(student_user, assessmentId, classroomSlug);
  const view_start_page_sleep = rando_sleep(1, options.max_view_start_page_sleep);

  if(options.logging_status >= 1){
      log_student_data_to_console(username, `is viewing ${title} start page for: ${view_start_page_sleep} seconds`) 
  }

     if(classroomSlug != undefined){
      log_user_events(student_user,  `${options.host}/s/classroom/${classroomSlug}/assessments/${assessmentId}/start`, new Date() , `Assessment - ${title}`)

    }else{
      log_user_events(student_user,  `${options.host}/s/assessments/${assessmentId}/start`, new Date() , `Assessment - ${assessmentId}`)

    }
  sleep(view_start_page_sleep);

  //create assessment  
  let create_assessment_data = await create_assessment(student_user, assessmentId, classroomSlug);
  if(options.logging_status >= 1){
      log_student_data_to_console(username, `created ${title} user assessment.`) 
  }

  //get users assessment in progroess
  let users_assessment_in_progress = await get_users_assessment_in_progress(student_user, assessmentId, classroomSlug);
  const userAssessment = users_assessment_in_progress.included.find( e => e.type == "userAssessment");
  let userAssessmentId = userAssessment.attributes._id;
  let question = await get_users_assessment_question(student_user, assessmentId, classroomSlug);
  let assessmentType = data.data.attributes.assessmentType;
  
  let count = 0;
  var isAssessmentDone = undefined;

      if(classroomSlug != undefined){
  log_user_events(student_user,  `${options.host}/s/classroom/${classroomSlug}/assessments/${assessmentId}/take`, new Date() , `Assessment - ${title}`)

    }else{
  log_user_events(student_user,  `${options.host}/assessments/${assessmentId}/take`, new Date() , `Assessment - ${title}`)

    }


    if(options.logging_status >= 1){
      log_student_data_to_console(username, `is on ${title} take page, and taking assessment.`) 
    }
  
  do{

      let questionId = question.data.attributes.questions._id;
      let answer_response = {};

      let sl = 0;

      switch(assessmentType){

          case "WRITING_PROMPT":
          
            let writing_sample = get_whole_writing_sample()
            let i = 0;
            let start = 0;
            let end = 0;
            let output = "";
            let writing_for_user = [];

            //todo change to - do while
            while(i < writing_sample.length ){
              let yo = range(i, i + 120, 1)

              output = yo.map(x=>writing_sample[x]).join("");

              writing_for_user.push({"id":makeid_no_special_characteres(10),"type":"paragraph","data":{"text":output}})
                answer_response = {
                  assessmentId: assessmentId,
                  userAssessmentId: userAssessmentId,
                  answers: writing_for_user,
                  classroomslug: classroomSlug
                }

              
              question = await send_users_writing_answers_for_assessment_question(student_user, assessmentId, answer_response, classroomslug);


              sl = rando_sleep(options.assessmentTypeOptions.writing.min_sleep, options.assessmentTypeOptions.writing.max_sleep);

              if(options.logging_status >= 2){
                log_student_data_to_console(username, `is thinking about what to write for ${sl} seconds.`) 
              }
              sleep(sl);
              i += 120;


            }
            
            question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response,);
            isAssessmentDone = question.data.attributes.isAssessmentDone;
        
          break;

          case "LIKERT":
              let answers = get_answers_by_assessment_type(assessmentType, question.data.attributes, options.assessmentTypeOptions.likert.answerType);
                answer_response = {
                  assessmentId: assessmentId,
                  userAssessmentId: userAssessmentId,
                  questionId:questionId, 
                  answers: answers,
                  classroomslug: classroomSlug
              }

                question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
                isAssessmentDone = question.data.attributes.isAssessmentDone;
                if(!isAssessmentDone){
                  sl = rando_sleep(options.assessmentTypeOptions.likert.min_sleep, options.assessmentTypeOptions.likert.max_sleep);

                  if(options.logging_status >= 2){
                    log_student_data_to_console(username, `is thinking for ${sl} seconds about the answer for question.`) 
                  }
                sleep(sl);

                } 
          break;

          case "CAT":

            let answerGroup = data.data.attributes.itemGroups.data.attributes.itemGroups.find(d => d._id === questionId);
          
              answer_response = {
                  assessmentId: assessmentId,
                  userAssessmentId: userAssessmentId,
                  questionId:questionId, 
                  answers: [],
                  classroomslug: classroomSlug,
              }
            
              let count = question.data.attributes.questions.items.length - 1;
              let index = 0;
              for(const q of question.data.attributes.questions.items){
                  
                  let answersForQuestion = answerGroup.items.find(d=> d._id ==  q._id);

                  let answer = get_answers_by_assessment_type(assessmentType, q, options.assessmentTypeOptions.cat.answerType, answersForQuestion);
                
                  let indiviual_answer = {
                      assessmentId: assessmentId,
                      userAssessmentId: userAssessmentId,
                      questionId:questionId, 
                      classroomSlug: classroomSlug,
                      answer: []
                  }
                  indiviual_answer.answer.push(answer[0])
      
                  answer_response.answers.push(answer[0]);
              
                  if(count != index ){
                    
                      await send_users_individual_answer_for_assessment_question(student_user, assessmentId, indiviual_answer);
                      sl = rando_sleep( options.assessmentTypeOptions.cat.min_sleep,  options.assessmentTypeOptions.cat.max_sleep);

                      if(options.logging_status >= 2){
                        log_student_data_to_console(username, `is thinking for ${sl} seconds about the answer for question.`) 
                      }
                      sleep(sl);

                  } 

                  index++;
              }
              question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response, classroomSlug);
              isAssessmentDone = question.data.attributes.isAssessmentDone;
  
          break;
          
      }
      
  }while(isAssessmentDone === false)

    if(options.logging_status >= 1){
      log_student_data_to_console(username, `is ending ${ title} assessment.`) 
    }

  return
}
function log_student_data_to_console(username, sentence){
      console.log(`${username} ${sentence}`)    

}
async function login(username, password){
  return new Promise(async (resolve, reject) => {
    const params = {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    };
  try{
    const response = await http.post(renderURL("/token"), {
      username: username,
      grant_type: "password",
      password: password,
      client_id: "application"
    } , params);
        
  check(response, {
    'status is 200': (r) => r.status === 200
  });

      const res_json = await response.json();     
      const total_kb = get_JSON_request_length(res_json);     
      res_json.total_kb = parseInt(total_kb); 
    return resolve(res_json);
  }catch(e){
      console.log(e)
  }

});
}

async function get_basic_assessment_data(user, assessmentId){
  return new Promise(async (resolve, reject) => {

  const params = {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer '+ user.accessToken
    },
  };
  
    const response = await http.get(renderURL(`/api/get-assessment-by-id/${assessmentId}`),params);
    
  check(response, {
    'status is 200': (r) => r.status === 200
  });


    const res_json = await response.json();        
    return resolve(res_json);

  });
}

async function get_answers_for_assessment(user, assessmentId){
  return new Promise(async (resolve, reject) => {

  const params = {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer '+ user.accessToken
    },
  };
  
  const response = await http.post(renderURL("/api/assessment"), {
    id: assessmentId,
    field: "questions"
  } , params);
    
  check(response, {
    'status is 200': (r) => r.status === 200
  });


    const res_json = await response.json();        
    return resolve(res_json);

  });
}


async function get_pdf_url(user, classroomSlug){

  return new Promise(async (resolve, reject) => {
          
      const params = {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer '+ user.accessToken
        },
      };

      let response;

      if(classroomSlug != undefined){
        response = await http.get(renderURL(`/api/get-student-pdf-report-url/${classroomSlug}`), params);

      }else{
        response = await http.get(renderURL("/api/get-student-pdf-report-url"), params);

      }
      

      // const response = await http.get(renderURL("/api/get-student-pdf-report-url"), params);        
      check(response, {
        'status is 200': (r) => r.status === 200
      });
    
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

      user.total_kb += get_JSON_request_length(res_json);      
      return resolve(res_json);


  });

}



async function run_get_pdf(user){

  return new Promise(async (resolve, reject) => {
          
      const params = {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer '+ user.accessToken
        },
      };

      const response = await http.get(renderURL("/api/download-assessment-report") , params);
        
      check(response, {
        'status is 200': (r) => r.status === 200
      });
    
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

      user.total_kb += get_JSON_request_length(res_json);      
      return resolve(res_json);


  });

}

async function log_user_events(user, url, time, title){
  return new Promise(async (resolve, reject) => {

      if(options.logging_status >= 3){
        log_student_data_to_console(user.user.username, `is logging page view for ${title}.`)
      }

      const params = {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer '+ user.accessToken
        },
      };

      const response = await http.post(renderURL("/api/user-events"), {"log_type":"PAGE_VIEW","url":url,  "title":title, "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36", "timestamp": time} , params);
        

      // {"log_type":"PAGE_VIEW","title":"Assessment - Reading","url":"https://loadtest2.moomoodev.com/assessments/795c8469-9bdd-439a-9251-34457bd04adc/take","userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36","timestamp":"2025-05-28T15:06:20.156Z"}

      check(response, {
        'status is 200': (r) => r.status === 200
      });
    
    
        const res_json = await response.json();      
        add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
    
  });
}

async function create_assessment(user, assessmentId, classroomSlug){
  return new Promise(async (resolve, reject) => {

      const params = {
        headers: {
        'Content-Type': 'application/json',
          
          'Authorization': 'Bearer '+ user.accessToken
        },
      };

            let response;
   
      if(classroomSlug != undefined){
     
        response = await http.put(renderURL("/api/classroom-student-assessment"), JSON.stringify({assessmentId: assessmentId, classroomslug: classroomSlug}), params);

      }else{
        response = await http.put(renderURL("/api/student-assessment"), JSON.stringify({assessmentId: assessmentId}), params);

      }

        
      check(response, {
        'status is 200': (r) => r.status === 200
      });
    
    
        const res_json = await response.json();      
        add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
    
  });
}

async function get_users_assessment_in_progress(user, assessmentId, classroomSlug){
  return new Promise(async (resolve, reject) => {
    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

       let response;

      if(classroomSlug != undefined){
        // response = await http.get(renderURL(`/api/s/classroom/${classroomSlug}/assessment/${assessmentId}/start`), params);
        response = await http.post(renderURL("/api/classroom-student-assessment"), JSON.stringify({assessmentID: assessmentId, classroomslug: classroomSlug}), params);

      }else{
        response = await http.post(renderURL("/api/student-assessment"), JSON.stringify({assessmentID: assessmentId}), params);

      }
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });

    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}

async function get_users_assessment_question(user, assessmentId, classroomSlug){
  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
          'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.post(renderURL("/api/student-assessment-question-group"), JSON.stringify({
      assessmentId: assessmentId,
      classroomslug: classroomSlug,
    }) , params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });
    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);

  });
}

async function get_student_q_status(user){

  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.get(renderURL("/api/get-student-q-status"), params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });
    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}


async function send_users_writing_answers_for_assessment_question(user, assessmentId, answers){

  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.put(renderURL("/api/save-writing-sample"), 
    // const response = await http.put(renderURL("/api/user-assessment-save-writing-sample"), 
      JSON.stringify(answers)
      , params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });
    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}


async function send_users_answers_for_assessment_question(user, assessmentId, answers, classroomSlug){

  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.put(renderURL("/api/student-assessment-question-answer"), 
    // const response = await http.put(renderURL("/api/user-assessment-question-answer"), 
      JSON.stringify(answers),  params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });
    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}

async function get_user_assessment_summaries_data(user, assessmentId, classroomSlug){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    try{
      
        let response;

      if(classroomSlug != undefined){
        // response = await http.get(renderURL(`/api/s/classroom/${classroomSlug}/assessment/${assessmentId}/start`), params);
        response = await http.post(renderURL("/api/classroom-student-assessment-summaries"), JSON.stringify({assessmentID: assessmentId, classroomslug: classroomSlug}), params);

      }else{
        response = await http.post(renderURL("/api/student-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);

      }
      

    // const response = await http.post(renderURL("/api/student-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);
    // const response = await http.post(renderURL("/api/user-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);

    check(response, {
      'status is 200': (r) => r.status === 200
    });
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);

        return resolve(res_json);

      }catch(e){
        console.log(e)
        throw new Error("SDFSDF")
      }

  });
}
function add_length_to_trend(l){
  myTrend.add(l);
}

function get_JSON_request_length(data){
  return JSON.stringify(data).length;
}

async function send_users_individual_answer_for_assessment_question(user, assessmentId, answers){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    
    const response = await http.put(renderURL("/api/student-assessment-answer"), JSON.stringify(answers), params);
    // const response = await http.put(renderURL("/api/user-assessment-answer"), JSON.stringify(answers), params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });
  
    const res_json = await response.json();      
    add_length_to_trend(get_JSON_request_length(res_json));

    user.total_kb += get_JSON_request_length(res_json);      
    return resolve(res_json);
    
  });
}


async function get_avg_for_assessment(user, assessmentId,){
  return new Promise(async (resolve, reject) => {
    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    
    const response = await http.post(renderURL("/api/get_user_assessment_answer_avg"), JSON.stringify({id: assessmentId}), params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });

      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}


function renderURL(path){
  return options.host + path;
}
  
function get_answers_by_assessment_type(type, data, answerType, answers){
  let return_data = [];
  let currentDate = undefined;
  switch(type){

    case "LIKERT":

    data.questions.items.forEach((d) => {

            let possibleItemAnswers = d.possibleItemAnswers;
            let answerID = getAnswerChoice(possibleItemAnswers, "RANDOM");
            currentDate = new Date();

            let obj = {
                domainId: d.domainId,
                startDate:currentDate,
                completeDate: currentDate,
                chosenItemAnswerId: answerID,
                questionId: d._id
            }
            return_data.push(obj);
        })

    break;

    case "CAT":

            let possibleItemAnswers = data.possibleItemAnswers;
            let answerID = getAnswerChoice(possibleItemAnswers, answerType, answers);
            currentDate = new Date();

        let obj = {
            domainId: data.domainId,
            startDate:currentDate,
            completeDate: currentDate,
            chosenItemAnswerId: answerID,
            questionId: data._id
        }
        return_data.push(obj);
    break;
  }

  return return_data;

}

function getAnswerChoice(possibleItemAnswers, answerType, answers){
  let answerID = "";
  switch(answerType){
      case "100%":
          answerID = possibleItemAnswers[answers.possibleItemAnswers.findIndex(d => d.score === 1)]._id;
      break;
      case "RANDOM":
      default:
          answerID = possibleItemAnswers[getRandomInt(possibleItemAnswers.length)]._id;
      break;

  }
  return answerID;
}

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

function get_whole_writing_sample(){
  return `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec justo nibh, viverra nec volutpat vitae, finibus ac mauris. Nulla posuere justo est, nec tristique elit pretium ac. Curabitur at odio id diam fringilla viverra. Sed cursus dolor sed pretium semper. Cras tempus condimentum massa eget vehicula. Donec sapien metus, eleifend sit amet ipsum eu, volutpat porttitor ipsum. Maecenas sed lacus lacinia, vestibulum justo et, consequat ex.

  Pellentesque dolor lectus, euismod vitae hendrerit in, mollis eget ex. Maecenas viverra lacinia varius. Sed molestie sit amet neque at dictum. Maecenas posuere risus dolor, sit amet finibus augue pulvinar eget. Nullam imperdiet velit elementum neque finibus, non elementum massa luctus. Maecenas fringilla sem sed est pellentesque semper. Donec vitae volutpat justo. Suspendisse sollicitudin mauris sit amet venenatis posuere. Integer venenatis auctor enim, vitae suscipit velit. Vivamus cursus, nibh nec sodales porttitor, nisi nisi dignissim ligula, et interdum neque lacus at lorem. Cras malesuada lectus at dui suscipit sollicitudin. Sed rutrum egestas vestibulum. Quisque lectus lacus, tincidunt in scelerisque ac, imperdiet non dui. Proin varius nibh malesuada ante molestie, eu porttitor mi ultricies. Curabitur facilisis libero neque, vitae imperdiet enim fringilla at. Ut finibus risus quis erat molestie, pulvinar ornare nisi placerat.

  Ut a lacus arcu. Sed at sem purus. Praesent eu quam turpis. Cras sollicitudin augue eget feugiat semper. Nullam orci neque, rhoncus id velit id, commodo facilisis dui. Praesent neque massa, semper nec nunc eget, facilisis blandit nisl. Aenean vitae suscipit diam. Suspendisse mauris tellus, congue vitae ultrices id, porta a massa. Maecenas tincidunt tortor sed facilisis sodales. Nullam iaculis maximus pretium. Curabitur cursus volutpat ante, id cursus felis sollicitudin a. Integer est arcu, pulvinar non fringilla suscipit, luctus eget metus.

  Ut luctus vehicula diam, eget tincidunt massa ultrices in. Pellentesque mollis pretium rutrum. Etiam massa dui, pharetra sit amet est ac, tempor euismod libero. Maecenas auctor nunc mauris, vel maximus dui tristique sit amet. Nunc sed interdum dolor. Vestibulum facilisis tincidunt dapibus. Integer vitae risus pretium, semper arcu et, efficitur ante. Integer rutrum volutpat elit non vehicula. Fusce ac auctor metus. Nam ac auctor felis. Cras bibendum in tortor id egestas. Nam.`;
}

function rando_sleep(min, max){
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}


function makeid_no_special_characteres(length) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
      counter += 1;
    }
    return result;
  }