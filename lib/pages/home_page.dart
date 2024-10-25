import 'package:flutter/material.dart';
import 'package:flutter_sqlite/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  @override
  void initState() {
    dbRef = DBHelper.getInstance;
    dbRef!.getAllNotes();
    getNotes();
    super.initState();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();

    ///putting set state so that the ui does not load untill the data get fetched
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (
                _,
                index,
              ) {
                return ListTile(
                  leading: Text("${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}"),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                );
              })
          : Center(
              child: Text("No notes found"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool check = await dbRef!
              .addNote(mTitle: "Personal note", mDesc: "Lorem ipsum");
          if (check) {
            getNotes();
          } else {}
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
