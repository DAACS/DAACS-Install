(async () => {

    var fs = require('fs');

    //I think we're going to keep this one 

    // db.auth(
    //   process.env["MONGO_INITDB_ROOT_USERNAME"],
    //   process.env["MONGO_INITDB_ROOT_PASSWORD"]
    // );

    db = db.getSiblingDB(process.env["MONGODB_DATABASE_NAME"]);

    db.createUser({
        user: process.env["MONGO_USERNAME"],
        pwd: process.env["MONGO_PASSWORD"],
        roles: [{
            role: "readWrite",
            db: process.env["MONGODB_DATABASE_NAME"]
        }],
    });

    /* USER ASSESSMENTS */

    db.createCollection("user_assessments");
    db.user_assessments.createIndex({
        assessmentSlug: 1
    })

    db.user_assessments.createIndex({
        assessmentId: 1
    })
    db.user_assessments.createIndex({
        userId: 1
    })
    /* TOKENS */

    db.createCollection("tokens");
    db.tokens.createIndex({
        refreshTokenExpiresAt: 1
    }, {
        expireAfterSeconds: 0
    }) //says its never used, so why are we keeping it?

    /* Q ITEMS */

    db.createCollection("qitems");

    /* HELP THREADS */
    db.createCollection("request_helps"); //rename to help-threads

    db.request_helps.createIndex({
        userId: 1
    })
    
    db.request_helps.createIndex({
        assessmentId: 1
    }, {
        sparse: true
    })
    /* DAACS INVITES */
    db.createCollection("daacs_invites"); //maybe we should add some to email and classroom ID

    /* CLASSROOM */

    db.createCollection("classrooms");
    db.classrooms.createIndex({
        slug: 1
    }, {
        unique: true
    })

    /* CLIENTS */

    db.createCollection("clients");

    //default clients to import
    let clientObjId1 = new ObjectId();
    let clientObjId2 = new ObjectId();
    db.clients.insertMany([{
            _id: clientObjId1.toString(),
            grants: ["password", "refresh_token"],
            redirectUris: [],
            id: process.env["API_CLIENT_ID"],
            clientId: process.env["API_CLIENT_ID"],
            clientSecret: "secret",
            __v: 0,
        },
        {
            "_id": clientObjId2.toString(),
            grants: ['password', 'refresh_token', 'urn:foo:bar:baz'],
            redirectUris: [],
            clientId: 'newsaml',
            clientSecret: '',
            __v: 0
        }
    ]);

    /* EVENT CONTAINERS */

    db.createCollection("event_containers");
    db.event_containers.createIndex({
        userId: 1
    }, {
        unique: true
    })

    /* USERS */

    db.createCollection("users");
    db.users.createIndex({
        username: 1
    }, {
        unique: true
    })
    db.users.createIndex({
        email: 1
    }, {
        unique: true,
        sparse: true
    })
    db.users.createIndex({
        email: 1,
        username: 1
    }, {
        unique: true
    })

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
    } catch (e) {

    }
    //Create comms user
    let comms_user_id = crypto.randomUUID().toString()

    let queue_user = {
        _id: comms_user_id,
        username: process.env.WEB_SERVER_COMMUNICATION_USERNAME,
        password: communication_password,
        firstName: "communication",
        lastName: "user",
        createdDate: new Date(),
        isUserDisabled: false,
        verifiedAccount: true,
        isSamlAccount: false,
        saml_properties: [],
        other_properties: [],
        pdfFileURL: "",
        q_status: ""
    };

    if (process.env.WEB_SERVER_COMMUNICATION_EMAIL != undefined && process.env.WEB_SERVER_COMMUNICATION_EMAIL.includes("@")) {
        queue_user.email = process.env.WEB_SERVER_COMMUNICATION_EMAIL;
    }

    if (process.env.WEB_SERVER_COMMUNICATION_EMAIL_EXTRA != undefined) {

        let extra_emails_split = process.env.WEB_SERVER_COMMUNICATION_EMAIL_EXTRA.split(",");
        if (extra_emails_split.length > 0) {
            queue_user.extra_alert_emails = [];

            extra_emails_split.forEach((item) => {
                if (item.includes("@")) {
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
    } catch (e) {

    }
    //Create admin user
    let admin_user_id = crypto.randomUUID().toString()
    let admin_user = {
        _id: admin_user_id,
        username: process.env.WEB_SERVER_ADMIN_USERNAME,
        password: communication_password,
        firstName: "admin-firstname",
        lastName: "admin-lastname",
        isUserDisabled: false,
        verifiedAccount: true,
        createdDate: new Date(),
        isSamlAccount: false,
        saml_properties: [],
        other_properties: [],
        pdfFileURL: "",
        q_status: ""

    };

    if (process.env.WEB_SERVER_ADMIN_EMAIL != undefined && process.env.WEB_SERVER_ADMIN_EMAIL.includes("@")) {
        admin_user.email = process.env.WEB_SERVER_ADMIN_EMAIL;
    }

    db.users.insertOne(admin_user);

    /* ASSESSMENTS */

    db.createCollection("assessments");
    db.assessments.createIndex({
        slug: 1
    }, {
        sparse: true
    })

    db.roles.createIndex({
        users: 1
    })

    //default assessment to import

    const folderPath = '/docker-entrypoint-initdb.d/assessments/';
    const files_scan_list = fs.readdirSync(folderPath);

    if (files_scan_list.length > 0) {

        let asseessments = files_scan_list.map((filename) => {
            return JSON.parse(fs.readFileSync(`${folderPath}/${filename}`))
        })
        if (asseessments.length > 0) {
            db.assessments.insertMany(asseessments);
        }
    }

    /* EVENT CONTAINERS */

    db.createCollection("system_emails");
    db.system_emails.createIndex({
        slug: 1
    },{
        unique: true
    })
    
    const folderPathSystemEmails = '/docker-entrypoint-initdb.d/insert-json-files/system_emails.json';

    if (folderPathSystemEmails.length > 0) {
        db.system_emails.insertMany(JSON.parse(fs.readFileSync(`${folderPathSystemEmails}`)));
    }

    /* ROLES */

    db.createCollection("roles");

    db.roles.createIndex({
        slug: 1
    }, {
        unique: true
    })

    const folderPathRoles = '/docker-entrypoint-initdb.d/insert-json-files/roles.json';

    if (folderPathSystemEmails.length > 0) {
        db.roles.insertMany(JSON.parse(fs.readFileSync(`${folderPathRoles}`)));
    }

    //NEED TO ADD ADMIN TO ADMIN ROLE

    db.roles.findOneAndUpdate({slug: "admin"}, {$push: {'users': admin_user_id}})

    //NEED TO ADD QCOMMUNICATION TO COMMUNICATION ROLE
    db.roles.findOneAndUpdate({slug: "q-server"},  {$push: {'users': comms_user_id}})

    /* PRIVILEGES */

    db.createCollection("privileges");
    const folderPathPrivileges = '/docker-entrypoint-initdb.d/insert-json-files/privileges.json';

    if (folderPathPrivileges.length > 0) {
        db.privileges.insertMany(JSON.parse(fs.readFileSync(`${folderPathPrivileges}`)));
    }
    /* ADMIN USER ASSESSMENTS */

    db.createCollection("admin_user_assessments");

    /* CONTACT FORMS */
    db.createCollection("contact_forms");
    
    return;
})()