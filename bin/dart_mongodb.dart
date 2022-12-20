// import 'package:dart_mongodb/dart_mongodb.dart' as dart_mongodb;
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  // Connect to database
  Db db = Db('mongodb://127.0.0.1:27017/test');
  await db.open();

  print("Connected to database");

  // People Collection
  DbCollection peopleCollection = db.collection('people');

  // Read people collection
  // ---
  // var people = await peopleCollection.find().toList();
  // var people = await peopleCollection.find(where.eq('first_name', 'Calypso')).toList();
  // var people = await peopleCollection.find(where.match('first_name', 'B')).toList();
  var people = await peopleCollection.find(where.limit(5)).toList();
  print("people: $people");

  var person = await peopleCollection
      // .findOne(where.match('first_name', 'B').and(where.gt('id', 40)));
      // .findOne(where.match('first_name', 'B').gt('id', 40));
      .findOne(where.jsQuery('''
      return this.first_name.startsWith('B') && this.id > 40;
      '''));
  print("person: $person");

  // Create person
  await peopleCollection.insertOne({
    "id": 101,
    "first_name": "Jermaine",
    "last_name": "Gippes",
    "email": "cgippes2r@xinhuanet.com",
    "gender": "Female",
    "ip_address": "97.252.84.122"
  });
  print("insertOne: saved new person");
  print(await peopleCollection.findOne(where.eq('id', 101)));

  // Update person
  await peopleCollection.update(
    await peopleCollection.findOne(where.eq('id', 101)),
    {
      r'$set': {
        'gender': 'Male',
      }
    },
  );
  print("update: Updated person");
  print(await peopleCollection.findOne(where.eq('id', 101)));

  // Delete person
  await peopleCollection
      .remove(await peopleCollection.findOne(where.eq('id', 101)));
  print("remove: Deleted person");
  print(await peopleCollection.findOne(where.eq('id', 101))); // null

  // Close Database
  await db.close();
}
