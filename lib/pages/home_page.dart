import 'package:flutter/material.dart';
import 'package:flutter_sqlite/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    dbRef = DBHelper.getInstance;
    getNotes();
    super.initState();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {}); // Update the UI after data is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anirban Note App"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          "${index+1}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                      subtitle:
                          Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () async {
                              titleController.text =
                                  allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                              descriptionController.text =
                                  allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return getBottomSheetWiget(
                                      isUpdate: true,
                                      sno: allNotes[index]
                                          [DBHelper.COLUMN_NOTE_SNO]);
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final int noteID =
                                  allNotes[index][DBHelper.COLUMN_NOTE_SNO];
                              int check = await dbRef!.removeNotes(noteID);

                              if (check > 0) {
                                getNotes();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Note deleted")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text("No notes found"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              titleController.clear();
              descriptionController.clear();
              return getBottomSheetWiget();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWiget({bool isUpdate = false, int sno = 0}) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUpdate ? "Update Note" : "Add Note",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter title here",
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter description here",
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // final int sno = allNotes[index][DBHelper.COLUMN_NOTE_SNO];
                  var title = titleController.text;
                  var desc = descriptionController.text;
                  if (title.isNotEmpty && desc.isNotEmpty) {
                    bool check = isUpdate
                        ? await dbRef!.updateNotes(
                            // Correct parameter
                            mTitle: title, // Named parameter
                            mDesc: desc,
                            sno: sno // Named parameter

                            )
                        : await dbRef!.addNote(
                            // Correct parameter
                            mTitle: title, // Named parameter
                            mDesc: desc,
                            // Named parameter
                          );

                    if (check) {
                      getNotes();
                      Navigator.pop(context); // Close the bottom sheet

                      isUpdate
                          ? ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Note Updated")),
                            )
                          : ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Note Added")));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Not")));
                    }
                  }
                },
                child: Text(isUpdate ? "Update Note" : "Add Note"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
