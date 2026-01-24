(async ()  => {
//Not implemented into anything yet
var fs = require('fs');

db = db.getSiblingDB(process.env["MONGODB_DATABASE_NAME"]);

db.createUser({
  user: process.env["MONGO_USERNAME"],
  pwd: process.env["MONGO_PASSWORD"],
  roles: [{ role: "readWrite", db: process.env["MONGODB_DATABASE_NAME"] }],
});



})