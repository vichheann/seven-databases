var settings = {};

settings.redis = {host: "172.16.195.1", port: 6379};
settings.couchdb = {host: "ubuntudev12", port: 5984};
settings.neo4j = {host: "ubuntudev12", port: 7474};
settings.mongodb = {host: "ubuntudev12", port: 27017};
settings.port = 8080;

module.exports = settings;