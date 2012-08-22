var http = require('http'),
    events = require('events');

exports.createWatcher = function(options) {

  var watcher = new events.EventEmitter();

  watcher.host = options.host || 'localhost';
  watcher.port = options.port || 5984;
  watcher.last_seq = options.last_seq || 0;
  watcher.db = options.db || '_users';

  watcher.start = function() {
    var http_options = {
          host: watcher.host,
          port: watcher.port,
          path: '/' + watcher.db + '/_changes?feed=continuous&include_docs=true&since=' + watcher.last_seq
       };

    http.get(http_options, function(response){
      var buffer = '';

      var parseBuffer = function() {
        lines = buffer.split("\n");
        if (buffer.charAt(buffer.length - 1) != "\n")
          buffer = lines.pop();
        else
          buffer = '';

        lines.forEach(function(line) {
          if (line) {
            var json = JSON.parse(line);
            watcher.last_seq = json.last_seq;// keep track of the last req when re-calling start()
            watcher.emit("change", json);
          }
        });

      }

      response.on('data', function(chunk){
        buffer+=chunk;
        parseBuffer();
      });
      response.on('end', function(){
        parseBuffer();
        watcher.start();//recall when disconnecting
      });
    }).on('error', function(err) {
      watcher.emit('error', err);
    });
  };

  return watcher;

};

if (!module.parent) {
  exports.createWatcher({
    db: process.argv[2],
    last_seq: process.argv[3]
  })
    .on('change', console.log)
    .on('error', console.error)
    .start();
}

