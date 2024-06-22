import 'package:anonymous_app/model/postModel.dart';
import 'package:anonymous_app/view_model/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/authService.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (context) => ProfileViewModel(authService: authService),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ProfileContent(),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final String userId = profileViewModel.authService.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          radius: 60,
          child: Icon(Icons.person, size: 60),
        ),
        SizedBox(height: 20),
        FutureBuilder<String>(
          future: profileViewModel.getAnonymousName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String anonymousName = snapshot.data!;
              return Text(
                '$anonymousName',
                style: GoogleFonts.inter(fontSize: 20),
              );
            }
          },
        ),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: _buildUserPostsList(userId),
          ),
        ),
      ],
    );
  }

  Widget _buildUserPostsList(String userId) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, child) {
        return StreamBuilder<List<Post>>(
          stream: profileViewModel.getUserPostsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Post> posts = snapshot.data ?? [];

            if (posts.isEmpty) {
              return Center(
                child: Text(
                  'No posts found.',
                  style: GoogleFonts.inter(),
                ),
              );
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(context, posts[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted at: ${_formatTimestamp(post.timestamp)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  'Likes: ${post.likes}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    // Implement custom date formatting if needed
    return timestamp.toString(); // Example formatting
  }
}
