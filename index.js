var app = require('express')();
var glob = require('glob');
var path = require("path");
var http = require('http').Server(app);
var io = require('socket.io')(http);
var bodyParser = require('body-parser');

app.use(bodyParser.text());

app.set('view engine', 'pug');

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

app.get('/chart', function(req, res){
  var files = glob.sync(__dirname + "/chart/*.yml");

  var filenames = files.map(function(file){
    return path.basename(file);
  });

  res.render("chart.pug", {
    filenames: filenames
  });
});

app.post('/log', function(req, res){
  var host = req.get("host").toLowerCase();
  var ui = req.get("ui").toLowerCase();

  console.log(req.body);

  io.emit(host + "," + ui, req.body);
  io.emit(host + "," + "all", req.body);

  res.end();
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
