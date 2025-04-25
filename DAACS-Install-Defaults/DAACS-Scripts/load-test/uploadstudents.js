const MongoClient = require('mongodb').MongoClient;
const fs = require('fs');
const dbName = 'foo23';
const client = new MongoClient(`mongodb://wgioweiog:wgnowiegn@172.16.215.129:27029/${dbName}`);
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
  
    await client.connect();
    console.log('Connected successfully to server');
    const db = client.db(dbName);
    const users = db.collection("users");
    
    for(let i = 501; i <= 1000; i++){

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

  })();