import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';

class VoiceEditorScreen extends StatefulWidget {
  const VoiceEditorScreen({super.key});

  @override
  State<VoiceEditorScreen> createState() => _VoiceEditorScreenState();
}

class _VoiceEditorScreenState extends State<VoiceEditorScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isRecording = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  double _playbackRate = 1.0;
  String? _loadedAudioUrl;

  // FX State
  double _pitchShift = 0;
  double _reverbDepth = 0;
  double _echoFeedback = 0;
  double _noiseGate = 0.02;
  bool _normalize = false;
  double _trimStart = 0;
  double _trimEnd = 1.0;

  // UI
  int _selectedTool = 0; // 0=trim, 1=fx, 2=levels
  final List<Map<String, dynamic>> _tools = [
    {'icon': Icons.crop, 'label': 'Trim'},
    {'icon': Icons.tune, 'label': 'FX'},
    {'icon': Icons.bar_chart, 'label': 'Levels'},
  ];

  final List<Map<String, dynamic>> _sampleClips = [
    {'name': 'Urdu Female (Uzma)', 'url': '/api/tts/audio?voice=ur-PK-UzmaNeural', 'lang': '🇵🇰 Urdu'},
    {'name': 'Urdu Male (Asad)', 'url': '/api/tts/audio?voice=ur-PK-AsadNeural', 'lang': '🇵🇰 Urdu'},
    {'name': 'English (Heart)', 'url': '/api/tts/audio?voice=af_heart', 'lang': '🇺🇸 English'},
    {'name': 'English (Bella)', 'url': '/api/tts/audio?voice=af_bella', 'lang': '🇺🇸 English'},
  ];

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text('Voice Editor',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(
                'Upload, record, trim, and apply professional audio effects to your voice tracks.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 20),

            // Upload / Record / Samples
            _buildSourceCard(),
            const SizedBox(height: 16),

            // Waveform / Player
            _buildPlayerCard(),
            const SizedBox(height: 16),

            // Tool Tabs
            _buildToolTabs(),
            const SizedBox(height: 12),
            _buildToolContent(),
            const SizedBox(height: 16),

            // Export
            _buildExportCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Audio Source',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.upload_file,
                  label: 'Upload File',
                  color: AppColors.primary,
                  onTap: () => _showSnack('File upload — use file_picker in real app'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  icon: _isRecording ? Icons.stop : Icons.mic,
                  label: _isRecording ? 'Stop' : 'Record',
                  color: _isRecording ? Colors.red : AppColors.accent,
                  onTap: () => setState(() => _isRecording = !_isRecording),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Sample Clips',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ...(_sampleClips.map((clip) => _sampleClipTile(clip))),
        ],
      ),
    );
  }

  Widget _sampleClipTile(Map<String, dynamic> clip) {
    return GestureDetector(
      onTap: () {
        setState(() => _loadedAudioUrl = clip['url']);
        _player.play(UrlSource('http://localhost:3000${clip['url']}'));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.play_arrow, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clip['name'],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(clip['lang'],
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Waveform visualization (static art)
          SizedBox(
            height: 60,
            child: _loadedAudioUrl == null
                ? Center(
                    child: Text('No audio loaded',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                  )
                : CustomPaint(
                    painter: _WaveformPainter(progress: progress),
                    child: Container(),
                  ),
          ),
          const SizedBox(height: 12),

          // Scrub bar
          Slider(
            value: progress,
            onChanged: (v) async {
              final newPos = Duration(
                  milliseconds: (v * _duration.inMilliseconds).round());
              await _player.seek(newPos);
            },
            activeColor: AppColors.accent,
            inactiveColor: Colors.white.withValues(alpha: 0.15),
          ),

          // Time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace')),
                Text(_fmt(_duration),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _player.seek(Duration.zero),
                icon: const Icon(Icons.skip_previous, color: Colors.white70),
              ),
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _player.pause();
                  } else if (_loadedAudioUrl != null) {
                    await _player.play(
                        UrlSource('http://localhost:3000$_loadedAudioUrl'));
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _player.seek(_duration),
                icon: const Icon(Icons.skip_next, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              // Playback rate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<double>(
                  value: _playbackRate,
                  dropdownColor: AppColors.darkBg,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text('${r}x'),
                          ))
                      .toList(),
                  onChanged: (v) async {
                    if (v != null) {
                      setState(() => _playbackRate = v);
                      await _player.setPlaybackRate(v);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolTabs() {
    return Row(
      children: _tools.asMap().entries.map((e) {
        final isSelected = _selectedTool == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTool = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border),
              ),
              margin: EdgeInsets.only(right: e.key < _tools.length - 1 ? 8 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(e.value['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(e.value['label'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToolContent() {
    switch (_selectedTool) {
      case 0:
        return _buildTrimTool();
      case 1:
        return _buildFxTool();
      case 2:
        return _buildLevelsTool();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTrimTool() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trim',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildSlider('Start Point', _trimStart, 0, 1,
              (v) => setState(() => _trimStart = v > _trimEnd ? _trimEnd : v)),
          _buildSlider('End Point', _trimEnd, 0, 1,
              (v) => setState(() => _trimEnd = v < _trimStart ? _trimStart : v)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.crop,
                  label: 'Apply Trim',
                  color: AppColors.primary,
                  onTap: () => _showSnack('Trim applied!'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.undo,
                  label: 'Reset',
                  color: AppColors.textSecondary,
                  onTap: () => setState(() {
                    _trimStart = 0;
                    _trimEnd = 1;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFxTool() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Audio Effects',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildSlider('Pitch Shift (semitones)', _pitchShift, -12, 12,
              (v) => setState(() => _pitchShift = v)),
          _buildSlider('Echo Feedback', _echoFeedback, 0, 0.85,
              (v) => setState(() => _echoFeedback = v)),
          _buildSlider('Reverb Depth', _reverbDepth, 0, 1,
              (v) => setState(() => _reverbDepth = v)),
          const SizedBox(height: 8),
          // Normalize toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Normalize Audio',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Switch(
                value: _normalize,
                onChanged: (v) => setState(() => _normalize = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsTool() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Audio Levels',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildSlider('Volume', _volume, 0, 2,
              (v) => setState(() {
                    _volume = v;
                    _player.setVolume(v.clamp(0, 1));
                  })),
          _buildSlider('Noise Gate', _noiseGate, 0, 0.2,
              (v) => setState(() => _noiseGate = v)),
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.download,
                  label: 'Download WAV',
                  color: AppColors.primary,
                  onTap: () => _showSnack('Downloading WAV...'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  icon: Icons.audio_file,
                  label: 'Download MP3',
                  color: AppColors.accent,
                  onTap: () => _showSnack('Downloading MP3...'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(value.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'monospace')),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// Custom waveform painter
class _WaveformPainter extends CustomPainter {
  final double progress;
  _WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bars = 60;
    final barWidth = size.width / bars;
    final heights = List.generate(bars, (i) {
      return (size.height * 0.2) +
          (size.height * 0.6) *
              (0.5 + 0.5 * (i % 7 / 7 * 2 - 1).abs());
    });

    for (int i = 0; i < bars; i++) {
      final isPlayed = i / bars <= progress;
      final paint = Paint()
        ..color = isPlayed ? AppColors.accent : Colors.white.withValues(alpha: 0.2)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth * 0.6;

      final x = barWidth * i + barWidth / 2;
      final h = heights[i] * 0.5;
      canvas.drawLine(
        Offset(x, size.height / 2 - h),
        Offset(x, size.height / 2 + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress;
}
