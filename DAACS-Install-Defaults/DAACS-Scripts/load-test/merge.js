// var fs = require('fs');
// var obj = JSON.parse(fs.readFileSync('file', 'utf8'));


var fs = require('fs'),
JSONStream = require('JSONStream'),
crypto = require('crypto');
const { parse } = require("csv-parse");


async function getJSONData(file){
  console.log("getJSONData()");
  return new Promise(function(resolve,reject){

      var return_data = [];
      var stream = fs.createReadStream(file, {encoding: 'utf8'}),
      parser1 = JSONStream.parse();
      
      stream.pipe(parser1).on('data', function (obj) {
         
          return_data.push(obj)
          
      }).on('end', function () {
          resolve(return_data);
      })
  })
}




  (async () =>{

    let cuny_old =  await getJSONData('/Users/victormckenzie/Downloads/cuny\ event\ containers/event_containers-2024-12-20.json');
    // console.log(cuny_old.length)

    let cuny_new =  await getJSONData('/Users/victormckenzie/Downloads/cuny\ event\ containers/polandiphoneday.event_containers.json');
    // console.log(cuny_new[0].length)


    cuny_new = cuny_new[0];

    
    cuny_new.forEach((n) => {

        let do_we_Have = cuny_old.find(e => e.userId == n.userId);

            if(do_we_Have != undefined){

                // console.log(n)
                // console.log(do_we_Have)

                   let newarray=  n.userEvents.concat(do_we_Have.userEvents)


                    console.log(do_we_Have.userEvents[0])
                    console.log(n.userEvents[0])
                    console.log(newarray[0])

                throw new Error("WER")
            }


    })


  })()