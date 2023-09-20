import '/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').orderBy('created_at', descending: true).snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) return const Center(child: Text('No messages found'));
        if (chatSnapshot.hasError) return const Center(child: Text('Something went wrong...'));

        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length ? loadedMessages[index + 1].data() : null;
            final currentMessageUserID = chatMessage['user_id'];
            final nextMessageUserID = nextChatMessage != null ? nextChatMessage['user_id'] : null;
            final nextUserIsSame = nextMessageUserID == currentMessageUserID;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserID,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['user_image'],
                userName: chatMessage['user_name'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserID,
              );
            }
          },
        );
      },
    );
  }
}
