/***
 * Excerpted from "Seven Databases in Seven Weeks",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/rwdata for more book information.
***/

var
  settings = require('./settings.js'),
  jsonHeader = {'Content-Type':'application/json'},

  // standard libraries
  http = require('http'),
  redis = require('redis'),
  bricks = require('bricks'),
  mustache = require('mustache'),
  fs = require('fs'),

  // custom libraries
  couchUtil = require('./populate_couch.js'),
  neo4j = require('./neo4j_caching_client.js'),

  mongo = require('mongodb'),
  mongoServer = new mongo.Server(settings.mongodb.host, settings.mongodb.port, {auto_reconnect: true}),
  mongodb = new mongo.Db('test', mongoServer),

  // database clients
  couchdb_port = settings.couchdb.port,
  couchdb_host = settings.couchdb.host,
  neo4jClient = neo4j.createClient({ host: settings.neo4j.host }, { host: settings.redis.host}),
  redisClient = redis.createClient(settings.redis.port, settings.redis.host);

var
  gremlin = neo4jClient.runGremlin;

/**
 * A convenience function for wrapping the
 * reading of JSON reponse data chunks.
 * @param response A Node HTTP response object.
 * @param callback the function to populate and call on completion.
 */
function processBuffer( response, callback )
{
  var buffer = '';
  response.on('data', function(chunk) {
    buffer += chunk;
  });
  response.on('end', function() {
    if(buffer === '') buffer = 'null';
    callback( JSON.parse(buffer) );
  });
};

/*
 * Post one or more documents into CouchDB.
 * @param url is where we POST to.
 * @param docString a stringified JSON document.
 * @param count the number of documents being inserted.
 */
function getCouchDoc( path, httpResponse, callback )
{
  var request = http.get({host:couchdb_host, port:couchdb_port, path:path, headers:jsonHeader},
    function( response ) {
    if( response.statusCode != 200 ) {
      writeTemplate( httpResponse, '', { message: "Value not found" } );
    } else {
      processBuffer( response, function( couchObj ) {
        callback( couchObj );
      });
    }
  }).
  on('error', function(e) {
    console.log('postDoc Got error: ' + e.message);
  });

  request.end();
};

/**
 * Wraps a block of HTML with a standard template. HTML lives in template.html.
 * @innerHtml populates the body of the template
 */
function htmlTemplate( innerHtml )
{
  var file_data = fs.readFileSync( 'template.html', 'utf8' );
  return file_data.replace("[[YIELD]]", innerHtml);
};

function writeTemplate( response, innerHtml, values )
{
  response.write( mustache.to_html( htmlTemplate( innerHtml ), values ));
  response.end();
}

// Blame me, please
function transform_to_JSON( bands )
{
  return bands.map(
       function(band){
         return JSON.parse(band.replace(/name=/,'"name":').replace(/from=/,'"from":').replace(/to=/,'"to":')
                               .replace(/:([^,]*),/g, ':"$1",').replace(/:([^,]*)\}/g, ':"$1"}'));
      });
}

// A Nodejs web app utility setup
appServer = new bricks.appserver();

// attach request plugin to easily extract params
appServer.addRoute("^/", appServer.plugins.request);

/*
 * Just display a blank form if no band is given.
 */
appServer.addRoute("^/$", function(req, res) {
  writeTemplate( res, '', { message: "Find a band" } );
});

/*
 * Accepts a band name and displays all artists in the band.
 * Also displays a list of suggested bands where at least
 * one artist has played at one time.
 */
