// k6 run k6.assessment.loadtest.js 
/**
  k6 run k6.assessment.loadtest.js --env ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"

  k6 run k6.assessment.loadtest.js --env ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365"
  
  ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f" k6 run k6.assessment.loadtest.js 
 
  k6 run k6.assessment.loadtest.js --env ASSESSMENT_ID="e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"
k6 run k6.assessment.loadtest.js --env ASSESSMENT_ID="79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365,795c8469-9bdd-439a-9251-34457bd04adc,46997151-21a3-4eef-b657-e7dcdd913481,e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"
ADMIN_CREDENTIALS="admin,password" HOST="https://daacs.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f,46997151-21a3-4eef-b657-e7dcdd913481" k6 run k6.assessment.loadtest.js

 *  */ 

import { check, sleep } from 'k6';
import http from 'k6/http';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';


export let options = {
  assessment_id: __ENV.ASSESSMENT_ID,
  host: __ENV.HOST,
  student_file: __ENV.STUDENT_FILE,
  admin_credentials: __ENV.ADMIN_CREDENTIALS,
  insecureSkipTLSVerify: true,
  // httpDebug: 'full',
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    
  },
  // stages: [
  //   { duration: '2m', target: 20 }, // traffic ramp-up from 1 to a higher 200 users over 10 minutes.
  //   { duration: '3m', target: 35 }, // stay at higher 200 users for 30 minutes
  //   { duration: '2m', target: 50 }, // stay at higher 200 users for 30 minutes
  //   { duration: '1m', target: 0 }, // ramp-down to 0 users
  // ],
  vus: 2,
  iterations: 2,
  // duration: '30s'
};

  const sharedData = new SharedArray("Shared Logins", function () {
    let data = papaparse.parse(open(`data/input/${options.student_file}`), { header: true }).data;
    return data;
  });

  export async function  setup() {

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
            promises2.push(get_avg_for_assessment(admin_user, e));

          }
        });
        return {assessments: await Promise.all(promises1), avg: await Promise.all(promises2)}

    }
  }
  
  export default async function (data) {

    let username = sharedData[exec.vu.idInTest - 1].username
    let password = sharedData[exec.vu.idInTest - 1].password
    
    //login  
    let student_user = await login(username, password);
 
    for (const ee of data.assessments) {
      console.log(`starting test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
       await run_program(student_user, ee, data.avg)
      console.log(`finished test for :${username} assessment: ${ ee.data.attributes.assessmentId}`)    
    }

    console.log(`test done for: ${username}`)
    return;
  
  }
  async function run_program(student_user, data, avg){
    
    let assessmentId = data.data.attributes.assessmentId;

    // //create assessment  
    let answersType = "RANDOM";
    let users_assessment = await create_assessment(student_user, assessmentId);

    // //get users assessment in progroess
    let users_assessment_in_progress = await get_users_assessment_in_progress(student_user, assessmentId);
    // assessmentId = users_assessment_in_progress.data.attributes.assessmentId;
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
            
               sleep(rando_sleep(2, 5));

             }
             
              question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
              isAssessmentDone = question.data.attributes.isAssessmentDone;
            
  
            break;
  
            case "LIKERT":
                let answers = get_answers_by_assessment_type(assessmentType, question.data.attributes, "RANDOM");
                 answer_response = {
                    assessmentId: assessmentId,
                    userAssessmentId: userAssessmentId,
                    questionId:questionId, 
                    answers: answers
                }
  
                 question = await send_users_answers_for_assessment_question(student_user, assessmentId, answer_response);
                 isAssessmentDone = question.data.attributes.isAssessmentDone;
                 if(!isAssessmentDone){
                  sleep(rando_sleep(3, 5));

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
  
                    let answer = get_answers_by_assessment_type(assessmentType, q, answersType, answersForQuestion);
                  
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
                        rando_sleep(2, 3)

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
  
          const response = await http.post(renderURL("/token"), {
            username: username,
            grant_type: "password",
            password: password,
            client_id: "application"
          } , params);
          
        check(response, {
          'status is 200': (r) => r.status === 200,
          'accessToken': (r) => r.json().accessToken ,
        });
      
          resolve(response.json());
   
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
      
        resolve(response.json());
    
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
      
        resolve(response.json());
      
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
    
      resolve(response.json());
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
    
      resolve(response.json());
  
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
    
      resolve(response.json());
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
    
      resolve(response.json());
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
  
      resolve(response.json());
    });
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
  
      resolve(response.json());
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
