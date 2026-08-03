import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/chat_knowledge_base.dart';
import '../../services/chat_service.dart';
import '../../widgets/animated_entrance.dart';
import '../../widgets/flexible_asset_image.dart';

enum _Stage { idle, thinking, extracting, streaming }

enum _Role { user, bot }

class _Message {
  final _Role role;
  String text;
  final bool isError;

  _Message({required this.role, required this.text, this.isError = false});
}

/// Dark palette local to this screen only — deliberately not added to the
/// global (white, app-wide) AppColors. Brand orange (AppColors.primary)
/// still carries through for the user bubble and send button.
class _ChatColors {
  _ChatColors._();

  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1C);
  static const surfaceHi = Color(0xFF242428);
  static const border = Color(0xFF2E2E33);
  static const textHi = Colors.white;
  static const textLo = Color(0xFFA1A1AA);
}

/// Full-screen AI Guide chat — answers from the local [chatKnowledgeBase]
/// via [ChatService], with a thinking → extracting → typewriter-streamed
/// response so it reads like a real assistant even though nothing leaves
/// the device.
///
/// EXEMPT from the app's light/dark theme toggle, intentionally — this
/// screen is always dark, the same way Claude/ChatGPT's own chat UIs are,
/// regardless of the rest of the app's theme. It never reads
/// context.palette; _ChatColors above and AppColors.primary/success are
/// the complete, deliberate palette for this screen in both app themes.
/// Do not "fix" this in a future sweep.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typeTimer;

  _Stage _stage = _Stage.idle;
  bool _showSuggestions = true;
  bool _hasText = false;
  String _pendingFullText = '';
  bool _pendingIsError = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _Message(
        role: _Role.bot,
        text:
            "Hi! I'm your Excelerate AI Guide. Ask me anything about your "
            "programs, or tap a suggestion below to get started.",
      ),
    );
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _stage != _Stage.idle) return;

    if (preset == null) _controller.clear();
    setState(() {
      _messages.add(_Message(role: _Role.user, text: text));
      _showSuggestions = false;
      _stage = _Stage.thinking;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _stage = _Stage.extracting);
    _scrollToBottom();

    try {
      final answer = await ChatService.ask(text);
      if (!mounted) return;
      _beginStreaming(answer, isError: false);
    } on ChatUnknownException catch (e) {
      if (!mounted) return;
      _beginStreaming(e.message, isError: true);
    }
  }

  void _beginStreaming(String fullText, {required bool isError}) {
    _pendingFullText = fullText;
    _pendingIsError = isError;
    setState(() {
      _stage = _Stage.streaming;
      _messages.add(_Message(role: _Role.bot, text: '', isError: isError));
    });
    _scrollToBottom();

    final targetIndex = _messages.length - 1;
    var charIndex = 0;
    _typeTimer?.cancel();
    _typeTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      charIndex++;
      setState(
        () => _messages[targetIndex].text = fullText.substring(0, charIndex),
      );
      _scrollToBottom();
      if (charIndex >= fullText.length) {
        timer.cancel();
        setState(() {
          _stage = _Stage.idle;
          if (isError) _showSuggestions = true;
        });
      }
    });
  }

  /// Tapping the message list while a response is streaming reveals it
  /// instantly — useful mid-demo, and standard chat-app behavior.
  void _skipStreaming() {
    if (_typeTimer == null || !_typeTimer!.isActive) return;
    _typeTimer!.cancel();
    final targetIndex = _messages.length - 1;
    setState(() {
      _messages[targetIndex].text = _pendingFullText;
      _stage = _Stage.idle;
      if (_pendingIsError) _showSuggestions = true;
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ChatColors.surfaceHi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final busy = _stage == _Stage.thinking || _stage == _Stage.extracting;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _ChatColors.bg,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _skipStreaming,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    itemCount: _messages.length + (busy ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        final message = _messages[index];
                        final bubble = _ChatBubble(message: message);
                        // Only messages that never mutate after creation get
                        // the slide-in — the streaming bubble's text changes
                        // every ~18ms, and re-triggering an entrance tween on
                        // every one of those rebuilds would look jittery
                        // rather than smooth. Its typewriter reveal already
                        // reads as its own entrance.
                        return message.role == _Role.user
                            ? AnimatedEntrance(index: index, child: bubble)
                            : bubble;
                      }
                      return _ThinkingBubble(
                        extracting: _stage == _Stage.extracting,
                      );
                    },
                  ),
                ),
              ),
              if (_showSuggestions)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: _SuggestionChips(onTap: _handleSend),
                ),
              // Composer rides directly above the keyboard: with
              // resizeToAvoidBottomInset false, nothing else pushes it up,
              // so its own bottom padding has to equal the keyboard's
              // height itself (not just a small constant) — same mechanism
              // as Login/Sign-Up's keyboard handling.
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.sm,
                  bottom:
                      viewInsets.bottom +
                      (viewInsets.bottom > 0 ? AppSpacing.sm : AppSpacing.lg),
                ),
                child: _buildComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _BotAvatar(size: 40),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Excelerate AI Guide',
                      style: TextStyle(
                        color: _ChatColors.textHi,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Online',
                          style: TextStyle(color: _ChatColors.textLo, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: _ChatColors.textHi),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(color: _ChatColors.border, height: 1),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: _ChatColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _ChatColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ComposerIconButton(
            icon: Icons.add,
            onTap: () => _showComingSoon('Attach a file'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: _ChatColors.textHi, fontSize: 14.5),
                cursorColor: AppColors.primary,
                // Every field in this app is styled by the app-wide
                // InputDecorationTheme (filled: true, white fillColor +
                // grey/orange outline borders) — that's correct for the
                // rest of the app's white screens, but left unoverridden
                // here it paints a white box straight through this dark
                // composer. Every border/fill slot needs an explicit
                // override, not just `border`, since InputDecoration
                // resolves enabledBorder/focusedBorder/etc. against the
                // theme independently of the generic `border` field.
                decoration: const InputDecoration(
                  hintText: 'Ask about your internship…',
                  hintStyle: TextStyle(color: _ChatColors.textLo),
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          // One slot, not two side-by-side controls — mic and send occupy
          // the exact same position and cross-fade + slide between each
          // other as typing starts/stops, so there's no dead gap between
          // the text and a permanently-visible mic icon.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _hasText
                ? _ComposerSendButton(
                    key: const ValueKey('send'),
                    onTap: () => _handleSend(),
                  )
                : _ComposerIconButton(
                    key: const ValueKey('mic'),
                    icon: Icons.mic_none_rounded,
                    onTap: () => _showComingSoon('Voice input'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ComposerSendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ComposerSendButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ComposerIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ChatColors.surfaceHi,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: _ChatColors.textLo, size: 20),
        ),
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  final double size;

  const _BotAvatar({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: _ChatColors.surfaceHi,
        child: FlexibleAssetImage(
          baseName: 'assets/images/chatbot_icon',
          fit: BoxFit.cover,
          fallback: (context) => Icon(
            Icons.smart_toy_outlined,
            color: AppColors.primary,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _Message message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _Role.user;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : _ChatColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isUser ? Colors.white : _ChatColors.textHi,
          fontSize: 14.5,
          height: 1.4,
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md, left: 60),
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: bubble,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BotAvatar(size: 28),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Container(constraints: BoxConstraints(maxWidth: maxWidth), child: bubble),
          ),
        ],
      ),
    );
  }
}

