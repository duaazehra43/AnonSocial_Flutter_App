import 'package:anonymous_app/view_model/post_view_model.dart';
import 'package:anonymous_app/views/user_profile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/authService.dart';
import '../model/postModel.dart';

class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostListViewModel(
          authService: Provider.of<AuthService>(context, listen: false)),
      child: Consumer<PostListViewModel>(
        builder: (context, viewModel, child) {
          return StreamBuilder<List<Post>>(
            stream: viewModel.getPostsStream(),
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

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToUserProfile(context, posts[index].userId);
                    },
                    child: _buildPostCard(context, posts[index], viewModel),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostCard(
      BuildContext context, Post post, PostListViewModel viewModel) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 8.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content, style: GoogleFonts.inter(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Posted by: ${post.originalAnonymousName ?? post.anonymousName}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            if (post.repostedBy != null)
              Text(
                'Reposted by: ${post.repostedBy}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
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
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () => viewModel.likePost(post.id),
                    ),
                    Text('${post.likes}'),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.repeat),
                  onPressed: () => viewModel.repostPost(post),
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

  void _navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }
}
