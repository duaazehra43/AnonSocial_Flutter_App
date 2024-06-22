import 'package:anonymous_app/auth/authService.dart';
import 'package:anonymous_app/view_model/user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/postModel.dart';
import '../model/userModel.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileViewModel(
        authService: Provider.of<AuthService>(context, listen: false),
        userId: userId,
      ),
      child: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                'Profile',
                style: GoogleFonts.inter(),
              ),
            ),
            body: Column(
              children: [
                _buildUserInfo(context, viewModel),
                _buildUserPosts(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserProfileViewModel viewModel) {
    return StreamBuilder<UserModel>(
      stream: viewModel.getUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: GoogleFonts.inter(),
          ));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        UserModel user = snapshot.data!;
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
              Center(
                child: Text(
                  user.anonymousName,
                  style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserPosts(BuildContext context, UserProfileViewModel viewModel) {
    return Expanded(
      child: StreamBuilder<List<Post>>(
        stream: viewModel.getUserPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No posts yet.',
              style: GoogleFonts.inter(),
            ));
          }
          List<Post> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(context, posts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
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
            Text(
              'Posted at: ${_formatTimestamp(post.timestamp)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Likes: ${post.likes}',
                      style: GoogleFonts.inter(),
                    ),
                  ],
                ),
                if (post.repostedBy != null)
                  Text(
                    'Reposted by: ${post.repostedBy}',
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
    return timestamp.toString(); // Implement date formatting as needed
  }
}
