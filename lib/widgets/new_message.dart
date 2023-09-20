import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.clear();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();

    FocusScope.of(context).unfocus();
    _messageController.clear();

    if (enteredMessage.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    //retriving data from firestore

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'created_at': Timestamp.now(),
      'user_id': user.uid,
      'user_name': userData.data()!['username'],
      'user_image': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              textInputAction: TextInputAction.send,
              onSubmitted: (c) => _submitMessage(),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
