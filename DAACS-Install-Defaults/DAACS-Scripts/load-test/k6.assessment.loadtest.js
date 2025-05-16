// https://grafana.com/docs/k6/latest/using-k6/k6-options/reference/#summary-mode



// https://grafana.com/docs/k6/latest/results-output/end-of-test/custom-summary/
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

import { check, sleep } from 'k6';
import http from 'k6/http';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

import { Gauge, Counter, Rate } from 'k6/metrics';

const myTrend = new Counter('total_byes');

export let options = {
  assessment_id: __ENV.ASSESSMENT_ID,
  max_login_sleep: __ENV.MAX_LOGIN_SLEEP == undefined ? 15 : __ENV.MAX_LOGIN_SLEEP,
  logging_status: __ENV.LOGGING_STATUS == undefined ? 0 : parseInt(__ENV.LOGGING_STATUS),
  host: __ENV.HOST,
  student_file: __ENV.STUDENT_FILE,
  admin_credentials: __ENV.ADMIN_CREDENTIALS,
  run_get_PDF: __ENV.RUN_GET_PDF == "true" ? true : false,
  run_get_assessment_results: __ENV.RUN_GET_ASSESSMENT_RESULTS == "true" ? true : false,
  
  insecureSkipTLSVerify:  __ENV.INSECURE_SKIP_TLS == "true" ? true : false,
  // httpDebug: 'full',
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<300'], // 95% of requests should be below 500ms
    
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
    let data = papaparse.parse(open(`data/input/${options.student_file}`), { header: true }).data;

    data.map( e => {
      e.used = false;
    })
    return data;
  });



  switch(__ENV.LOAD_TEST_TYPE_SPEED){

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
      options.userAssessmentOptions.user_results.min_sleep = 1;
      options.userAssessmentOptions.user_results.max_sleep = 10;

      options.assessmentTypeOptions.cat.min_sleep = 1;
      options.assessmentTypeOptions.cat.max_sleep =  10;
      options.assessmentTypeOptions.writing.min_sleep = 1; 
      options.assessmentTypeOptions.writing.max_sleep =  10;
      options.assessmentTypeOptions.likert.min_sleep = 1;
      options.assessmentTypeOptions.likert.max_sleep =  10;
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
      // ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="slow" LOAD_TEST_TYPE_SCENRIO="stages-ramping-vus" STAGES="30s:100,30s:200,30s:500,30s:1000,30s:0" GRACEFUL_STOP="120s" GRACEFUL_RAMP_DOWN="120s" RUN_GET_PDF=false RUN_GET_ASSESSMENT_RESULTS=true MAX_LOGIN_SLEEP=30 INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json
      
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

    
    case "vus":

      options.vus = vus;
      options.iterations =iterations; 

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
  let [admin_username, admin_password] = options.admin_credentials.split(",")
  let admin_user = await login(admin_username, admin_password);
  options.assessment_id = options.assessment_id.split(",")

  if(options.assessment_id.length >  0){

      let promises1 = [];
      
      options.assessment_id.forEach(async (e) => {
        if(e.length > 0){

          //get answers
          promises1.push(get_answers_for_assessment(admin_user, e));

        }
      });
      return {assessments: await Promise.all(promises1)}

  }
}
  

export default async function (data) {

  let username = sharedData[__VU - 1].username
  let password = sharedData[__VU - 1].password
  
  const login_sleep = rando_sleep(1,  options.max_login_sleep);
  if(options.logging_status >= 1){
    console.log(`${username} is sleeping for ${login_sleep}`)
  }

  sleep(login_sleep);

  //login  
  let student_user = await login(username, password);
  add_length_to_trend(get_JSON_request_length(student_user));

  for (const ee of data.assessments) {
    // if(options.logging_status >= 1){
    //   console.log(`starting test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
    // }
    // await run_program(student_user, ee) 
    // if(options.logging_status >= 1){
    //   console.log(`ending test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
    // }

    // if(options.run_get_assessment_results == true){

    //   await run_user_assessment_results_program(student_user, ee)
    //   if(options.logging_status >= 1){
    //     console.log(`got results for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
    //   }
    // }

    // total_total += student_user.total_kb;

  }

    //add downloading a PDF
    if(options.run_get_PDF == true){
      await run_get_pdf(student_user)
    }

  return;

}

const range = (start, end, step = 1) => {
  return Array.from({ length: Math.ceil((end - start) / step) }, (_, i) => start + i * step);
};


//todo - make dynamic. Make it do a PDF request... then check back every 5 seconds, then download
async function run_get_pdf(student_user){

  return new Promise(async (resolve, reject) => {
          
    let response = await http.get(renderURL("/pdf_assessments/b8NPTg8ZNQugVNJVZlsx.pdf"));
      
    check(response, {
      'status is 200': (r) => r.status === 200
    }); 

    student_user.total_kb += response.body.length;
    add_length_to_trend(response.body.length);

  });

}

async function run_user_assessment_results_program(student_user, data){

  let user_assessment_summaries_data = await get_user_assessment_summaries_data(student_user, data.data.attributes.assessmentId);
  let count = user_assessment_summaries_data.data.attributes.lastUserAssessmentSummary.domainScores.map((d) => {
        return d.subDomainScores
    }).reduce(function(pre, cur) {
        return pre.concat(cur);
    }, [])

    count = count.length + user_assessment_summaries_data.data.attributes.lastUserAssessmentSummary.domainScores.length;
    
    let range_ = range(1, count)
    for (const index of range_) {
      await get_user_assessment_summaries_data(student_user, data.data.attributes.assessmentId);
      sleep(rando_sleep(options.userAssessmentOptions.user_results.min_sleep, options.userAssessmentOptions.user_results.max_sleep));
    }
}

