/* setup */
var express = require('express');
var appPort = 80;
var collections = ["events"]
var db = require("mongojs").connect("5c3", collections);
var app = express();
var http = require('http');
app.use(express.bodyParser());
app.use(express.static(__dirname + '/public'));

//register view
app.post(/event\/(.+)/, function(req, res) {
    console.log(req);
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
        res.json(docs);
    });
});



app.post('/events', function(req, res) {
    
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
                            obj.persons = [];
                            try {
                                for (p=0;p<eventJson.schedule.day[i].room[j].event[e].persons[0].person.length;p++) {
                                    obj.persons.push(eventJson.schedule.day[i].room[j].event[e].persons[0].person[p]["_"]);
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