/// Bot-side bubble shown while a response is being produced — same pulsing
/// dots throughout, just swaps its label between "Thinking" and
/// "Extracting from LMS" so the wait still reads as two distinct stages.
class _ThinkingBubble extends StatefulWidget {
  final bool extracting;

  const _ThinkingBubble({required this.extracting});

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BotAvatar(size: 28),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _ChatColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.extracting ? 'Extracting from LMS' : 'Thinking',
                  style: const TextStyle(color: _ChatColors.textLo, fontSize: 13),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final t = (_controller.value - i * 0.2) % 1.0;
                        final opacity = (0.3 + 0.7 * (1 - (t - 0.5).abs() * 2))
                            .clamp(0.3, 1.0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _ChatColors.textLo,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _SuggestionChips({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Horizontal scroll, same pattern as Home's category-filter pills —
    // a wrapping grid of these full-length prompts ate several lines of
    // vertical space; a single scrollable row reads faster and leaves the
    // message list room to breathe.
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestedPrompts.length,
        itemBuilder: (context, index) {
          final prompt = suggestedPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AnimatedEntrance(
              index: index,
              child: _SuggestionChip(label: prompt, onTap: () => onTap(prompt)),
            ),
          );
        },
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ChatColors.surfaceHi,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _ChatColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(color: _ChatColors.textHi, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
