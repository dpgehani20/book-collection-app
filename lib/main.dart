import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './models/book.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'test',
      home: BookfirebaseDemo(),
    );
  }
}

class BookfirebaseDemo extends StatefulWidget {

  BookfirebaseDemo() : super();

  final String appTitle = 'BOOK Db';
  @override
  _BookfirebaseDemoState createState() => _BookfirebaseDemoState();
}

class _BookfirebaseDemoState extends State<BookfirebaseDemo> {

  TextEditingController bookNameController = TextEditingController();
  TextEditingController authorNameController = TextEditingController();

  bool isEditing = false;
  bool textFeildVisibility = false;

  String firestoreCollectionName ="Books";

  Book currentBook;

  getAllBooks() {
    return Firestore.instance.collection(firestoreCollectionName).snapshots();
  }

  addBook() async {
    Book book = Book(bookName: bookNameController.text, authorName: authorNameController.text);

    try{
      Firestore.instance.runTransaction(
        (Transaction transaction) async {
          await Firestore.instance
          .collection(firestoreCollectionName)
          .document()
          .setData(book.toJson());
        }
      );
    }
    catch(e) {
      print(e.toString());
    }
  }

  updateBook(Book book, String bookName, String authorName) {

    try{
      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(book.documentReference, {'bookName': bookName, 'authorName':authorName});
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  updateifEditing() {
    if(isEditing){
      //update
      updateBook(currentBook, bookNameController.text, authorNameController.text);

      setState(() {
        isEditing=false;
      });
    }
  }

  deleteBook(Book book) {
    Firestore.instance.runTransaction(
      (Transaction transaction) async {
        await transaction.delete(book.documentReference);
      }
      );
  }



  Widget buildBody(BuildContext context){

    return StreamBuilder<QuerySnapshot>(
      stream :getAllBooks(),
      builder:(context, snapshot) {
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}');
        }
        if(snapshot.hasData){
          print("Document -> ${snapshot.data.documents.length}");
          return buildList(context,snapshot.data.documents);
        }
      }
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot) {

    return ListView(
      children: snapshot.map((data) => listItemBuild(context,data)).toList(),
    );

  }

  Widget listItemBuild(BuildContext context, DocumentSnapshot data) {

    final book = Book.fromSnapshot(data);

    return Padding(
      key: ValueKey(book.bookName),
      padding: EdgeInsets.symmetric(vertical: 19.0, horizontal: 1.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          child: ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color:Colors.yellow),
                    Text(book.bookName),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Icon(Icons.person, color:Colors.blue),
                    Text(book.authorName),
                  ],
                ),
              ]
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color:Colors.red),
              onPressed: () {
                deleteBook(book);
              }
              ),
              onTap: () {
                setUpdateUI(book);
              },
          ),
        ),
      ),
    );

  }

  setUpdateUI(Book book) {
    bookNameController.text=book.bookName;
    authorNameController.text =book.authorName;

    setState(() {
      textFeildVisibility = true;
      isEditing = true;
      currentBook = book;
    });

  }

  button() {
    return SizedBox(
      width:double.infinity,
      child: OutlineButton(
        child: Text(isEditing ? 'UPDATE' : 'ADD'),
        onPressed: () {
          if(isEditing == true){
            updateifEditing();
          }
          else{
            addBook();
          }

          setState(() {
            textFeildVisibility = false;
          });
        },
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,

      appBar: AppBar(
        title: Text(widget.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                textFeildVisibility = !textFeildVisibility;
              });
            },
          ),
        ],
        ),
        body: Container(
          padding: EdgeInsets.all(19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textFeildVisibility
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      TextFormField(
                        controller: bookNameController,
                        decoration: InputDecoration(
                          labelText: "book name",
                        ),
                      ),
                      TextFormField(
                    controller: authorNameController,
                    decoration: InputDecoration(
                      labelText: "author name",
                    ),
                  ),
                  ],
                  ),
                  SizedBox(height: 10.0),
              button(),
                ],
              ) : Container(),
              SizedBox(height: 20.0),

              Text('Books',
              style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Flexible(child: buildBody(context),)
            ],
          ),

        ),
    );
  }
}