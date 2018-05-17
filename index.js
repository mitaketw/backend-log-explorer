var express = require('express');
var app = express();
var fs = require('fs');
var glob = require('glob');
var path = require("path");
var yaml = require("js-yaml");
var child_process = require("child_process");
var http = require('http').Server(app);
var io = require('socket.io')(http);
var bodyParser = require('body-parser');

app.use(bodyParser.text());
app.use(express.static('public'));

app.set('view engine', 'pug');

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

app.post('/log', function(req, res){
  var host = req.get("host").toLowerCase();
  var ui = req.get("ui").toLowerCase();

  console.log(req.body);

  io.emit(host + "," + ui, req.body);
  io.emit(host + "," + "all", req.body);

  res.end();
});

app.get('/charts', function(req, res){
  var files = glob.sync(__dirname + "/chart/*.yml");

  var ymlFiles = files.map(function(file){
    return path.basename(file);
  });

  var files = glob.sync(__dirname + "/public/generated/*.png");

  var pngFiles = files.map(function(file){
    return "/public/generated/" + path.basename(file);
  });

  res.render("chart.pug", {
    ymlFiles: ymlFiles,
    pngFiles: pngFiles
  });
});

app.get('/charts/:filename', function(req, res){
  var json = yaml.safeLoad(fs.readFileSync(__dirname + '/chart/' + req.params.filename, 'utf-8'));

  res.json(json);
});

app.post('/charts/generate', function(req, res){
  var args = Object.keys(req.query).map(function(q){
    return req.query[q];
  });

  var cmd = __dirname + "/chart/chart.sh " + __dirname + "/chart/" + args.join(" ");

  console.log("cmd: " + cmd);

  child_process.exec(cmd, {
    cwd: __dirname + "/chart"
  }, function(err, stdout, stderr){
    console.log(stdout);

    res.send(stdout);
  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});