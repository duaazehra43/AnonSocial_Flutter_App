import 'package:anonymous_app/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:anonymous_app/auth/authService.dart';
import 'package:anonymous_app/views/chat_Screen.dart';
import 'package:anonymous_app/views/post_Screen.dart';
import 'package:anonymous_app/views/profile_Screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(
          authService: Provider.of<AuthService>(context, listen: false)),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'AnonSocial',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => viewModel.signOut(context),
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            body: _buildBody(context, viewModel),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: 'Add',
                  ),
                ],
                currentIndex: viewModel.selectedIndex,
                selectedItemColor: Colors.blue[900],
                unselectedItemColor: Colors.blue[900],
                showUnselectedLabels: true,
                onTap: (int index) {
                  viewModel.setIndex(index);
                  if (index == 3) {
                    _showCreatePostDialog(context, viewModel);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    switch (viewModel.selectedIndex) {
      case 1:
        return ProfileScreen();
      case 2:
        return ChatScreen();
      case 0:
      default:
        return PostList();
    }
  }

  void _showCreatePostDialog(BuildContext context, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Create a new post',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: Colors.blue[900]),
          ),
          content: TextField(
            controller: viewModel.postController,
            maxLines: 3,
            decoration: InputDecoration(
                hintText: 'Enter your post content...',
                hintStyle: GoogleFonts.inter()),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.blue[900]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Post',
                style: GoogleFonts.inter(color: Colors.blue[900]),
              ),
              onPressed: () async {
                String postContent = viewModel.postController.text.trim();
                if (postContent.isNotEmpty) {
                  await viewModel.savePostToFirebase(postContent, context);
                  viewModel.postController.clear();
                  Navigator.of(context).pop(); // Close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
}
