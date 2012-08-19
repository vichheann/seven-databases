// 1

UNIT = {KM:6371, MILE:3959};

//There's some cities which latitude and longitude label were reversed (e.g. Paris,FR)
//So if it does not work as expected, try to change them
findNearBy = function(city, distance, unit) {
  var location = city["location"];
  var earth_radius = unit;
  var radius = distance / earth_radius;
  return db.cities.find({
           location : {
             $within : {
               $centerSphere : [[location['latitude'], location['longitude']], radius]}}});
};

var london = db.cities.findOne({name:"London", country:"GB"}, {location:true, _id:false});

// usage: findNearBy(london, 50, UNIT.MILE).forEach(printjson);

// It's a try, I don't really know how to do that ;)
findNearByBox = function(city, distance, unit) {
  var location = city["location"];
  var earth_radius = unit;
  var radius = distance / earth_radius;
  var lower_left = [location['latitude'] - radius/2, location['longitude'] - radius/2 ];
  var upper_right = [location['latitude'] + radius/2, location['longitude'] + radius/2 ];
  return db.cities.find({
           location : {
             $within : {
               $box : [lower_left, upper_right]}}});
};