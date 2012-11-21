/* setup */
var express = require('express');
var appPort = 80;
var collections = ["views"]
var db = require("mongojs").connect("5c3", collections);
var app = express();
app.use(express.bodyParser());

app.use(express.static(__dirname + '/public'));

//register view
app.post('/viewcount', function(req, res) {
    
    if (req.body.event && req.body.duration) {
        db.views.save({event: req.body.event, duration: req.body.duration, time: new Date().getTime()}, function(err, saved) {
            if (err) res.send(500);
            res.send(201);
        });
    } else {
        res.send(400);
    }
    
});

app.get(/viewcount\/(.+)/, function(req, res) {
    
    db.views.count({event:req.params[0]}, function(err, count) {
        if (err) res.send(500);
        res.send(200,""+count);
    });
    
});


//start up
app.listen(appPort);
console.log('Listening on port '+appPort);