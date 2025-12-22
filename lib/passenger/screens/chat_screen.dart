import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in.")));
      return;
    }

    setState(() => _isSending = true);

    try {
      // 1. Insert Message
      await supabase.from('support_messages').insert({
        'user_id': user.id,
        'message': text,
        'is_admin_reply': false, // This is a user message
      });

      // 2. Clear input ONLY on success
      if (mounted) {
        _msgCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error sending: $e"), 
          backgroundColor: Colors.red
        ));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    
    // Safety check: if user isn't logged in, don't try to load chat
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Support")),
        body: const Center(child: Text("Please log in to chat.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Chat"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // MESSAGES AREA
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Listen specifically to MY messages
              stream: supabase
                  .from('support_messages')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', user.id) 
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading chat: ${snapshot.error}"));
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("No messages yet.", style: TextStyle(color: Colors.grey)),
                        const Text("Say 'Hi' to start!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isAdmin = msg['is_admin_reply'] as bool? ?? false;
                    return _buildMessageBubble(msg['message'], !isAdmin);
                  },
                );
              },
            ),
          ),

          // INPUT AREA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: _isSending
                      ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? Colors.black87: Colors.white),
        ),
      ),
    );
  }
}