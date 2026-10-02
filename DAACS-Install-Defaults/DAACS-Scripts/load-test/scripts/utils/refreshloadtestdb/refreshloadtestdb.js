let replicaSet = "";
let host = "";
let mongo_query_string = "?";

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


const MongoClient = require('mongodb').MongoClient;
const fs = require('fs');
const dbName = process.env.MONGODB_DATABASE_NAME;
const connection_string = `mongodb://${process.env.MONGO_USERNAME}:${process.env.MONGO_PASSWORD}@${host}/${dbName}${mongo_query_string}`;

const client = new MongoClient(connection_string);
let testFolder = "imports"
let files = [];
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

    await users.updateMany({}, {$set:{ classroom_pdf :{}, q_status: "", pdfFileURL: ""}});

    await user_assessments.deleteMany({});

    const tokens = db.collection("tokens");
    await tokens.deleteMany({});
    
    const event_containers = db.collection("event_containers");
    await event_containers.deleteMany({});

    await client.close();

    console.timeEnd(id);
    return console.log("done")
    }catch(e){
        console.log(e)
    }
  })();