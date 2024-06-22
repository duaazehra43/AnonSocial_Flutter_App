import 'package:flutter/material.dart';
import 'package:anonymous_app/auth/authService.dart';
import '../model/postModel.dart';

class PostListViewModel extends ChangeNotifier {
  final AuthService authService;

  PostListViewModel({required this.authService});

  Stream<List<Post>> getPostsStream() {
    return authService.getPostsStream();
  }

  Future<void> likePost(String postId) async {
    await authService.likePost(postId);
  }

  Future<void> repostPost(Post post) async {
    await authService.repostPost(post);
  }
}
