import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with TickerProviderStateMixin {
  // =============================================
  // RECORDING STATE
  // =============================================

  bool _isRecording = false;
  bool _isPaused = false;

  Duration _recordingDuration = Duration.zero;

  Timer? _recordingTimer;

  // =============================================
  // PLAYBACK STATE
  // =============================================

  bool _isPlaying = false;

  int? _currentlyPlayingIndex;

  // ignore: unused_field
  final Duration _playbackPosition = Duration.zero;

  // =============================================
  // ANIMATIONS
  // =============================================

  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  // =============================================
  // MOCK DATA
  // =============================================

  final List<VoiceNote> _voiceNotes = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadSavedVoiceNotes();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // =============================================
  // PERSISTED VOICE NOTES
  // =============================================

  Future<void> _loadSavedVoiceNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_voice_notes');

    if (savedJson == null || savedJson.isEmpty) {
      return;
    }

    final List<dynamic> decoded = jsonDecode(savedJson) as List<dynamic>;

    setState(() {
      _voiceNotes.clear();
      _voiceNotes.addAll(
        decoded
            .map((entry) => VoiceNote.fromMap(entry as Map<String, dynamic>))
            .toList(),
      );
    });
  }

  Future<void> _saveVoiceNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _voiceNotes.map((note) => note.toMap()).toList(),
    );
    await prefs.setString('saved_voice_notes', encoded);
  }

  // =============================================
  // UI
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Notes'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.helpCircle, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Tap record to start. Voice notes can be converted to transactions.',
                  ),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildRecordingArea(),

                  const SizedBox(height: AppSpacing.lg),

                  _buildWaveformVisualization(),

                  const SizedBox(height: AppSpacing.lg),

                  _buildVoiceNotesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // RECORDING AREA
  // =============================================

  Widget _buildRecordingArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: _isRecording
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: _isRecording ? AppColors.error : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            _isRecording
                ? (_isPaused ? 'Paused' : 'Recording...')
                : 'Tap to start recording',
            style: AppTypography.bodyMedium.copyWith(
              color: _isRecording ? AppColors.error : AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final scale = _isRecording && !_isPaused
                    ? _pulseAnimation.value
                    : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? AppColors.error : AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRecording
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: _isRecording ? 8 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isRecording
                              ? (_isPaused
                                    ? LucideIcons.mic
                                    : LucideIcons.pause)
                              : LucideIcons.mic,
                          key: ValueKey(
                            _isRecording
                                ? (_isPaused ? 'paused' : 'recording')
                                : 'idle',
                          ),
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          if (_isRecording) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isPaused ? LucideIcons.play : LucideIcons.pause,
                  label: _isPaused ? 'Resume' : 'Pause',
                  onTap: _togglePause,
                ),

                const SizedBox(width: AppSpacing.xl),

                _buildControlButton(
                  icon: LucideIcons.square,
                  label: 'Stop',
                  onTap: _stopRecording,
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =============================================
  // CONTROL BUTTON
  // =============================================

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, size: 20, color: color)),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // WAVEFORM
  // =============================================

  Widget _buildWaveformVisualization() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.waves, size: 18, color: AppColors.primary),

              const SizedBox(width: AppSpacing.sm),

              const Text('Waveform', style: AppTypography.titleMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size.infinite,
              painter: WaveformPainter(
                isActive: _isRecording && !_isPaused,
                color: _isRecording ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // NOTES LIST
  // =============================================

  Widget _buildVoiceNotesList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.listMusic,
                    size: 20,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  const Text(
                    'Saved Voice Notes',
                    style: AppTypography.titleLarge,
                  ),
                ],
              ),

              if (_voiceNotes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_voiceNotes.length}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          if (_voiceNotes.isEmpty)
            _buildEmptyNotesPlaceholder()
          else
            ..._voiceNotes.asMap().entries.map((entry) {
              return _buildVoiceNoteTile(note: entry.value, index: entry.key);
            }),
        ],
      ),
    );
  }

  // =============================================
  // EMPTY STATE
  // =============================================

  Widget _buildEmptyNotesPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              LucideIcons.micOff,
              size: 48,
              color: AppColors.textTertiary,
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'No voice notes yet',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Tap the record button to create your first note',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // NOTE TILE
  // =============================================

  Widget _buildVoiceNoteTile({required VoiceNote note, required int index}) {
    final isCurrentlyPlaying = _currentlyPlayingIndex == index && _isPlaying;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isCurrentlyPlaying
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _togglePlayback(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrentlyPlaying
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCurrentlyPlaying
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        size: 18,
                        color: isCurrentlyPlaying
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            _formatDuration(note.duration),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),

                          Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              _formatDate(note.date),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (note.isSynced)
                  const Icon(
                    LucideIcons.cloud,
                    size: 16,
                    color: AppColors.success,
                  )
                else
                  const Icon(
                    LucideIcons.cloudOff,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),

            if (isCurrentlyPlaying) ...[
              const SizedBox(height: AppSpacing.sm),

              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 0.35,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  minHeight: 3,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _convertToTransaction(note),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.income.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.receipt,
                            size: 14,
                            color: AppColors.income,
                          ),

                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              'Convert to Transaction',
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.income,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                GestureDetector(
                  onTap: () => _deleteVoiceNote(note.id),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // ACTIONS
  // =============================================

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });

    _pulseController.repeat(reverse: true);

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePause() {
    if (!_isRecording) {
      return;
    }

    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    _pulseController.stop();
    _pulseController.reset();

    final note = VoiceNote(
      id: 'vn_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Voice note ${_voiceNotes.length + 1}',
      duration: _recordingDuration,
      date: DateTime.now(),
      isSynced: false,
      filePath: '',
    );

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _voiceNotes.insert(0, note);
      _recordingDuration = Duration.zero;
    });

    _saveVoiceNotes();
  }

  void _togglePlayback(int index) {
    setState(() {
      if (_currentlyPlayingIndex == index && _isPlaying) {
        _isPlaying = false;
        _currentlyPlayingIndex = null;
      } else {
        _isPlaying = true;
        _currentlyPlayingIndex = index;
      }
    });
  }

  void _convertToTransaction(VoiceNote note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Converting "${note.title}" to transaction...'),
        backgroundColor: AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  void _deleteVoiceNote(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Delete Voice Note', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to delete this voice note?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _voiceNotes.removeWhere((n) => n.id == id);
              });

              await _saveVoiceNotes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // =============================================
  // HELPERS
  // =============================================

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================
// MODEL
// =============================================

