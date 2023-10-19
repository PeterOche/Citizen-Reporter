import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/main_drawer.dart';

class IncidentPostedPage extends StatefulWidget {
  static const routeName = '/incident-posted-page';

  @override
  _IncidentPostedState createState() => _IncidentPostedState();
}

class _IncidentPostedState extends State<IncidentPostedPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.amber,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reported Incidents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 53, 41),
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder<User?>(
        future: _auth.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final currentUser = snapshot.data;

            if (currentUser != null) {
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('incidentsposted')
                    .where('postedBy', isEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reported incidents found.',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final document = snapshot.data!.docs[index];
                        final incidentTitle = document['incidentTitle'];
                        final incidentDescription =
                            document['incidentDescription'];
                        final postedDate = document['postedDate'];
                        final imageUrl = document['imageUrl'];

                        return Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 169, 215, 213),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              if (imageUrl != null)
                                Image.network(imageUrl) // Display the image
                              else
                                const SizedBox(), // If no image URL is available, display nothing
                              ListTile(
                                title: Text(
                                  incidentTitle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Posted Date: $postedDate',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 210, 78, 11),
                                  ),
                                ),
                              ),
                              Card(
                                child: Text(incidentDescription),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              );
            } else {
              // Handle the case where currentUser is null (e.g., show a login screen)
              return const Center(
                child: Text('Please log in.'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: IncidentPostedPage(),
  ));
}
