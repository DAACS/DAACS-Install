/*

MONGO_USERNAME="" MONGO_PASSWORD="" MONGODB_HOST="IP" MONGODB_PORT="PORT" MONGODB_DATABASE_NAME="" node /Users/victormckenzie/webdev/daacs-loadtest/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/uploadstudents.js
MONGO_USERNAME="" MONGO_PASSWORD="" MONGODB_HOST="IP" MONGODB_PORT="PORT" MONGODB_DATABASE_NAME="" node /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/scripts/utils/upload-students/uploadstudents.js

cat "/home/moo/DAACS-Install/new-env-setups/mongossl/databases/yogurt/webserver-mongo" |  node /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/scripts/utils/upload-students/uploadstudents.js

export $(cat "/home/moo/DAACS-Install/new-env-setups/mongossl/databases/yogurt/webserver-mongo" | xargs) && node /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/scripts/utils/upload-students/uploadstudents.js


echo $(cat "/home/moo/DAACS-Install/new-env-setups/mongossl/databases/yogurt/webserver-mongo")  &&  node /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/scripts/utils/upload-students/uploadstudents.js



MONGO_USERNAME="" MONGO_PASSWORD="" MONGODB_HOST="IP:PORT,IP:PORT,IP:PORT" MONGODB_DATABASE_NAME="" REPLICA_SET="" node /Users/victormckenzie/webdev/daacs-loadtest/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/uploadstudents.js

MONGODB_CRT=/Users/victormckenzie/Desktop/newmongo/home/mongodb.crt
MONDGODB_PEM=/Users/victormckenzie/Desktop/newmongo/home/mongodb.pem

directConnection=true&serverSelectionTimeoutMS=2000&authSource=admin&tls=true&tlsCAFile=${MONGODB_CRT}&tlsCertificateKeyFile=${MONDGODB_PEM}&appName=mongosh 2.4.0&tlsAllowInvalidHostnames=true


*/

let replicaSet = "";
let host = "";
let mongo_query_string = "?";
let NUMBER_TO_UPLOAD = 1;

if(process.env.REPLICA_SET != undefined){
  host = process.env.MONGODB_HOST;
  replicaSet = `replicaSet=${process.env.REPLICA_SET}`
  mongo_query_string += replicaSet
}else{
  host = `${process.env.MONGODB_HOST}:${process.env.MONGODB_PORT}`

}

if(process.env.MONGODB_SSL != undefined && process.env.MONGODB_SSL == "true"){

  mongo_query_string += `directConnection=true&serverSelectionTimeoutMS=2000&tls=true&tlsCAFile=${process.env.MONGODB_CRT}&tlsCertificateKeyFile=${process.env.MONDGODB_PEM}&tlsAllowInvalidHostnames=true`
}

if(process.env.NUMBER_TO_UPLOAD != undefined && isNaN(parseInt(process.env.NUMBER_TO_UPLOAD)) == false){

  NUMBER_TO_UPLOAD =  parseInt(process.env.NUMBER_TO_UPLOAD)
}

// console.log(process.env)
const MongoClient = require('mongodb').MongoClient;
const fs = require('fs');
const dbName = process.env.MONGODB_DATABASE_NAME;
const connection_string = `mongodb://${process.env.MONGO_USERNAME}:${process.env.MONGO_PASSWORD}@${host}/${dbName}${mongo_query_string}`;

// console.log(connection_string)
// return;
const client = new MongoClient(connection_string);
let testFolder = "imports"
let files = [];
// fs.readdirSync(testFolder).forEach(file => {
//         files.push(file);
//   });

