import 'package:citizen_report_solution/screens/incident_posted_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/main_drawer.dart';

class AddIncidentScreen extends StatefulWidget {
  @override
  _AddIncidentScreenState createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final TextEditingController _incidentTitleController =
      TextEditingController();
  final TextEditingController _incidentDescriptionController =
      TextEditingController();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Report an Incident',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 3, 53, 41),
          actions: [
            DropdownButton(
              icon: const Icon(
                Icons.more_vert,
              ),
              items: [
                DropdownMenuItem(
                  value: 'logout',
                  child: Container(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (itemIdentifier) {
                FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _incidentTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Incident Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Incident Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _incidentDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter incident description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _postIncidentToFirestore();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 3, 53, 41), // Button color
                      ),
                      child: const Text(
                        'Report an incident',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        File? selectedImage = await _pickImage();
                        if (selectedImage != null) {
                          setState(
                            () {
                              imageFile = selectedImage;
                            },
                          );
                        }
                      },
                      child: const Text('Pick an Image'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(IncidentPostedPage.routeName);
                    },
                    child: const Text('View Posted Incidents'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  void _postIncidentToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String uid = user.uid;
    String? imageUrl = await _uploadImage(imageFile, uid);

    CollectionReference incidentCollection =
        FirebaseFirestore.instance.collection('incidentsposted');

    Map<String, dynamic> incidentData = {
      'incidentTitle': _incidentTitleController.text,
      'incidentDescription': _incidentDescriptionController.text,
      'postedBy': uid,
      'imageUrl': imageUrl,
      'postedDate': DateTime.now().toLocal().toString(),
    };

    try {
      await incidentCollection.add(incidentData);

      _showSuccessMessage(context);

      _clearTextFields();
    } catch (e) {
      print('Error reporting incident: $e');
    }
  }

  Future<String?> _uploadImage(File? imageFile, String uid) async {
    if (imageFile == null) {
      return null;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('incident_images/$uid/$imageName.jpg');

    UploadTask uploadTask = storageReference.putFile(imageFile);

    try {
      await uploadTask;
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Incident posted successfully!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearTextFields() {
    _incidentTitleController.clear();
    _incidentDescriptionController.clear();
  }
}
