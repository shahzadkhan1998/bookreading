// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as Path;

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

// ignore: unused_element
File? image;
File? file;
// ignore: prefer_typing_uninitialized_variables
var imageUrl;
var fileUrl;

// ignore: non_constant_identifier_names
AddRData() {
  final db = FirebaseDatabase.instance.reference().child("user");
  db.push().set({
    'name': 'Shahzad',
    'age': '20',
    'email': 'sk@gmail.com',
    'password': '123456',
  });
}

ReadData() {
  //////////////////>>>>>>>>>>>>      First Method/////////////////////
  final db = FirebaseDatabase.instance.reference().child("user");
  db.once().then((DataSnapshot snapshot) {
    print(snapshot.value);
  });
  // / //////////////////////////////////////////////////////////////  Second Method
  return FirebaseAnimatedList(
    query: FirebaseDatabase.instance.reference().child("user"),
    itemBuilder: (BuildContext context, DataSnapshot snapshot,
        Animation<double> animation, int index) {
      return Column(
        children: <Widget>[
          ListTile(
            title: Text(snapshot.value['name']),
            subtitle: Text(snapshot.value['age']),
            leading: const Icon(Icons.account_circle),
          ),
        ],
      );
    },
  );
  ///////////////////////  Third method //////////////////
  return FutureBuilder(
      future: FirebaseDatabase.instance.reference().child("user").once(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ListView.builder(
          itemCount: snapshot.data.value.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                snapshot.data.value[index]['name'],
              ),
            );
          },
        );
      });
}

uploadProfileImage() async {
  Reference reference = FirebaseStorage.instance
      .ref()
      .child('Image/${Path.basename(image!.path)}');
  UploadTask uploadTask = reference.putFile(image!);
  TaskSnapshot snapshot = await uploadTask;
  imageUrl = await snapshot.ref.getDownloadURL();
  print("Image Upladed succesfully $imageUrl");
}

uploadfile() async {
  Reference reference =
      FirebaseStorage.instance.ref().child('file/${Path.basename(file!.path)}');
  UploadTask uploadTask = reference.putFile(file!);
  TaskSnapshot snapshot = await uploadTask;
  fileUrl = await snapshot.ref.getDownloadURL();
  print("FIle Upladed succesfully $file");
}

//////////////////////////// upload the data to server//////////////////////

///

class _PostState extends State<Post> {
///////////////// get image from gallery ////////////////////////////////////////////
  final databaseReference = FirebaseFirestore.instance;
  postImage() async {
    ImagePicker picker = ImagePicker();

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        print("Image   $image");
        MotionToast.info(
                title: Text("Image"),
                description: Text("Image select Successfully"))
            .show(context);
      });
    } else {
      print('No image selected.');
      MotionToast.info(
              title: Text("image"), description: Text("No image selected"))
          .show(context);
      return;
    }
    uploadProfileImage();
  }

  postfiles() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result!.files.single.path;
    // ignore: avoid_print
    print(path);
    MotionToast.info(
            title: Text("File"),
            description: Text("File select Successfully $file"))
        .show(context);

    setState(() {
      file = File(path!);
      // ignore: avoid_print
      print(path);
      MotionToast.info(
              title: Text("File"),
              description: Text("File select Successfully $file"))
          .show(context);
    });
    uploadfile();
  }

  //////////////////// upload All data to server /////////////////////////////////

  postData() async {
    DocumentReference ref = await databaseReference.collection("book").add({
      'Name': controllerName.text,
      'Description': controllerDescription.text,
      'Image': imageUrl,
      'Read': fileUrl,
    });
    // ignore: unnecessary_null_comparison
    if (ref.id != null) {
      print("Data Uploaded Successfully");
      MotionToast.success(
              title: Text("Data"),
              description: Text("Data Uploaded Successfully"))
          .show(context);
    }
  }

  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'upload Book',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),

              const Text(
                'Upload book picture & Book must be a PDF Form '
                '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const Text(
                'First select picture and File',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(
                height: 40,
              ),
              //////////////////////////  TextField  //////////////////////////
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  controller: controllerName,
                  decoration: InputDecoration(
                    hintText: 'Enter Book Name',
                    labelText: 'Book Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              /////////////////////// TextField ////////////////////////////////////////////

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  controller: controllerDescription,
                  decoration: InputDecoration(
                    hintText: 'Enter Book Description',
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              //////////////////////// Button //////////////////////////////////
              const SizedBox(
                height: 20,
              ),
              //////////////////////// Button //////////////////////////////////

              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                height: MediaQuery.of(context).size.height * 0.20,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: () {
                            postImage();
                          },
                          child: Text('Select Image'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: () {
                            postfiles();
                          },
                          child: Text('Select File'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: () {
                            postData();
                          },
                          child: Text('Upload'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              // ignore: deprecated_member_use
              // FlatButton(
              //   color: Colors.green,
              //   onPressed: () {
              //     AddRData();
              //   },
              //   child: const Text("RealTime Data Add"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
