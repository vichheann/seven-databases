/* Find
1.
  db.adminCommand({"top":1})
2.
  http://www.mongodb.org/display/DOCS/Querying
3.
  http://www.mongodb.org/display/DOCS/MapReduce
*/

// 'map_1.js' and 'reduce_1.js' should be loaded

finalize = function(key, value){
  return {"_id": key, "value": {"total":value.count}}
};

db.system.js.save({_id:"finalize", value:finalize});

db.runCommand({
  mapReduce: "phones",
  map: db.eval("map1"),
  reduce: db.eval("reduce1"),
  out: "phones.reports2",
  finalize: db.eval("finalize")
});

db.phones.reports2.find().limit(1).forEach(printjson);
