import 'package:anonymous_app/views/chat_Detail.dart';
import 'package:anonymous_app/view_model/chat_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatViewModel>(
      create: (context) => ChatViewModel(),
      child: Scaffold(
        body: ChatScreenContent(),
      ),
    );
  }
}

class ChatScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    chatViewModel.getUsers(); // Fetch users when the screen builds

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ChatViewModel>(
        builder: (context, model, child) {
          if (model.usersCount == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: model.usersCount,
            itemBuilder: (context, index) {
              final user = model.getUser(index);
              if (user.id == model.currentUserId) {
                return SizedBox.shrink(); // Skip the logged-in user
              }
              return Card(
                color: Colors.white,
                shadowColor: Colors.blue[100],
                elevation: 8.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    child: Text(
                      user.anonymousName[0],
                      style: GoogleFonts.inter(),
                    ),
                  ),
                  title: Text(
                    user.anonymousName,
                    style: GoogleFonts.inter(),
                  ),
                  trailing: Icon(Icons.chat),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          recipientId: user.id,
                          recipientName: user.anonymousName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
