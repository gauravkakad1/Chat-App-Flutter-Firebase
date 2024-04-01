import 'dart:io';

import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/media_services.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get_it/get_it.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile chatUser;
  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatUser currentUser;
  late ChatUser otherUser;
  GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late DatabaseServices _databaseServices;
  late MediaServices _mediaServices;
  late StorageServices _storageServices;
  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _databaseServices = getIt.get<DatabaseServices>();
    _mediaServices = getIt.get<MediaServices>();
    _storageServices = getIt.get<StorageServices>();
    currentUser = ChatUser(
        id: _authServices.user!.uid,
        firstName: _authServices.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(widget.chatUser.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        // centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: _databaseServices.getChatMessages(currentUser.id, otherUser.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = _convertMessages(chat?.messages ?? []);

        return DashChat(
            inputOptions: InputOptions(
                inputToolbarMargin: EdgeInsets.all(10),
                leading: [
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () async {
                      // Handle image upload
                      final media = await _mediaServices.pickImage();
                      if (media != null) {
                        final chatId = generateChatId(
                            userId1: currentUser.id, userId2: otherUser.id);
                        final downloadUrl =
                            await _storageServices.uploadChatImage(
                          chatId: chatId,
                          imageFile: File(media.path),
                        );
                        ChatMessage newMessage = ChatMessage(
                          user: currentUser,
                          medias: [
                            ChatMedia(
                              fileName: '',
                              url: downloadUrl!,
                              type: MediaType.image,
                            )
                          ],
                          createdAt: DateTime.now(),
                        );
                        _onSend(newMessage);
                      }
                    },
                  ),
                ],
                sendOnEnter: true,
                alwaysShowSend: true),
            messageOptions: MessageOptions(
              // showCurrentUserAvatar: true,
              showTime: true,
              showOtherUsersAvatar: true,
            ),
            currentUser: currentUser,
            onSend: _onSend,
            messages: messages);
      },
    );
  }

  Future<void> _onSend(ChatMessage message) async {
    if (message.medias != null && message.medias!.isNotEmpty ?? false) {
      if (message.medias!.first.type == MediaType.image) {
        // Handle media message
        Message newMessage = Message(
            senderID: currentUser.id,
            content: message.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(message.createdAt));
        await _databaseServices.sendMessage(
            currentUser.id, otherUser.id, newMessage);
      }
    } else {
      Message newMessage = Message(
          senderID: currentUser.id,
          content: message.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(message.createdAt));
      await _databaseServices.sendMessage(
          currentUser.id, otherUser.id, newMessage);
    }
  }

  _convertMessages(List<Message> messages) {
    var msg = messages.map((message) {
      if (message.messageType == MessageType.Image) {
        return ChatMessage(
          user: message.senderID == currentUser.id ? currentUser : otherUser,
          medias: [
            ChatMedia(
              fileName: "",
              url: message.content!,
              type: MediaType.image,
            )
          ],
          createdAt: message.sentAt!.toDate(),
        );
      } else {
        return ChatMessage(
          text: message.content!,
          user: message.senderID == currentUser.id ? currentUser : otherUser,
          createdAt: message.sentAt!.toDate(),
        );
      }
    }).toList();
    msg.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return msg;
  }
}
