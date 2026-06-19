let mongo_query_string = "";

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
const connection_string = `mongodb://${host}/${mongo_query_string}`;
console.log(connection_string)

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

        const admin = client.db().admin();
const dbInfo = await admin.listDatabases();
for (const db of dbInfo.databases) {

    if(db.name == "admin" || db.name == "local" || db.name == "config" ){
        continue;
    }
        for await (collect of  client.db(db.name).listCollections()  ){
                const database = client.db(db.name);
                if(collect.name == "user_assessments") {
                    const collection = database.collection(collect.name);
                    console.log(await collection.deleteMany({}))
                }
                if(collect.name == "tokens") {
                    const collection = database.collection(collect.name);
                    console.log(await collection.deleteMany({}))
                }
                if(collect.name == "event_containers") {
                    const collection = database.collection(collect.name);
                    console.log(await collection.deleteMany({}))
                }
                
            }
        
}

    await client.close();
        

    }catch(e){

    }

})()


