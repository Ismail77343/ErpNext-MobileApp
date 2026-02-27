import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/gemini_chat_service.dart';

class AiAdvisorPage extends StatefulWidget {
  const AiAdvisorPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends State<AiAdvisorPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = GeminiChatService(model: 'gemini-3-flash-preview');
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _picker = ImagePicker();
  final List<_ChatMessage> _messages = [];

  XFile? _selectedImage;
  bool _speechReady = false;
  bool _isListening = false;
  bool _isSending = false;
  bool _voiceMode = true;
  double _soundLevel = 0;
  double _minSoundLevel = 50000;
  double _maxSoundLevel = -50000;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;

    final ready = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isListening = false);
      },
    );

    if (mounted) {
      setState(() => _speechReady = ready);
    }
    return ready;
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null || !mounted) return;
    setState(() => _selectedImage = file);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone is not ready on this device.')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _soundLevel = 0;
      _minSoundLevel = 50000;
      _maxSoundLevel = -50000;
    });

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        _minSoundLevel = math.min(_minSoundLevel, level);
        _maxSoundLevel = math.max(_maxSoundLevel, level);
        final range = (_maxSoundLevel - _minSoundLevel).abs();
        final normalized = range < 0.01 ? 0.0 : (level - _minSoundLevel) / range;
        setState(() => _soundLevel = normalized.clamp(0.0, 1.0));
      },
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _selectedImage == null) || _isSending) return;

    final history = _messages
        .where((m) => !m.isPending)
        .map((m) => (role: m.isUser ? 'user' : 'model', text: m.contextText))
        .toList();

    final sendingImage = _selectedImage;
    setState(() {
      _isSending = true;
      _messages.add(
        _ChatMessage.user(
          text.isEmpty ? 'Attached an image for analysis.' : text,
          imagePath: sendingImage?.path,
        ),
      );
      _controller.clear();
      _selectedImage = null;
    });
    _scrollToBottom();

    try {
      final attachments = <GeminiAttachment>[];
      if (sendingImage != null) {
        final bytes = await sendingImage.readAsBytes();
        final mimeType = lookupMimeType(sendingImage.path) ?? 'image/jpeg';
        attachments.add(GeminiAttachment(bytes: bytes, mimeType: mimeType));
      }

      setState(() => _messages.add(const _ChatMessage.pending()));
      _scrollToBottom();

      final reply = await _chatService.sendMessage(
        prompt: text,
        history: history,
        attachments: attachments,
      );
      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.isPending);
        _messages.add(_ChatMessage.ai(reply));
      });
      if (_voiceMode) await _speak(reply);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isPending);
        _messages.add(_ChatMessage.aiError('Error: $e'));
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Technical Palace Group AI Advisor - ERPNext Expert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0C4A6E),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Voice reply', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _voiceMode,
                    onChanged: (v) => setState(() => _voiceMode = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isListening)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: _VoiceVisualizer(level: _soundLevel),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
              final bg = msg.isUser ? const Color(0xFF0E7490) : Colors.white;
              final textColor = msg.isUser ? Colors.white : const Color(0xFF111827);

              return Align(
                alignment: align,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: msg.isUser
                        ? null
                        : Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: msg.isPending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg.imagePath != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(msg.imagePath!),
                                  height: 140,
                                  width: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              msg.text,
                              style: TextStyle(color: textColor, height: 1.35),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
        if (_selectedImage != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImage!.path),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('Image attached')),
                IconButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Attach image',
                  onPressed: _isSending ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                ),
                IconButton(
                  tooltip: _isListening ? 'Stop mic' : 'Start mic',
                  onPressed: _isSending ? null : _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? Colors.red : null,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type your question or use the microphone...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Advisor')),
      body: body,
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.isPending,
    this.isError = false,
    this.imagePath,
  });

  const _ChatMessage.pending()
      : this(text: '', isUser: false, isPending: true);

  factory _ChatMessage.user(String text, {String? imagePath}) => _ChatMessage(
        text: text,
        isUser: true,
        isPending: false,
        imagePath: imagePath,
      );

  factory _ChatMessage.ai(String text) =>
      _ChatMessage(text: text, isUser: false, isPending: false);

  factory _ChatMessage.aiError(String text) =>
      _ChatMessage(text: text, isUser: false, isPending: false, isError: true);

  final String text;
  final bool isUser;
  final bool isPending;
  final bool isError;
  final String? imagePath;

  String get contextText {
    if (text.trim().isNotEmpty) return text;
    if (imagePath != null) return '[User attached an image]';
    return '';
  }
}

class _VoiceVisualizer extends StatelessWidget {
  const _VoiceVisualizer({required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    final safeLevel = level.clamp(0.0, 1.0);
    final bars = List.generate(18, (i) {
      final wave = (math.sin((i + 1) * 0.7) + 1) / 2;
      final height = 8 + (safeLevel * (12 + wave * 24));
      return AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        width: 4,
        height: height,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFF22D3EE), const Color(0xFF0891B2), wave),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bars,
      ),
    );
  }
}
