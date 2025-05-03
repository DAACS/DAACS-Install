(async ()  => {

  var fs = require('fs');

  //I think we're going to delete this 

  
// file is included here:

db.auth(
  process.env["MONGO_INITDB_ROOT_USERNAME"],
  process.env["MONGO_INITDB_ROOT_PASSWORD"]
);

db = db.getSiblingDB(process.env["MONGODB_DATABASE_NAME"]);

db.createUser({
  user: process.env["MONGO_USERNAME"],
  pwd: process.env["MONGO_PASSWORD"],
  roles: [{ role: "readWrite", db: process.env["MONGODB_DATABASE_NAME"] }],
});

db.createCollection("user_assessments");
db.createCollection("tokens");
db.createCollection("qitems");
db.createCollection("assessmentcategorygroups");
db.createCollection("request_helps");

//default asssessment categories to import
db.assessmentcategorygroups.insertMany([
  {
    _id: "precalculus",
    label: "PreCalculus",
    assessmentCategory: "MATHEMATICS",
  },
  { _id: "writing", label: "writing-group", assessmentCategory: "WRITING" },
  {
    _id: "mathematics",
    label: "mathematics-group",
    assessmentCategory: "MATHEMATICS",
  },
  {
    _id: "college_skills",
    label: "college-skills-group",
    assessmentCategory: "COLLEGE_SKILLS",
  },
  { _id: "reading", label: "reading-group", assessmentCategory: "READING" },
]);



db.createCollection("clients");

//default clients to import
let clientObjId1 = new ObjectId();
let clientObjId2 = new ObjectId();
db.clients.insertMany([
  {
    _id: clientObjId1.toString(),
    grants: ["password", "refresh_token"],
    redirectUris: [],
    id: process.env["API_CLIENT_ID"],
    clientId: process.env["API_CLIENT_ID"],
    clientSecret: "secret",
    __v: 0,
  },
  { "_id": clientObjId2.toString(), grants: [ 'password', 'refresh_token', 'urn:foo:bar:baz' ], redirectUris: [], clientId: 'newsaml', clientSecret: '',__v: 0}
]);

//SAML CLIENT

db.createCollection("event_containers");
db.createCollection("message_stats");
db.createCollection("messages");
db.createCollection("users");

db.users.createIndex({username: 1 }, {unique: true})
db.users.createIndex({email: 1 }, {unique: true, sparse:true})
db.users.createIndex({email: 1, username: 1 }, {unique: true})

//Create default user
 
   const util = require('util');
   const exec = util.promisify(require('child_process').exec);

  let real_command = "";

  real_command = `echo -n  ${process.env.WEB_SERVER_COMMUNICATION_PASSWORD} | sha1sum `;
  
  var communication_password = "";

   try {
           const {
                   stdout,
                   stderr
           } = await exec(real_command)
           communication_password = stdout.split(" ")[0]
   }catch(e){

   }

   let queue_user = {
      _id: crypto.randomUUID().toString(),
    username: process.env.WEB_SERVER_COMMUNICATION_USERNAME ,
    password: communication_password,
    firstName: "communication",
    lastName: "user",
    roles: ["ROLE_COMMUNICATION"],
    rolesAreWritable: false,
    createdDate: new Date(),
    isUserDisabled: false
   };



   if(process.env.WEB_SERVER_COMMUNICATION_EMAIL != undefined && process.env.WEB_SERVER_COMMUNICATION_EMAIL.includes("@")){
    queue_user.email = process.env.WEB_SERVER_COMMUNICATION_EMAIL;
   }

   if(process.env.WEB_SERVER_COMMUNICATION_EMAIL_EXTRA != undefined){
    
    let extra_emails_split = process.env.WEB_SERVER_COMMUNICATION_EMAIL_EXTRA.split(",");
      if(extra_emails_split.length > 0){
      queue_user.extra_alert_emails = [];

        extra_emails_split.forEach((item) => {
          if(item.includes("@")){
            queue_user.extra_alert_emails.push(item);
          }
        })
      }
   }

   db.users.insertOne(queue_user);

    real_command = `echo -n  ${process.env.WEB_SERVER_ADMIN_PASSWORD} | sha1sum `;

   communication_password = "";
    
   try {
    const {
            stdout,
            stderr
      } = await exec(real_command)
      communication_password = stdout.split(" ")[0]
  }catch(e){

  }

   let admin_user = {
    _id: crypto.randomUUID().toString(),
  username: process.env.WEB_SERVER_ADMIN_USERNAME ,
  password: communication_password,
  firstName: "admin-firstname",
  lastName: "admin-lastname",
  roles: ["ROLE_ADMIN"],
  rolesAreWritable: false,
  isUserDisabled: false,
  createdDate: new Date(),
 };


  //default assessment to import


  if(process.env.WEB_SERVER_ADMIN_EMAIL != undefined && process.env.WEB_SERVER_ADMIN_EMAIL.includes("@")){
    admin_user.email = process.env.WEB_SERVER_ADMIN_EMAIL;
   }

   db.users.insertOne(admin_user);

   db.createCollection("assessments");

  const folderPath = '/docker-entrypoint-initdb.d/assessments/';
  const files_scan_list = fs.readdirSync(folderPath);
  let asseessments = [];

   if(files_scan_list.length >  0){

    let asseessments = files_scan_list.map((filename) => { 
      return JSON.parse(fs.readFileSync(`/docker-entrypoint-initdb.d/assessments/${filename}`))
    })
    if(asseessments.length > 0){
      db.assessments.insertMany(asseessments);
    }
  }



  return;
})()
