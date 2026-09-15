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
    //todo - need to update this with newest user object
    

    await users.deleteMany({"firstName": "student"});
    await user_assessments.deleteMany({});

    
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

    //add ids to student role
    await roles.findOneAndUpdate({slug: "student"},{$set: { users: []  }} );
    await roles.findOneAndUpdate({slug: "student"},{$set: { users: list_of_ids  }} );


    await client.close();

    console.timeEnd(id);
    return console.log("done")
    }catch(e){
        console.log(e)
    }
  })();