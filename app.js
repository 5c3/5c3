/* setup */
var password = "asd";
var express = require('express');
var appPort = 8003;
var collections = ["events","speakers"]
var db = require("mongojs").connect("5c3", collections);
var app = express();
var http = require('http');
app.use(express.bodyParser());
app.use(express.static(__dirname + '/public'));


//authentication
var adminAuth = express.basicAuth(function(user,pwd) {
    return (pwd = password);
}, 'Restrict area, please identify');


//register view
app.post(/event\/(.+)/, function(req, res) {
    if (req.params[0]) {
        db.events.update({_id: req.params[0]}, { $inc: { popularity: 1 } }, function(err, saved) {
            if (err) res.send(500);
            res.send(201);
        });
    } else {
        res.send(400);
    }
});


app.get(/event\/(.+)/, function(req, res) {
    db.events.find({_id:req.params[0]}, function(err, event) {
        if (err) res.send(500);
        if (!event[0]) {res.send(404); return;}
        res.json(event[0]);
    });
    
});



app.get('/events', function(req, res) {
    db.events.find({},{"abstract":0, "description":0},function(err, docs) {
        if (err) res.send(500);

        for (i=0;i<docs.length;i++) {
            
            duration = docs[i].duration.split(":");
            endtime = (docs[i].timestamp + parseInt(duration[0])*3600 + parseInt([1])*60);
            
            if (docs[i].timestamp>new Date().getTime()/1000) docs[i].status = "upcoming";
            else if (endtime>new Date().getTime()/1000) {
                docs[i].status = "live";
                if (docs[i].location == "Saal 1") docs[i].video = "http://cdn.29c3.fem-net.de/hls/saal1/saal1_multi.m3u8";
                else if (docs[i].location == "Saal 4") docs[i].video = "http://cdn.29c3.fem-net.de/hls/saal4/saal4_hq.m3u8";
                else if (docs[i].location == "Saal 6") docs[i].video = "http://cdn.29c3.fem-net.de/hls/saal6/saal6_hq.m3u8";
            } else {
                docs[i].status = "past";
                docs[i].video = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
            }            
        }
        
        res.json(docs);
    });
});


app.get('/speakers', function(req, res) {
    db.speakers.find(function(err, docs) {
        if (err) res.send(500);
        res.json(docs);
    });
});


app.post('/events',adminAuth, function(req, res) {
    
    xml2js = require('xml2js');
    
    var parser = new xml2js.Parser();
    
    url = require('url').parse(req.body.url);
    
    var options = {
      host: url.hostname,
      port: url.port,
      path: url.path,
      method: 'GET'
    };
    
    var req = http.get(options, function(xmlRes) {
        var pageData = "";
        xmlRes.setEncoding('utf8');
        
        xmlRes.on('data', function (chunk) {
            pageData += chunk;
        });
        
        xmlRes.on('end', function(){
            parser.parseString(pageData, function (err, eventJson) {
                
                events = [];
                                
                for (i=0;i<eventJson.schedule.day.length;i++) {
                    for (j=0;j<eventJson.schedule.day[i].room.length;j++) {
                        if (eventJson.schedule.day[i].room[j].event) {
                            for (e=0;e<eventJson.schedule.day[i].room[j].event.length;e++) {
                            
                                obj = {};
                                obj._id = eventJson.schedule.day[i].room[j].event[e].$.id;
                                obj.conference = eventJson.schedule.conference[0].title[0];
                                obj.date = eventJson.schedule.day[i].$.date;
                                obj.location = eventJson.schedule.day[i].room[j].$.name;
                                obj.start = eventJson.schedule.day[i].room[j].event[e].start[0];
                                obj.duration = eventJson.schedule.day[i].room[j].event[e].duration[0];
                                obj.room = eventJson.schedule.day[i].room[j].event[e].room[0];
                                obj.slug = eventJson.schedule.day[i].room[j].event[e].slug[0];
                                obj.title = eventJson.schedule.day[i].room[j].event[e].title[0];
                                obj.subtitle = eventJson.schedule.day[i].room[j].event[e].subtitle[0];
                                obj.track = eventJson.schedule.day[i].room[j].event[e].track[0];
                                obj.type = eventJson.schedule.day[i].room[j].event[e].type[0];
                                obj.language = eventJson.schedule.day[i].room[j].event[e].language[0];
                                
                                dateParts = obj.date.split("-");
                                timeParts = obj.start.split(":");
                                
                                day = parseInt(dateParts[2]);
                                if (parseInt(timeParts[0])<7) {
                                    day++;
                                }
                                    
                                obj.timestamp = new Date(parseInt(dateParts[0]), (parseInt(dateParts[1]) - 1),day ,parseInt(timeParts[0])+1,parseInt(timeParts[1])).getTime()/1000;
                                obj.persons = [];
                                try {
                                    for (p=0;p<eventJson.schedule.day[i].room[j].event[e].persons[0].person.length;p++) {
                                        obj.persons.push(eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["_"]);
                                        currentSpeaker = {"name":eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["_"],"_id":eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["$"].id};
                                        console.log("speaker"+eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["$"].id);
                                        db.speakers.update({"_id":eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["$"].id},currentSpeaker, {upsert:true}, function (err,saved) {});
                                        
                                    }
                                } catch (e) {}
                                
                                obj.links = [];
                                try {
                                    for (l=0;l<eventJson.schedule.day[i].room[j].event[e].links[0].link.length;l++) {
                                        obj.links.push(eventJson.schedule.day[i].room[j].event[e].links[0].link[l].$.href);                                        
                                    }
                                } catch (e) {}
                                
                                
                                obj.description = eventJson.schedule.day[i].room[j].event[e].description[0];
                                obj.abstract = eventJson.schedule.day[i].room[j].event[e].abstract[0];
                                events.push(obj);
                                //db.events.save(obj, function(err, saved) {});
                            }
                        }
                    }
                }
                
                events.forEach(function (event) {
                    db.events.update( {_id:event._id},event, {upsert:true}, function (err,saved) {
                        if (err) res.send(500);
                    });
                });
                
                res.send(200);
                
                
                
            });
        });
    });
});



//start up
app.listen(appPort);
console.log('Listening on port '+appPort);