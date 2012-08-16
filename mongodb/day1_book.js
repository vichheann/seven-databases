/*
Find:
1.
  http://docs.mongodb.org/manual/
2.
  http://www.mongodb.org/display/DOCS/Advanced+Queries#AdvancedQueries-RegularExpressions
4.
  gem install mongo
*/

db.towns.remove({});

db.towns.insert({
  name: "New York",
  population: 222000000,
  last_census: ISODate("2009-07-31"),
  famous_for: ["statue of liberty", "food"],
  mayor: {
    name: "Michael Bloomberg",
    party: "I"
  }
});

function insertCity(name, population, last_census, famous_for, mayor_info) {
  db.towns.insert({
    name:name, 
    population:population,
    last_census: ISODate(last_census),
    famous_for:famous_for,
    mayor : mayor_info 
  });
}

insertCity("Punxsutawney", 6200, '2008-31-01', ["phil the groundhog"], {name:"Jim Wehrle"});
insertCity("Portland", 582000, '2007-20-09', ["beer", "food"], {name:"Sam Adams", party:"D"});

db.countries.insert({
  _id: "us",
  name: "United States",
  exports: {
    foods: [
      {name: "bacon", tasty: true},
      {name: "burgers"}
    ]
  }
});

db.countries.insert({
  _id: "ca",
  name: "Canada",
  exports: {
    foods: [
      {name: "bacon", tasty: false},
      {name: "syrup", tasty: true}
    ]
  }
});

db.countries.insert({
  _id: "mx",
  name: "Mexico",
  exports: {
    foods: [
      {name: "salsa", tasty: true, condiment: true}
    ]
  }
});

var portland = db.towns.findOne({"name":"Portland"});

printjson(portland);

db.towns.update(
  { "_id" : portland._id},
  {$set: {"state":"OR"}}
);

db.towns.update(
  { "_id" : portland._id},
  {$inc: {population:1000}}
);

db.towns.update(
  { "_id" : portland._id},
  {$set: {country: {$ref:"countries", $id:"us"}}}
);

db.towns.find({"name": "Portland"}).forEach(printjson);

print("-->1")
printjson({"hello":"world"});

print("-->2")
db.towns.find({"name": /new/i}).forEach(printjson);

print("-->3")
db.towns.find({"name": /e/}, {$or: [{"famous_for":"beer"}, {"famous_for":"food"}]}).forEach(printjson);

