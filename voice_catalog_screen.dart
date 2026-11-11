import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state.dart';
import '../models/voice_model.dart';
import '../theme/app_theme.dart';
import '../widgets/clone_voice_sheet.dart';

class VoiceCatalogScreen extends StatefulWidget {
  final Function(String) onOpenAuth;
  final VoidCallback onOpenMediaCloner;

  const VoiceCatalogScreen({
    super.key,
    required this.onOpenAuth,
    required this.onOpenMediaCloner,
  });

  @override
  State<VoiceCatalogScreen> createState() => _VoiceCatalogScreenState();
}

class _VoiceCatalogScreenState extends State<VoiceCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = 'all';
  String _searchQuery = '';
  final AudioPlayer _previewPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'All Voices'},
    {'key': 'urdu', 'label': '🇵🇰 Urdu'},
    {'key': 'character', 'label': '🎭 Character'},
    {'key': 'narration', 'label': 'Narration'},
    {'key': 'conversational', 'label': 'Conversational'},
    {'key': 'professional', 'label': 'Professional'},
    {'key': 'male', 'label': 'Male'},
    {'key': 'female', 'label': 'Female'},
    {'key': 'custom', 'label': '✨ Cloned'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  List<VoiceModel> _filtered(List<VoiceModel> voices) {
    return voices.where((v) {
      // Category filter
      bool matchesCategory = true;
      switch (_filterCategory) {
        case 'urdu':
          matchesCategory = v.language.toLowerCase().contains('ur') ||
              v.accent.toLowerCase().contains('urdu');
          break;
        case 'custom':
          matchesCategory = v.isCustom;
          break;
        case 'male':
          matchesCategory = v.gender == 'male';
          break;
        case 'female':
          matchesCategory = v.gender == 'female';
          break;
        case 'character':
          matchesCategory = v.category == 'character';
          break;
        case 'all':
          matchesCategory = true;
          break;
        default:
          matchesCategory = v.category == _filterCategory;
      }

      // Search filter
      if (_searchQuery.isEmpty) return matchesCategory;
      final q = _searchQuery.toLowerCase();
      return matchesCategory &&
          (v.name.toLowerCase().contains(q) ||
              v.accent.toLowerCase().contains(q) ||
              v.description.toLowerCase().contains(q) ||
              v.language.toLowerCase().contains(q));
    }).toList();
  }

  void _playPreview(String voiceId, AppState state) {
    final url = state.api.getPreviewUrl(voiceId);
    _previewPlayer.play(UrlSource(url));
  }

  void _showCloneSheet(BuildContext context, AppState state) {
    if (state.user == null) {
      widget.onOpenAuth('login');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CloneVoiceSheet(
        onClone: (name, category, accent, desc, consent) async {
          try {
            final newVoice = await state.api.cloneVoice(
              name: name,
              category: category,
              accent: accent,
              description: desc,
              consentVerified: consent,
            );
            state.addClonedVoice(newVoice);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voice "$name" cloned successfully!'),
                  backgroundColor: AppColors.accent,
                ),
              );
            }
          } catch (e) {
            rethrow;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filtered = _filtered(state.voices);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text('Voice Catalog',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showCloneSheet(context, state),
                        icon: const Icon(Icons.add, size: 12),
                        label: const Text('Clone',
                            style: TextStyle(fontSize: 10)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: widget.onOpenMediaCloner,
                        icon: const Icon(Icons.video_call, size: 12, color: Colors.white),
                        label: const Text('Media',
                            style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Browse ${state.voices.length} pre-trained AI voices or create your own clone.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // Search
              TextField(
                controller: _searchController,
                onChanged: (q) => setState(() => _searchQuery = q),
                decoration: InputDecoration(
                  hintText: 'Search by name, accent, language...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          child: const Icon(Icons.close, size: 16),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Category filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final filter = _filters[i];
                    final isActive = _filterCategory == filter['key'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _filterCategory = filter['key']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Text(
                          filter['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text('${filtered.length} voices',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // Voice Grid
        Expanded(
          child: state.isLoadingVoices
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              color: AppColors.textSecondary, size: 40),
                          const SizedBox(height: 12),
                          const Text('No voices match your criteria',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {
                              _filterCategory = 'all';
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _buildVoiceCard(filtered[i], state),
                    ),
        ),
      ],
    );
  }

  Widget _buildVoiceCard(VoiceModel voice, AppState state) {
    final isSelected = state.selectedVoiceId == voice.id;
    return GestureDetector(
      onTap: () {
        state.setSelectedVoiceId(voice.id);
        state.setActiveTab(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${voice.name} selected for Studio'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + Category badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        isSelected ? AppColors.primary : AppColors.primaryLight,
                    child: Text(
                      voice.name.substring(0, 1),
                      style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        voice.category,
                        style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.3),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),

              // Name
              Text(
                voice.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Badges
              Row(
                children: [
                  if (voice.language.startsWith('ur'))
                    _badgeTile('Urdu', AppColors.accent),
                  if (voice.isCustom) _badgeTile('Clone', AppColors.primary),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                voice.accent,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                voice.description,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _playPreview(voice.id, state),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 12, color: AppColors.primary),
                            SizedBox(width: 3),
                            Text('Preview',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (voice.isCustom &&
                      state.user != null &&
                      voice.createdBy == state.user!.id) ...[
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => _deleteVoice(voice, state),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeTile(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'monospace'),
      ),
    );
  }

  Future<void> _deleteVoice(VoiceModel voice, AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Voice Clone'),
        content: Text('Are you sure you want to delete "${voice.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      await state.api.deleteVoice(voice.id);
      await state.fetchVoices();
    }
  }
}
