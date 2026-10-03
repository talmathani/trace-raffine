import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

class ManagerChatScreen extends StatefulWidget {
  const ManagerChatScreen({super.key});

  @override
  State<ManagerChatScreen> createState() => _ManagerChatScreenState();
}

class _ManagerChatScreenState extends State<ManagerChatScreen> {
  final FunctionInvoker _functions = FunctionInvoker.create();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  List<_ManagerMessage> _messages = const [];
  String? _userId;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final userId = await CurrentUserService.userId;
    if (!mounted) return;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'يلزم تسجيل الدخول لاستخدام المحادثة.';
      });
      return;
    }
    _userId = userId;
    await _loadMessages();
    await _markRead();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadMessages(silent: true),
    );
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final result = await _functions.listManagerMessages(userId: userId);
      if (result['success'] != true) {
        throw StateError(result['error']?.toString() ?? 'تعذر تحميل المحادثة.');
      }
      final raw = result['messages'];
      final messages = raw is List
          ? raw.whereType<Map>().map(_ManagerMessage.fromMap).toList()
          : <_ManagerMessage>[];
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!silent) _error = error.toString();
      });
    }
  }

  Future<void> _markRead() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _functions.markManagerMessagesRead(userId: userId);
    } catch (_) {}
  }

  Future<void> _send() async {
    final userId = _userId;
    final body = _controller.text.trim();
    if (userId == null || body.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final result = await _functions.sendManagerMessage(
        userId: userId,
        body: body,
      );
      if (result['success'] != true) {
        throw StateError(result['error']?.toString() ?? 'تعذر إرسال الرسالة.');
      }
      _controller.clear();
      await _loadMessages(silent: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: MaisonAppBar(title: 'محادثة مع المدير'),
        body: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.softRose),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: AppTheme.mutedIvory,
            ),
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'ابدأ المحادثة مع المدير من هنا.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.warmIvory,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final mine = message.senderId == _userId;
        return _MessageBubble(message: message, mine: mine);
      },
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: AppTheme.burgundyBlack,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك للمدير...',
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            tooltip: 'إرسال',
          ),
        ],
      ),
    );
  }
}

class _ManagerMessage {
  const _ManagerMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory _ManagerMessage.fromMap(Map raw) {
    final value = raw['created_at']?.toString();
    return _ManagerMessage(
      id: raw[r'$id']?.toString() ?? raw['id']?.toString() ?? '',
      senderId: raw['sender_id']?.toString() ?? '',
      body: raw['body']?.toString() ?? '',
      isRead: raw['is_read'] == true,
      createdAt: value == null ? null : DateTime.tryParse(value),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mine});

  final _ManagerMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt == null
        ? ''
        : _formatTime(message.createdAt!);
    return Align(
      alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
        decoration: BoxDecoration(
          color: mine ? AppTheme.deepBurgundy : AppTheme.burgundyBlack,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
          border: Border.all(
            color: mine
                ? AppTheme.softRose.withValues(alpha: 0.22)
                : AppTheme.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                color: AppTheme.warmIvory,
                height: 1.7,
              ),
            ),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                time,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 9,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
