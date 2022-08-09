import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './editPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List places = [];

  void fetchPlaces() async {
    await FirebaseFirestore.instance
        .collection('places')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          places.add(doc);
        });
      });
    });
  }

  initState() {
    fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "IDUBAI ADMIN PANEL",
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
            children: [
              GestureDetector(
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color.fromARGB(255, 113, 180, 231)),
                    child: Center(
                      child: Text(
                        "Create New Location",
                        style: TextStyle(
                          fontFamily: 'Varela Round',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(
                            name: "",
                            address: "",
                            description: "",
                            displayMain: false,
                            pictures: [],
                            placeID: "",
                            numBookmark: 0,
                            state: "Create"),
                      ),
                    );
                  }),
              SizedBox(height: 30),
              Container(
                height: MediaQuery.of(context).size.height - 80,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: places.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          child: Text(
                                            places[index]['name'],
                                            style: TextStyle(
                                              fontFamily: "Varela Round",
                                              fontSize: 14,
                                            ),
                                            // textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_pin,
                                                size: 15,
                                              ),
                                              Text(
                                                places[index]['address'],
                                                style: TextStyle(
                                                  fontFamily: "Varela Round",
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                                // textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          places[index]["pictures"][0]),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPage(
                                name: places[index]["name"],
                                address: places[index]['address'],
                                description: places[index]['description'],
                                displayMain: places[index]['displayMain'],
                                pictures: places[index]['pictures'],
                                placeID: places[index].id,
                                numBookmark: places[index]['numBookmark'],
                                state: "Edit",
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
