import 'package:flutter/material.dart';

import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, required this.currentUserId, required this.conversation,required this.onTap});
  final Conversation conversation;
  final String currentUserId;
  final void Function()? onTap;


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
