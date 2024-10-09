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

db.createCollection("itemqueues");

