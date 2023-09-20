import 'dart:io';

import '/widgets/user_image_picker_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  bool _isLogin = true;

  final _formKey = GlobalKey<FormState>();
  final _firebaseAuth = FirebaseAuth.instance;

  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUserName = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) return;

    _formKey.currentState!.save();

    try {
      setState(() => _isAuthenticating = true);
      if (_isLogin) {
        await _firebaseAuth.signInWithEmailAndPassword(email: _enteredEmail.trim(), password: _enteredPassword.trim());
      } else {
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: _enteredEmail.trim(), password: _enteredPassword.trim());
        final storageRef = FirebaseStorage.instance.ref('user_image').child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final downloadURL = await storageRef.getDownloadURL();
        // print(downloadURL);

        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': _enteredUserName,
          'email': _enteredEmail.trim(),
          'image_url': downloadURL,
        });
        // create a new document in a collection called user
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == '') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication failed')));
    }
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin) UserImagePickerWidget(onImageSelected: (pickedImage) => _selectedImage = pickedImage),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'User Name'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
                              validator: (value) => (value == null || value.trim().isEmpty || value.trim().length < 4) ? 'Please enter a valid user name of 4 characters' : null,
                              onSaved: (newValue) => _enteredUserName = newValue!,
                            ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            enableSuggestions: false,
                            validator: (value) => (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@') ||
                                    !value.contains(
                                      '.',
                                    ))
                                ? 'Please enter a valid email address'
                                : null,
                            onSaved: (newValue) => _enteredEmail = newValue!,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Password'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            enableSuggestions: false,
                            validator: (value) => (value == null || value.trim().length < 6) ? 'Password must be atleast 6 characters long' : null,
                            onSaved: (newValue) => _enteredPassword = newValue!,
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating) const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(_isLogin ? 'Login' : 'Sign up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin ? 'Create an account' : 'Login with an existing account'))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
