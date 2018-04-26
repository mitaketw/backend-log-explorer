var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var bodyParser = require('body-parser');

app.use(bodyParser.text());

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

app.post('/log', function(req, res){
  var ui = req.get("ui");
  var host = req.get("host");

  console.log(req.body);

  io.emit(host + "," + ui, req.body);
  io.emit(host + "," + "all", req.body);

  res.end();
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
