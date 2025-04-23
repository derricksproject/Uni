import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/file_finder.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/data/services/file_service.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/chat_message.dart';
import 'package:flutter_allianz/presentation/widgets/image_viewer.dart';
import 'package:flutter_allianz/presentation/widgets/pdf_widget.dart';
import 'package:flutter_allianz/presentation/widgets/styled/styled_tabbar.dart';

/// A StatelessWidget that provides the main layout for the Chat screen.
/// 
/// **Author**: Derrick Nyarko
class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: ChatScreen(),
          ),
        ],
      ),
    );
  }
}

/// A StatefulWidget for managing the chat functionality.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription<ChatMessage> _chatStreamSubscription;
  late StreamSubscription<ChatMessage> _missionControlSubscription;
  final TextEditingController _messageController = TextEditingController();
  late List<ChatMessage> _messages;
  final ScrollController _scrollController = ScrollController();
  File? attachedFile;
  final _focusNode = FocusNode();
  final String user = Params.userName;

  @override
  void initState() {
    super.initState();
    _missionControlSubscription =
        ControllerHelper.controller.getChatStream('chatbot/mission_control').listen((message) {
      setState(() {
        if(message.user != user) {
              _messages.add(message);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
    _messages = ControllerHelper.controller.getChatMessages();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _chatStreamSubscription.cancel();
    _missionControlSubscription.cancel();
    super.dispose();
  }

  /// Sends a message and clears the input field.
  void _sendMessage(ChatMessage message) {
    if (message.message.trim().isEmpty) return;
    setState(() {
      _messages.add(message);
      attachedFile = null;
    });
    ControllerHelper.controller.sendMessage(message);
    _messageController.clear();
  }

  List<Tab> tabs = [
    const Tab(text: 'Chat'),
    const Tab(text: 'Images'),
    const Tab(text: 'PDF-Viewer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: StyledTabBar(
            controller: _tabController,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            chatPanel(),
            const ImageViewer(),
            const PDFViewerWidget(pdfPath: null),
          ],
        ));
  }

  /// Builds the chat panel displaying the chat messages and message input.
  Widget chatPanel() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final ChatMessage message = _messages[index];
              final bool isCurrentUser = message.user == user;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: IntrinsicWidth(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.blue.shade600
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    message.message,
                                    style:
                                        Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                if (message.file != null)
                                  Container(
                                      alignment: Alignment.bottomRight,
                                      child: _buildFileWidget(message)),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    textAlign: TextAlign.end,
                                    message.time.substring(11, 16),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  /// Builds the message input field with options to send a message and attach a file.
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type here to enter a message!',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _sendMessage(
                          ChatMessage(user, value, DateTime.now().toString(), file: attachedFile));
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.blue.shade600,
                ),
                onPressed: () async {
                  final file = await FileFinder(FileService()).openFilePicker();
                  if (file != null) {
                    setState(() {
                      attachedFile = file;
                    });
                  }
                },
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage(ChatMessage(user, _messageController.text, DateTime.now().toString(),
                        file: attachedFile));
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Icon(Icons.send, size: 32, color: Colors.white),
              ),
            ],
          ),
          if (attachedFile != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => {
                    setState(() {
                      attachedFile = null;
                    })
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Attached file: ${attachedFile!.path.split('/').last}',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

   /// Builds the file widget for displaying attached files.
  Widget _buildFileWidget(ChatMessage message) {
    final file = message.file!;
    final isImage = ['png', 'jpg', 'jpeg', 'gif']
        .contains(file.path.split('.').last.toLowerCase());

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(
          file,
          height: 400,
          width: 400,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          debugPrint('File tapped: ${file.path}');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.fileName ?? 'Unknown File',
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8.0),
            const Icon(Icons.attach_file, size: 12, color: Colors.white),
          ],
        ),
      );
    }
  }
}