async function run_program(student_user, data, avg){
  
  let assessmentId = data.data.attributes.assessmentId;

  // //create assessment  
  await create_assessment(student_user, assessmentId);

  // //get users assessment in progroess
  let users_assessment_in_progress = await get_users_assessment_in_progress(student_user, assessmentId);
  let userAssessmentId =users_assessment_in_progress.data.attributes.assessment._id;
  let question = await get_users_assessment_question(student_user, assessmentId);
  let assessmentType = users_assessment_in_progress.data.attributes.assessmentType;
  
  let count = 0;
  var isAssessmentDone = undefined;
  do{

      let questionId = question.data.attributes.questions._id;
      let answer_response = {};

      switch(assessmentType){

          case "WRITING_PROMPT":
            let length = get_whole_writing_sample().length
            let i = 0;
            let output = "";

            while(i < length ){
              i += 120;
            
              output = [...Array(i).keys()].map(x=>get_whole_writing_sample()[x]).join("")


            answer_response = {
              assessmentId: assessmentId,
              userAssessmentId: userAssessmentId,
              answers: output
            }
            question = await send_users_writing_answers_for_assessment_question(student_user, assessmentId, answer_response);
              sleep(rando_sleep(options.assessmentTypeOptions.writing.min_sleep, options.assessmentTypeOptions.writing.max_sleep));
            }
            
            question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
            isAssessmentDone = question.data.attributes.isAssessmentDone;
          

          break;

          case "LIKERT":
              let answers = get_answers_by_assessment_type(assessmentType, question.data.attributes, options.assessmentTypeOptions.likert.answerType);
                answer_response = {
                  assessmentId: assessmentId,
                  userAssessmentId: userAssessmentId,
                  questionId:questionId, 
                  answers: answers
              }

                question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
                isAssessmentDone = question.data.attributes.isAssessmentDone;
                if(!isAssessmentDone){
                
                sleep(rando_sleep(options.assessmentTypeOptions.likert.min_sleep, options.assessmentTypeOptions.likert.max_sleep));

                } 
          break;

          case "CAT":
            let answerGroup = data.data.attributes.questions.find(d => d._id === questionId);
          
              answer_response = {
                  assessmentId: assessmentId,
                  userAssessmentId: userAssessmentId,
                  questionId:questionId, 
                  answers: []
              }
              let count = question.data.attributes.questions.items.length - 1;

              question.data.attributes.questions.items.forEach(async (q,i) =>{
                  
                  let answersForQuestion = answerGroup.items.find(d=> d._id ==  q._id);

                  let answer = get_answers_by_assessment_type(assessmentType, q, options.assessmentTypeOptions.cat.answerType, answersForQuestion);
                
                  let indiviual_answer = {
                      assessmentId: assessmentId,
                      userAssessmentId: userAssessmentId,
                      questionId:questionId, 
                      answer: []
                  }
                  indiviual_answer.answer.push(answer[0])
      
                  answer_response.answers.push(answer[0]);
              
                  if(count != i ){
                    
                      await send_users_individual_answer_for_assessment_question(student_user, assessmentId, indiviual_answer);
                      sleep(rando_sleep( options.assessmentTypeOptions.cat.min_sleep,  options.assessmentTypeOptions.cat.max_sleep));

                  } 
              });
              question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
              isAssessmentDone = question.data.attributes.isAssessmentDone;
  
          break;
          
      }
      
  }while(isAssessmentDone === false)
  return
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
    field: "itemGroups"
  } , params);
    
  check(response, {
    'status is 200': (r) => r.status === 200
  });


    const res_json = await response.json();        
    return resolve(res_json);

  });
}

async function create_assessment(user, assessmentId){
  return new Promise(async (resolve, reject) => {

      const params = {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer '+ user.accessToken
        },
      };

      const response = await http.post(renderURL("/api/user-assessment"), {
          assessmentId: assessmentId,
      } , params);
        
      check(response, {
        'status is 200': (r) => r.status === 200
      });
    
    
        const res_json = await response.json();      
        add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
    
  });
}

async function get_users_assessment_in_progress(user, assessmentCategoryId){
  return new Promise(async (resolve, reject) => {
    const params = {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.post(renderURL("/api/user-assessment-summary"), {
      assessmentID: assessmentCategoryId,
    } , params);
      
    check(response, {
      'status is 200': (r) => r.status === 200
    });

    
  
      const res_json = await response.json();      
      add_length_to_trend(get_JSON_request_length(res_json));

        user.total_kb += get_JSON_request_length(res_json);      
        return resolve(res_json);
  });
}

async function get_users_assessment_question(user, assessmentId){
  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.post(renderURL("/api/user-assessment-question-group"), {
      assessmentId: assessmentId,
    } , params);
      
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

    const response = await http.put(renderURL("/api/user-assessment-save-writing-sample"), 
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


async function send_users_answers_for_assessment_question(user, assessmentId, answers){

  return new Promise(async (resolve, reject) => {

    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };

    const response = await http.put(renderURL("/api/user-assessment-question-answer"), 
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

async function get_user_assessment_summaries_data(user, assessmentId){
  return new Promise(async (resolve, reject) => {


    const params = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer '+ user.accessToken
      },
    };
    try{
      
    
    const response = await http.post(renderURL("/api/user-assessment-summaries"), JSON.stringify({assessmentID: assessmentId}), params);

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
    
    const response = await http.put(renderURL("/api/user-assessment-answer"), JSON.stringify(answers), params);
      
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
