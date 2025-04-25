// k6 run k6.assessment.loadtest.js 
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


 *  */ 

import { check, sleep } from 'k6';
import http from 'k6/http';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

import { Gauge, Counter, Rate } from 'k6/metrics';

export let options = {
  assessment_id: __ENV.ASSESSMENT_ID,
  logging_status: __ENV.LOGGING_STATUS == undefined ? 0 : parseInt(__ENV.LOGGING_STATUS),
  host: __ENV.HOST,
  student_file: __ENV.STUDENT_FILE,
  admin_credentials: __ENV.ADMIN_CREDENTIALS,
  insecureSkipTLSVerify: true,
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
  // stages: [
  //   { duration: '30s', target: 100 }, // traffic ramp-up from 1 to a higher 200 users over 10 minutes.
  //   { duration: '30s', target: 200 }, // stay at higher 200 users for 30 minutes
  //   { duration: '40s', target: 400 }, // stay at higher 200 users for 30 minutes
  //   { duration: '20s', target: 500 }, // ramp-down to 0 users
  //   { duration: '5m', target: 0 }, // ramp-down to 0 users
  // ],
  gracefulRampDown: "5m",
  // vus: 300,
  // iterations: 300,
  vus: 1,
  iterations: 1,
  // duration: '30s'
  tot: 0
};
let total_total = 0;

  let sharedData = new SharedArray("Shared Logins", function () {
    let data = papaparse.parse(open(`data/input/${options.student_file}`), { header: true }).data;

    data.map( e => {
      e.used = false;
    })
    return data;
  });



// function getSlice(data, n) {
//   let partSize = Math.floor(data.length / n);
//   return data.slice(rando_sleep(0, users.length), 1);
// }

const woof = open(`data/input/${options.student_file}`);
let users = [];

  export async function  setup() {


    users = papaparse.parse(woof, { header: true }).data;



    let [admin_username, admin_password] = options.admin_credentials.split(",")
    let admin_user = await login(admin_username, admin_password);
    options.assessment_id = options.assessment_id.split(",")

    if(options.assessment_id.length >  0){
 
        let promises1 = [];
        let promises2 = [];
        
        options.assessment_id.forEach(async (e) => {
          if(e.length > 0){

            //get answers
            promises1.push(get_answers_for_assessment(admin_user, e));
            // //get answer avgs
            // promises2.push(get_avg_for_assessment(admin_user, e));

          }
        });
        return {assessments: await Promise.all(promises1), users:users}

    }
  }
  
  function getSlice(data, n) {
    let partSize = Math.floor(data.length / n);
    return data.slice(partSize*__VU, partSize*__VU+partSize);
}
// const myTrend = new Gauge('total_byes');
const myTrend = new Counter('total_byes');

  export default async function (data) {

    // sleep(5);

    // console.log(__VU, __ITER);

  //   console.log(`
  
  // All info except abort.
  
  
  // // Other variables
  
  // Instance info
  // -------------
  // Vus active: ${exec.instance.vusActive}
  // Iterations completed: ${exec.instance.iterationsCompleted}
  // Iterations interrupted:  ${exec.instance.iterationsInterrupted}
  // Iterations completed:  ${exec.instance.iterationsCompleted}
  // Iterations active:  ${exec.instance.vusActive}
  // Initialized vus:  ${exec.instance.vusInitialized}
  // Time passed from start of run(ms):  ${exec.instance.currentTestRunDuration}
  
  // Scenario info
  // -------------
  // Name of the running scenario: ${exec.scenario.name}
  // Executor type: ${exec.scenario.executor}
  // Scenario start timestamp: ${exec.scenario.startTime}
  // Percenatage complete: ${exec.scenario.progress}
  // Iteration in instance: ${exec.scenario.iterationInInstance}
  // Iteration in test: ${exec.scenario.iterationInTest}
  
  // Test info
  // ---------
  // All test options: ${exec.test.options}
  
  // vu info
  // -------
  // Iteration id: ${exec.vu.iterationInInstance}
  // Iteration in scenario: ${exec.vu.iterationInScenario}
  // VU ID in instance: ${exec.vu.idInInstance}
  // VU ID in test: ${exec.vu.idInTest}
  // VU tags: ${exec.vu.tags}
  
  
  // `);

    
    // let slice = getSlice(data.users, 500);


      // Pick a random username/password pair
      // const randomUser = data(rando_sleep(0, sharedData.length))
  // const randomUser = sharedData[Math.floor(Math.random() * sharedData.length)];

  // console.log('Random user: ', JSON.stringify(randomUser));
    // let username = randomUser.username;
    // let password = randomUser.password;
        
  // if(options.logging_status >= 1){
  //   console.log(`${randomUser.username} is sleeping for ${login_sleep}`)
  // }
  // sleep(login_sleep);
  // console.log(`users.length: ${data.users.length}` )

  //   const myNum = rando_sleep(0, data.users.length);
  //   console.log(`myNum: ${myNum} users.length: ${data.users.length}` )
    
  //   const username = data.users[myNum].username;

  //   data.users = data.users.slice(myNum, 1);
  //   console.log(`$data:${data.users.length}`)
    let username = sharedData[__VU - 1].username
    let password = sharedData[__VU - 1].password
    
    const login_sleep = rando_sleep(1, 15);
    
    if(options.logging_status >= 1){
      console.log(`${username} is sleeping for ${login_sleep}`)
    }
    sleep(login_sleep);
    //login  
    let student_user = await login(username, password);

    student_user.user_assessment_total_kb_total = 0;
 
    add_length_to_trend(get_JSON_request_length(student_user));

    // return;
    for (const ee of data.assessments) {
      if(options.logging_status >= 1){
        console.log(`starting test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
      }
      await run_program(student_user, ee) 
      if(options.logging_status >= 1){
        console.log(`ending test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
      }
      await run_user_assessment_results_program(student_user, ee)
      if(options.logging_status >= 1){
        console.log(`got results for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
      }
      total_total += student_user.total_kb;

    }
      //add downloading a PDF
      // await run_get_pdf(student_user)
      
    if(options.logging_status >= 1){
      console.log(`test done for: ${username}`)
      console.log(`test done for: ${username}`)
      console.log(`Total Bytes: ${total_total} `)
      console.log(`Total KB: ${total_total / 1000} `)
      console.log(`Total MB: ${total_total / 1000000} `)
      console.log(`Total GB: ${total_total / 1000000000} `)
    }

    return;
  
  }

  const range = (start, end, step = 1) => {
    return Array.from({ length: Math.ceil((end - start) / step) }, (_, i) => start + i * step);
  };

  async function run_get_pdf(student_user){

    return new Promise(async (resolve, reject) => {
            
       let response = await http.get(renderURL("/pdf_assessments/b8NPTg8ZNQugVNJVZlsx.pdf"));
        
      check(response, {
        'status is 200': (r) => r.status === 200
      });
      
      
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
        sleep(rando_sleep(1, 3));
      }

      // student_user.user_assessment_total_kb_total += count * JSON.stringify(user_assessment_summaries_data).length; 
      // student_user.total_kb +=student_user.user_assessment_total_kb_total
  }

  async function run_program(student_user, data, avg){
    
    let assessmentId = data.data.attributes.assessmentId;

    // //create assessment  
    let users_assessment = await create_assessment(student_user, assessmentId);

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
          // 'accessToken': (r) => r.json().accessToken ,
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
          user.user_assessment_total_kb = get_JSON_request_length(res_json);

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
