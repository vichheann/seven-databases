db = db.getSisterDB("blogger")

db.articles.drop();

print("--> 4")
my_article = {
  _id:"Mongo",
  author:"Me",
  email:"me@somewhere.com",
  creation_date: ISODate(),
  text:"Mongodb rocks!"
};
db.articles.insert(my_article);
db.articles.find().forEach(printjson);

db.articles.update(
  { "_id" : "Mongo" },
  { $set : {"comments": [{"author":"Mr X", "text":"NoSQL rules"}] }}
);

print("--> 5")
db.articles.find().forEach(printjson);