appServer.addRoute("^/band$", function(req, res) {
  var
    bandName = req.param('name'),
    bandNodePath = '/bands/' + couchUtil.couchKeyify( bandName ),
    membersQuery = 'g.V.filter{it.name=="'+bandName+'"}'
                 + '.out("member").in("member").dedup.name';

  getCouchDoc( bandNodePath, res, function( couchObj ) {
    gremlin( membersQuery, function(graphData) {
      var artists = couchObj && couchObj['artists'];
      var samples = couchObj['samples'] || []; // add song title in a 'samples' array with the couchdb web admin
      var values = { band: bandName, artists: artists, bands: graphData, samples: samples};
      var body = '<h2>{{band}} Band Members</h2>';
      body += '<ul>{{#artists}}';
      body += '<li><a href="/artist?name={{name}}">{{name}}</a></li>';
      body += '{{/artists}}</ul>';
      body += '<h3>Samples</h3>';
      body += '{{#samples}}<div><p>{{.}}</p><audio controls preload="auto">';
/*      body += '<source src="/media?file={{.}}.mp3"/>',
      body += '<source src="/media?file={{.}}.ogg"/>', */
      body += '<source src="/media?file={{.}}.webm"/>',
      body += '</audio></div>{{/samples}}';
      body += '<h3>You may also like</h3>';
      body += '<ul>{{#bands}}';
      body += '<li><a href="/band?name={{.}}">{{.}}</a></li>';
      body += '{{/bands}}</ul>';
      writeTemplate( res, body, values );
    });
  });
});

/*
 * Accepts an artist name and displays band and role information
 */
appServer.addRoute("^/artist$", function(req, res) {
  var
    artistName = req.param('name'),
    rolesQuery = 'g.V.filter{it.name=="'+artistName+'"}.out("plays").role.dedup',
    bandsQuery = 'g.V.filter{it.name=="'+artistName+'"}'+
                 '.inE("member").transform{[name:it.outV.next().name,from:it.map.next().from_date,to:it.map.next().to_date]}';
  gremlin( rolesQuery, function(roles) {
    gremlin( bandsQuery, function(bands) {
      bands = transform_to_JSON(bands);
      var values = { artist: artistName, roles: roles, bands: bands };
      var body = '<h3>{{artist}} Performs these Roles</h3>';
      body += '<ul>{{#roles}}';
      body += '<li>{{.}}</li>';
      body += '{{/roles}}</ul>';
      body += '<h3>Play in Bands</h3>';
      body += '<ul>{{#bands}}';
      body += '<li>({{from}} / {{to}}) <a href="/band?name={{name}}">{{name}}</a></li>';
      body += '{{/bands}}</ul>';
      writeTemplate( res, body, values );
    });
  });
});

/*
 * A band name search. Used for autocompletion.
 */
appServer.addRoute("^/search$", function(req, res) {
  var query = req.param('term');

  redisClient.keys("band-name:"+query+"*", function(error, keys) {
    var bands = [];
    keys.forEach(function(key){
      bands.push(key.replace("band-name:", ''));
    });
    res.write( JSON.stringify(bands) );
    res.end();
  });
});

mongodb.open(function(err, mongodb) {
  if (err) {
    console.log(err);
    process.exit(1);
  }
  console.log("Mongodb opened");
});

appServer.addRoute("^/media$", function(req, res) {
  var fileName = req.param('file');

  var gridStore = new mongo.GridStore(mongodb, fileName, "r", {root:'fs'});
  gridStore.open(function(err, gridStore) {
    var stream = gridStore.stream(true),
        contentType = gridStore.contentType;
    if (contentType.length == 0) contentType = "audio/mpeg";
    res.sendDate;
    res.setHeader("Content-Type", contentType);
    stream.on("data", function(chunk) {
      console.log("Streaming ... " + fileName);
      res.write(chunk);
    });

    stream.on("end", function() {
      res.end();
    });

    stream.on("error", function(err) {
      console.log(err);
      res.end();
    });
  });
});

// catch all unknown routes with a 404
appServer.addRoute(".+", appServer.plugins.fourohfour);
appServer.addRoute(".+", appServer.plugins.loghandler, { section: "final" });

// start up the server
console.log("Starting Server on port " + settings.port);
appServer.createServer().listen(settings.port);
