import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/services/chat_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService();
  String _currentUserId = "vecino_demo_123";
  String _currentUserName = "Vecino";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('user_id') ?? "vecino_demo_123";
      _currentUserName = prefs.getString('user_name') ?? "Vecino";
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    _chatService.sendMessage(
      emisorId: _currentUserId,
      emisorNombre: _currentUserName,
      mensaje: _messageController.text.trim(),
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text("CHAT VECINAL"),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner Superior de Alerta Urgente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.alertRed.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.alertRed.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "ALERTA VECINAL ACTIVA",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
                ),
              ],
            ),
          ),

          // Listado de Mensajes con fondo oscuro
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                image: DecorationImage(
                  image: const NetworkImage("https://www.transparenttextures.com/patterns/carbon-fibre.png"),
                  opacity: 0.05,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatService.messagesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final messages = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140), // Espacio para el nav bar
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg['emisor_id'] == _currentUserId;
                      final bool isOfficial = msg['es_oficial'] ?? false;

                      return _buildMessageBubble(
                        name: msg['emisor_nombre'],
                        text: msg['mensaje'],
                        isMe: isMe,
                        isOfficial: isOfficial,
                        time: "Ahora",
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Barra de Entrada (Bottom Bar)
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String name,
    required String text,
    required bool isMe,
    required bool isOfficial,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isOfficial 
            ? AppTheme.alertRed.withOpacity(0.15) 
            : (isMe ? AppTheme.primaryBlue : AppTheme.cardDark),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: isOfficial ? Border.all(color: AppTheme.alertRed.withOpacity(0.5), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOfficial) const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.verified_user_rounded, size: 16, color: AppTheme.alertRed),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isOfficial ? AppTheme.alertRed : AppTheme.primaryBlue,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white70 : Colors.white30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // Extra bottom padding for floating nav bar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.backgroundDark.withOpacity(0.8),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.white54),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe a la comunidad...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
