import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_v3/firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  //text controller
  final TextEditingController textController = TextEditingController();
  final FirestoreService firestoreservice = FirestoreService();
  //open dialog box to add a note
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey,
        content: TextField(
          controller: textController,
        ),
        actions: [
          //button to save
          ElevatedButton(
              onPressed: () {
                //add a new note
                if (docID == null) {
                  firestoreservice.addNote(textController.text);
                  //update the note
                } else {
                  firestoreservice.updateNote(docID, textController.text);
                }

                //clear
                textController.clear();
                //close the box
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: const Text(
          "N O T E S",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Colors.black,
        hoverColor: Colors.grey,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreservice.getNotesStream(),
        builder: (context, snapshot) {
          //if we have data, get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data["note"];
                Timestamp timestamp = data["timestamp"] as Timestamp;
                DateTime date = timestamp.toDate();

                //display as a list tile
                return Column(
                  children: [
                    Row(
                      //timestamp
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.55,
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.03,
                          ),
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.06,
                              left: MediaQuery.of(context).size.width * 0.05,
                              bottom: MediaQuery.of(context).size.height * 0.01,
                              right: MediaQuery.of(context).size.width * 0.025),
                          child: Text(date.toString()),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        //update
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.15,
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.03,
                          ),
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.06,
                              bottom: MediaQuery.of(context).size.height * 0.01,
                              right: MediaQuery.of(context).size.width * 0.025),
                          child: IconButton(
                              padding: EdgeInsets.only(bottom: 1),
                              onPressed: () => openNoteBox(docID: docID),
                              icon: Icon(Icons.edit)),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        //delete
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.15,
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.03,
                          ),
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.06,
                              bottom: MediaQuery.of(context).size.height * 0.01,
                              right: MediaQuery.of(context).size.width * 0.025),
                          child: IconButton(
                              padding: EdgeInsets.only(bottom: 1),
                              onPressed: () =>
                                  firestoreservice.deleteNote(docID),
                              icon: Icon(Icons.delete)),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03,
                      ),
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: Text(noteText),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    Container(
                      height: 1,
                      color: Colors.black,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.06),
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                );
              },
            );
          } else {
            return const Text("No note...");
          }
        },
      ),
    );
  }
}