//   return console.log(files);
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }

  (async () =>{

    let id = "test1";
    console.time(id);
  
    try{


    await client.connect();
    console.log('Connected successfully to server');
    const db = client.db(dbName);
    const users = db.collection("users");
    const user_assessments = db.collection("user_assessments");
    const roles = db.collection("roles");

    await users.deleteMany({"firstName": "student"});
    // await user_assessments.deleteMany({});

    
    let list_of_ids = [];

    for(let i = 1; i <= NUMBER_TO_UPLOAD; i++){

      const id = generateUUID();
      const username =  "student.test"+ i;
      const firstname = "student";
      const lastname = "test"+i;
      const hashed_password = "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8";
      const email = "student.test"+ i+ "@victor.com";

          var user = {
                _id:  id,
                username: username.trim(),
                password: hashed_password,
                firstName: firstname,
                lastName: lastname,
                email: email.trim(), 
                createdDate: new Date(),
                isUserDisabled: false,
                verifyAccountToken: "asdfasfsf"+ i,
                verifiedAccount: true,
                isSamlAccount: false,
                pdfFileURL:"",
                q_status: "",
                classroom_pdf: {}
            };

    await users.insertOne(user)

      list_of_ids.push(id)

    }

    // //add ids to student role
    await roles.findOneAndUpdate({slug: "student"},{$set: { users: []  }} );
    await roles.findOneAndUpdate({slug: "student"},{$set: { users: list_of_ids  }} );

    const classrooms = db.collection("classrooms");
    await classrooms.deleteMany({});

    let students_per_class = 30
    let classrooms_to_create = Math.ceil(NUMBER_TO_UPLOAD / students_per_class)
      let student_count = 0

    for(let i = 1; i <= classrooms_to_create; i++){

      // console.log(i)
        //create classroom
        let data = {};
        const author_id = "1"
        let classroom_id = crypto.randomUUID().toString();
        data._id = classroom_id;
        data.title = "Load test "+ i;
        data.description = "This is a load test classroom";
        data.slug = "loadtest-" + i;
        data.createdAt = new Date();
        data.author_id = author_id;
        data.createdBy = author_id;
        data.auto_accept_enroll = true;
        data.auto_accept_enroll = true;
        data.invite_link_code = crypto.randomUUID().toString();
        data.status = 3
        data.case_manager_limit = 5
        data.enrolled_student_limit = 40
        data.send_enrollment_emails_for_student = false;
        data.send_enrollment_emails_for_instructor = false; 
        data.lti_classroom = false;
        data.lti_assessment_settings = [];
        data.case_manager = []
        data.assessments = []
        data.students = []
        
        //add students to classroom
        let up_to_index = ((i- 1) * students_per_class) 

        for(let index = ((i- 1) * students_per_class)  ; index < ( i * students_per_class) ; index ++){

          if(list_of_ids[index] == undefined){
            break;
          }

          //enable student
          let student_insert_data = {userId: list_of_ids[index], id: crypto.randomUUID(), accepted: true, accepted_date: new Date(), added_date: new Date() , addition_apparatus: "load-test"};
          data.students.push(student_insert_data)
        }
        const assessment_list = [{slug: "self-regulated-learning", id: "46997151-21a3-4eef-b657-e7dcdd913481"} , {slug: "writing" , id: "e1ca9e67-2882-4ebb-b3e7-0ac02b321c8f"} , {slug: "mathematics" , id: "79ba2ed2-0d9a-4eaf-8b3e-ae54ccfaa365"} , {slug: "reading" , id:"795c8469-9bdd-439a-9251-34457bd04adc"} ];
        
        //add assessment to classroom
        for(let assessment of assessment_list){

            let new_assessment_obj = {};
            
          new_assessment_obj._id = crypto.randomUUID().toString()
          new_assessment_obj.assessmentId = assessment.id
          new_assessment_obj.slug = assessment.slug
          new_assessment_obj.added_date = new Date();

          
          data.assessments.push(new_assessment_obj)
        }

        //savew classroom data
        await classrooms.insertOne(data)

    }

    await client.close();

    console.timeEnd(id);
    return console.log("done")
    }catch(e){
        console.log(e)
    }
  })();