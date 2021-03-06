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

  // how many bands we expect to process
  totalBands = null,
  // and keep track of how many bands we have processed
  processedBands = 0,
  // The name of the couch database
  couchDBpath = '/bands',

  // standard libraries
  http = require('http'),
  redis = require('redis'),

  // database clients
//[Vic] createClient is deprecated
// couchPort = http.createClient(5984),
  couchPort = settings.couchdb.port,
  couchHost = settings.couchdb.host,
  couchdb_options = {
      host: couchHost,
      port: couchPort,
      path: couchDBpath+'/_bulk_docs',
      agent: new http.Agent({host: couchHost, port: couchPort, maxSockets: 1}),
      method: 'POST',
      headers: {'Content-Type': 'application/json'}
  },
  redisClient = redis.createClient(settings.redis.port, settings.redis.host);

/**
 * A helper function that builds a good CouchDB key
 * @param string the unicode string being keyified
 */
function couchKeyify( string )
{
  // remove bad chars, and disallow starting with an underscore
  return string.
    replace(/[\t \?\#\\\-\+\.\,'"()*&!\/]+/g, '_').
    replace(/^_+/, '');
};

/*
 * Keep track of the number of bands processed, output every 1000 loaded,
 * and close the Redis client when we've loaded them all.
 */
function trackLineCount( increment ) {

  processedBands += increment;

  // output once every 1000 lines
  if(processedBands % 1000 === 0)
    console.log('Bands Loaded: ' + processedBands);

  // close the Redis Client when complete
  if(totalBands <= processedBands) {
    console.log('Total Bands Loaded: ' + processedBands);
    redisClient.quit();
  }
};

/*
 * Post one or more documents into CouchDB.
 * @param url is where we POST to.
 * @param docString a stringified JSON document.
 * @param count the number of documents being inserted.
 */
function postDoc( url, docsString, count ) {

  var request = http.request(couchdb_options, function(res) {
    res.on("end", function() {
// Fix => Got Error: socket hang up
// read http://nodejs.org/api/http.html#http_class_http_agent
// and https://github.com/felixge/node-couchdb/issues/38
      couchdb_options.agent.sockets[couchdb_options.host + ':' + couchdb_options.port][0].emit("agentRemove");
      });
    if(res.statusCode == 201)
      trackLineCount( count );
  }).on('error', function(e) {
      console.log('postDoc Got error: ' + e);
    });

  request.end(docsString);
};

/*
 * Loop through all of the bands populated in Redis. We expect
 * the format of each key to be 'band:Band Name' having the value
 * as a set of artist names. The artists each have the list of roles
 * they play in each band, keyed by 'artist:Band Name:Artist Name'.
 * The band name, set of artists, and set of roles each artist plays
 * populates the CouchDB documents. eg:
  {
    name:"Nirvana",
    artists:[{
      name: "Kurt Cobain",
      roles:["Lead Vocals", "Guitar"]
    },...]
  }
 */
function populateBands() {

  // First, create the couch database
  http.request({
      host: couchHost,
      port: couchPort,
      path: couchDBpath,
      method: 'PUT'}).end();

  redisClient.keys('band:*', function(error, bandKeys) {
    totalBands = bandKeys.length;
    var
      readBands = 0,
      bandsBatch = [];

    bandKeys.forEach(function(bandKey) {
      // substring of 'band:'.length gives us the band name
      var bandName = bandKey.substring(5);
      redisClient.smembers(bandKey, function(error, artists) {
        // batch the Redis calls to get all artists' information at once
        var infosBatch = [];
        artists.forEach(function(artistName) {
          infosBatch.push([
            'hgetall',
            'artist:' + bandName + ':' + artistName,
          ]);
        });

        // batch up each band member to find the roles they play
        redisClient.
          multi(infosBatch).
          exec(function(err, infos)
          {
            var
              i = 0,
              artistDocs = [],
              info = [];
              roles = [];

            // build the artists sub-documents
            artists.forEach( function(artistName) {
              info = infos[i++];
              if (info.roles.length > 0) {
                roles = info.roles.split(',');
              }
              else
                roles = [];
              artistDocs.push({ name: artistName, role: roles, from: info.from, to: info.to });
            });

            // add this new band document to the batch to be executed later
            bandsBatch.push({
              _id: couchKeyify( bandName ),
              name: bandName,
              artists: artistDocs
            });
            // keep track of the total number of bands read
            readBands++;

            // upload batches of 50 values to couch, or the remaining values left
            if( bandsBatch.length >= 50 || totalBands - readBands == 0) {
              postDoc(
                couchDBpath+'/_bulk_docs',
                JSON.stringify({ docs : bandsBatch }),
                bandsBatch.length);

              // empty out the batch array to be filled again
              bandsBatch = [];
            }
          }
        );
      });
    });
  });
};

// expose couchKeyify function
exports.couchKeyify = couchKeyify;

// start populating bands if running as main script
if(!module.parent) {
  populateBands();
}