class VoiceNote {
  final String id;
  final String title;
  final Duration duration;
  final DateTime date;
  final bool isSynced;
  final String filePath;

  const VoiceNote({
    required this.id,
    required this.title,
    required this.duration,
    required this.date,
    this.isSynced = false,
    required this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration.inSeconds,
      'date': date.toIso8601String(),
      'isSynced': isSynced,
      'filePath': filePath,
    };
  }

  factory VoiceNote.fromMap(Map<String, dynamic> map) {
    return VoiceNote(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      duration: Duration(
        seconds: map['duration'] is int
            ? map['duration'] as int
            : int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      ),
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      isSynced:
          map['isSynced'] == true || map['isSynced']?.toString() == 'true',
      filePath: map['filePath']?.toString() ?? '',
    );
  }
}

// =============================================
// WAVEFORM PAINTER
// =============================================

class WaveformPainter extends CustomPainter {
  final bool isActive;
  final Color color;

  WaveformPainter({required this.isActive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isActive ? 0.7 : 0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const barCount = 50;

    final barWidth = size.width / barCount;

    final midY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;

      double barHeight;

      if (isActive) {
        final phase = DateTime.now().millisecondsSinceEpoch / 500.0;

        barHeight =
            (size.height * 0.3) * (0.3 + 0.7 * ((i * 0.3 + phase) % 1.0).abs());
      } else {
        barHeight = size.height * 0.05 * (0.5 + (i % 3) * 0.3);
      }

      final startY = midY - barHeight / 2;

      final endY = midY + barHeight / 2;

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return isActive != oldDelegate.isActive || color != oldDelegate.color;
  }
}
