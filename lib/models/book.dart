import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String bookName;
  String authorName;

  DocumentReference documentReference;

  //constructor

  Book({this.bookName, this.authorName});

  //map
  Book.fromMap(Map<String, dynamic> map, {this.documentReference}){
    bookName = map["bookName"];
    authorName = map["authorName"];
  }

  Book.fromSnapshot(DocumentSnapshot snapshot)
  : this.fromMap(snapshot.data, documentReference: snapshot.reference);

  toJson() {
    return {'bookName':bookName, 'authorName':authorName};
  }
}