import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class EditPage extends StatefulWidget {
  String address;
  String description;
  bool displayMain;
  String name;
  List pictures;
  String placeID;
  String state;
  int numBookmark;

  EditPage({
    required this.address,
    required this.description,
    required this.displayMain,
    required this.name,
    required this.pictures,
    required this.placeID,
    required this.state,
    required this.numBookmark,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController addressCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  String displayMainCont = "false";
  TextEditingController nameCont = TextEditingController();
  List<TextEditingController> picturesCont = [
    for (int i = 0; i < 5; i++) TextEditingController()
  ];
  List<TextEditingController> tagCont = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];
  List _tags = [];
  List allTags = [];
  List allTagsName = [];
  List allTagsID = [];
  List randColours = [
    "0xfffaa69",
    "0xfffff59a",
    "0xfff59bad",
    "0xfdf9e1",
    "0xff9796f2",
    "0xffb3f7f8",
    "0xffff8469",
    "0xffe2b3f8",
    "0xfffffff7",
    "0xffc62fff"
  ];

  void fetchTags() async {
    await FirebaseFirestore.instance
        .collection('tags')
        .where('placesID', arrayContainsAny: [widget.placeID])
        .get()
        .then(
          (QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach(
              (doc) {
                setState(() {
                  _tags.add(doc.id);
                });
                for (int i = 0; i < _tags.length; i++) {
                  setState(
                    () {
                      tagCont[i].text = _tags[i];
                    },
                  );
                }
              },
            );
          },
        );
  }

  fetchAllTags() async {
    await FirebaseFirestore.instance.collection('tags').get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            setState(() {
              allTags.add(doc);
              allTagsID.add(doc['placesID']);
              allTagsName.add(doc.id);
            });
          },
        );
      },
    );
  }

  @override
  initState() {
    setState(() {
      addressCont.text = widget.address;
      descriptionCont.text = widget.description;
      nameCont.text = widget.name;
      displayMainCont = (widget.displayMain.toString());
      for (int i = 0; i < widget.pictures.length; i++) {
        picturesCont[i].text = widget.pictures[i];
      }
    });
    fetchTags();
    fetchAllTags();
  }

  savePlace() async {
    DateTime now = DateTime.now();
    widget.placeID = nameCont.text;
    List pictures = [];
    for (int i = 0; i < picturesCont.length; i++) {
      if (!(picturesCont[i].text == "" || picturesCont[i].text == null)) {
        pictures.add(picturesCont[i].text);
      }
    }
    await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeID)
        .set({
      'name': nameCont.text,
      'address': addressCont.text,
      'description': descriptionCont.text,
      'pictures': pictures,
      'displayMain': displayMainCont == "true" ? true : false,
      'numBookmark': widget.numBookmark,
      'addTime': now,
    });
    Random random = new Random();
    for (int i = 0; i < tagCont.length; i++) {
      int randNum = random.nextInt(9);
      if (!(tagCont[i].text == "" || tagCont[i].text == null)) {
        if (allTagsName.contains(tagCont[i].text)) {
          List ids = [];
          await FirebaseFirestore.instance
              .collection('tags')
              .doc(tagCont[i].text)
              .get()
              .then((doc) {
            ids = doc['placesID'];
          });
          if (!ids.contains(widget.placeID)) {
            ids.add(widget.placeID);
            await FirebaseFirestore.instance
                .collection('tags')
                .doc(tagCont[i].text)
                .set({'color': randColours[randNum], 'placesID': ids});
          }
        } else {
          await FirebaseFirestore.instance
              .collection('tags')
              .doc(tagCont[i].text)
              .set({
            'color': randColours[randNum],
            'placesID': [widget.placeID]
          });
        }
      }
    }
    Navigator.popAndPushNamed(context, '/');
  }

  deletePlace() async {
    await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeID)
        .delete();
    for (int i = 0; i < _tags.length; i++) {
      for (int j = 0; j < allTags.length; j++) {
        if (_tags[i] == allTags[j].id) {
          allTagsID[j].remove(widget.placeID);
          await FirebaseFirestore.instance
              .collection('tags')
              .doc(_tags[i])
              .set({
            'color': allTags[j]['color'],
            'placesID': allTagsID[j],
          });
        }
      }
    }
    Navigator.popAndPushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.state + " " + widget.name,
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Name",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                controller: nameCont,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 113, 180, 231),
                    ),
                  ),
                  hintText: "Name of Place",
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Address",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                controller: addressCont,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 113, 180, 231),
                    ),
                  ),
                  hintText: "Address of Place",
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Description",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                controller: descriptionCont,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 113, 180, 231),
                    ),
                  ),
                  hintText: "Description of Place",
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Pictures",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: picturesCont.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextFormField(
                      controller: picturesCont[index],
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 113, 180, 231),
                          ),
                        ),
                        hintText: "Link of Picture " + (index + 1).toString(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Tags",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: tagCont.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextFormField(
                      controller: tagCont[index],
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 113, 180, 231),
                          ),
                        ),
                        hintText: "Tag Name " + (index + 1).toString(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Main Display?",
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              DropdownButton<String>(
                alignment: AlignmentDirectional.centerStart,
                value: displayMainCont.toString(),
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 113, 180, 231),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    displayMainCont = newValue!;
                  });
                },
                items: <String>['true', 'false']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Container(
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(100, 96, 193, 200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        minimumSize: Size(170, 50), //////// HERE
                        textStyle: const TextStyle(
                            fontSize: 14, fontFamily: "Varela Round"),
                      ),
                      onPressed: () {
                        savePlace();
                      },
                      child: Row(children: [const Text('Save Changes')]),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        minimumSize: Size(170, 50), //////// HERE
                        textStyle: const TextStyle(
                            fontSize: 14, fontFamily: "Varela Round"),
                        primary: Color.fromARGB(0xff, 0x2E, 0x92, 0xD0),
                      ),
                      onPressed: () {
                        deletePlace();
                      },
                      child: Row(
                        children: [
                          const Text('Delete Places'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
