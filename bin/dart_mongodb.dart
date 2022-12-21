// import 'package:dart_mongodb/dart_mongodb.dart' as dart_mongodb;
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';

void main(List<String> arguments) async {
  int port = 8085;
  var server = await HttpServer.bind('localhost', port);
  // Connect to database
  Db db = Db('mongodb://127.0.0.1:27017/test');
  await db.open();

  print("Connected to database");

  // People Collection
  DbCollection peopleCollection = db.collection('people');

  // Server listening
  server.listen((HttpRequest request) async {
    switch (request.uri.path) {
      case '/':
        request.response.write('Hello, world!');
        await request.response.close();
        break;
      case '/people':
        request.response
          ..write(await peopleCollection.find().toList())
          ..close();

        // Handle GET request
        if (request.method == 'GET') {
          request.response.write(await peopleCollection.find().toList());
        }
        // Handle POST request
        else if (request.method == 'POST') {
          var content = await utf8.decoder.bind(request).join();
          print(content);
          var document = json.decode(content);
          await peopleCollection.insertOne(document);
        }
        // Handle PUT request
        else if (request.method == 'PUT') {
          var id = int.parse(request.uri.queryParameters['id']!);
          var content = await utf8.decoder.bind(request).join();
          var document = json.decode(content);
          var itemToReplace =
              await peopleCollection.findOne(where.eq('id', id));

          if (itemToReplace == null) {
            await peopleCollection.insertOne(document);
          } else {
            await peopleCollection.update(itemToReplace, document);
          }
        }
        // Handle DELETE request
        else if (request.method == 'DELETE') {
          var id = int.parse(request.uri.queryParameters['id']!);
          var itemToDelete = await peopleCollection.findOne(where.eq('id', id));
          await peopleCollection.remove(itemToDelete);
        }
        // Handle PATCH request
        else if (request.method == 'PATCH') {
          var id = int.parse(request.uri.queryParameters['id']!);
          var content = await utf8.decoder.bind(request).join();
          var document = json.decode(content);
          var itemToPatch = await peopleCollection.findOne(where.eq('id', id));
          await peopleCollection.update(itemToPatch, {
            r'$set': document,
          });
        }

        await request.response.close();
        break;
      default:
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found');
    }
  });

  print("Server listening at http://localhost:$port");

  // // Read people collection
  // // ---
  // // var people = await peopleCollection.find().toList();
  // // var people = await peopleCollection.find(where.eq('first_name', 'Calypso')).toList();
  // // var people = await peopleCollection.find(where.match('first_name', 'B')).toList();
  // var people = await peopleCollection.find(where.limit(5)).toList();
  // print("people: $people");

  // var person = await peopleCollection
  //     // .findOne(where.match('first_name', 'B').and(where.gt('id', 40)));
  //     // .findOne(where.match('first_name', 'B').gt('id', 40));
  //     .findOne(where.jsQuery('''
  //     return this.first_name.startsWith('B') && this.id > 40;
  //     '''));
  // print("person: $person");

  // // Create person
  // await peopleCollection.insertOne({
  //   "id": 101,
  //   "first_name": "Jermaine",
  //   "last_name": "Gippes",
  //   "email": "cgippes2r@xinhuanet.com",
  //   "gender": "Female",
  //   "ip_address": "97.252.84.122"
  // });
  // print("insertOne: saved new person");
  // print(await peopleCollection.findOne(where.eq('id', 101)));

  // // Update person
  // await peopleCollection.update(
  //   await peopleCollection.findOne(where.eq('id', 101)),
  //   {
  //     r'$set': {
  //       'gender': 'Male',
  //     }
  //   },
  // );
  // print("update: Updated person");
  // print(await peopleCollection.findOne(where.eq('id', 101)));

  // // Delete person
  // await peopleCollection
  //     .remove(await peopleCollection.findOne(where.eq('id', 101)));
  // print("remove: Deleted person");
  // print(await peopleCollection.findOne(where.eq('id', 101))); // null

  // // Close Database
  // await db.close();
}
