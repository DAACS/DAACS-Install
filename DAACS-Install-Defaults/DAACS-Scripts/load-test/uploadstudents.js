/*

M_USERNAME="" M_PASSWORD="" M_HOST="IP" M_PORT="PORT" DB="" node /Users/victormckenzie/webdev/daacs-loadtest/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/uploadstudents.js

M_USERNAME="" M_PASSWORD="" M_HOST="IP:PORT,IP:PORT,IP:PORT" DB="" REPLICA_SET="" node /Users/victormckenzie/webdev/daacs-loadtest/DAACS-Install/DAACS-Install-Defaults/DAACS-Scripts/load-test/uploadstudents.js

*/

let replicaSet = "";
let host = "";
let mongo_query_string = "?";

if(process.env.REPLICA_SET != undefined){
  host = process.env.M_HOST;
  replicaSet = `replicaSet=${process.env.REPLICA_SET}`
  mongo_query_string += replicaSet
}else{
  host = `${process.env.M_HOST}:${process.env.M_PORT}`

}

const MongoClient = require('mongodb').MongoClient;
const fs = require('fs');
const dbName = process.env.DB;
const connection_string = `mongodb://${process.env.M_USERNAME}:${process.env.M_PASSWORD}@${host}/${dbName}${mongo_query_string}`;

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
    
    for(let i = 1; i <= 1000; i++){

    await users.insertOne(
    {
        "_id": generateUUID(),
        "roles": [
          "ROLE_STUDENT"
        ],
        "isUserDisabled": false,
        "username": "student.test"+ i,
        "firstName": "student",
        "lastName": "test"+i,
        "password": "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8",
        "rolesAreWritable": false,
        "email": "student.test"+ i+ "@victor.com",
        "isSamlAccount": false,
        "hasDataUsageConsent": false,
        "__v": 0,
        "createdDate": new Date(),
        "pdfFileURL": ""
      })
    }
    
    await client.close();

    console.timeEnd(id);
    return console.log("done")
    }catch(e){
        console.log(e)
    }
  })();