import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datn/database/firestore/firestore_service.dart';
import 'package:datn/database/storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:datn/model/user.dart' as model_user;
import '../../database/auth/firebase_auth_service.dart';

List<String> genders = ['Nam', 'Nữ', 'Khác'];

class UpdateInfoScreen extends StatefulWidget {
  const UpdateInfoScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UpdateInfoScreenState();
  }
}

class _UpdateInfoScreenState extends State<UpdateInfoScreen> {
  String dropDownGender = genders.first;
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isEdit = false;
  FirebaseAuthService authService = FirebaseAuthService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirestoreService firestoreService = FirestoreService();
  FirebaseStorageService firebaseStorageService = FirebaseStorageService();
  FirebaseAuth auth = FirebaseAuth.instance;
  ImagePicker imagePicker = ImagePicker();
  XFile? returnImage;
  File? selectedImage;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dateController.dispose();
    phoneController.dispose();
  }

  Future initInfo() async {
    final userDoc = firestore.collection('users').doc(auth.currentUser!.uid);
    userDoc.get().then(
      (DocumentSnapshot snapshot) {
        if (snapshot.data() == null) {
          print('is null');
        } else {
          final data = snapshot.data() as Map<String, dynamic>;

          String? displayName = data['display_name'] as String?;
          nameController.text = displayName ?? '';

          print('display name $displayName');

          String? phoneNumber = data['phone'] as String?;
          phoneController.text = phoneNumber ?? '';

          String? dateOfBirth = data['born'] as String?;
          dateController.text = dateOfBirth ?? '';

          String? gender = data['gender'] as String?;
          dropDownGender = gender ?? genders.first;
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future uploadImage() async {
    FirebaseStorage storage = firebaseStorageService.storage;

    Reference folderReference =
        storage.ref('user_images/${auth.currentUser!.uid}/avatar/');

    //upload new image
    returnImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (returnImage != null) {
      selectedImage = File(returnImage!.path);
      print('return image path $returnImage');
      print('selectedImage $selectedImage');

      try {
        Reference imageRef = folderReference.child(returnImage!.name);
        print('imageRef $imageRef');
      await  imageRef.putFile(selectedImage!);
        String imageUrl = await imageRef.getDownloadURL();
        print('Image URL ' + imageUrl);
        firestoreService.updateImageUrl(auth.currentUser!.uid, imageUrl);
        //store imageUrl to firestore
      } catch (error) {
        print(error);
      }
    }
  }

  Future update() async {
    print(phoneController.text);
    print('dropdown gender $dropDownGender');
    firestoreService.updateInfo(auth.currentUser!.uid, nameController.text,
        phoneController.text, dateController.text, dropDownGender);
  }

  @override
  Widget build(BuildContext context) {
    // initInfo();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Thông tin chung'),
      ),
      body: Builder(
        builder: (BuildContext context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: uploadImage,
                  child:
                      // Text('ok')

                      StreamBuilder<model_user.User>(
                          stream: firestoreService.user(auth.currentUser!.uid),
                          builder: (context,
                              AsyncSnapshot<model_user.User> snapshot) {
                            model_user.User? user = snapshot.data;
                            if (user != null) {
                              return CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoUrl),
                                  radius: 50);
                            } else {
                              return CircleAvatar(
                                backgroundImage: AssetImage('assets/bear.jpg'),
                                radius: 50,
                              );
                            }
                          }),

                  // (selectedImage != null)
                  //     ? CircleAvatar(
                  //         backgroundImage: FileImage(selectedImage!), radius: 50)
                  //     : CircleAvatar(
                  //         backgroundImage: AssetImage('assets/bear.jpg'),
                  //         radius: 50,
                  //       ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEdit = !isEdit;
                          print(isEdit);
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Sửaa')),
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        readOnly: !isEdit,
                        keyboardType: TextInputType.name,
                        controller: nameController,
                        obscureText: false,
                        decoration: InputDecoration(
                          filled: isEdit,
                          border: const OutlineInputBorder(),
                          labelText: 'Họ và tên',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        readOnly: !isEdit,
                        validator: (String? phoneNumber) {
                          if (phoneNumber == null || phoneNumber.isEmpty) {
                            return null;
                          } else {
                            // You may need to change this pattern to fit your requirement.
                            // I just copied the pattern from here: https://regexr.com/3c53v
                            const pattern =
                                r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
                            final regExp = RegExp(pattern);

                            if (!regExp.hasMatch(phoneNumber)) {
                              return 'Không đúng định dạng';
                            }
                            return null;
                          }
                        },
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        obscureText: false,
                        decoration: InputDecoration(
                          filled: isEdit,
                          border: const OutlineInputBorder(),
                          labelText: 'Số điện thoại',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        initialValue: auth.currentUser?.email,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Địa chỉ email',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Giới tính'),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownMenu<String>(
                        enabled: isEdit,
                        initialSelection: dropDownGender,
                        onSelected: (String? gender) {
                          setState(() {
                            dropDownGender = gender!;
                            print('set state drop down gender $dropDownGender');
                          });
                        },
                        dropdownMenuEntries: genders
                            .map((value) => DropdownMenuEntry<String>(
                                value: value, label: value))
                            .toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                          // validator: validateEmail,
                          controller: dateController,
                          readOnly: true,
                          keyboardType: TextInputType.datetime,
                          obscureText: false,
                          decoration: InputDecoration(
                            filled: isEdit,
                            border: const OutlineInputBorder(),
                            labelText: 'Năm sinh',
                          ),
                          onTap: !isEdit
                              ? null
                              : () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now());
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    setState(() {
                                      dateController.text = formattedDate;
                                    });
                                  }
                                }),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.background)),
                        onPressed: isEdit ? update : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            'Cập nhật',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
