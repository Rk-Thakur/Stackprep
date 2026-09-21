import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/kotlin_swift_seeder.dart';

class SeedPage extends StatefulWidget {
  const SeedPage({super.key});

  @override
  State<SeedPage> createState() => _SeedPageState();
}

class _SeedPageState extends State<SeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _seedApp() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Seeding all tracks...')),
    );
    try {
      final report = await const AppSeeder().seedAll();
      final summary = report.entries
          .map(
            (e) =>
                '${e.key}: ${e.value['modules']} modules, '
                '${e.value['questions']} q, ${e.value['flipcards']} cards',
          )
          .join(' | ');
      messenger.showSnackBar(SnackBar(content: Text('Seeded: $summary')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Seed error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Firestore Admin'),
        // backgroundColor: AppColors.surfaceContainer,
        // foregroundColor: AppColors.onSurface,
        actions: [
          TextButton.icon(
            onPressed: _seedApp,
            icon: const Icon(Icons.storage_rounded, size: 18),
            label: const Text('Seed All'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tracks'),
            Tab(text: 'Modules'),
            Tab(text: 'Content'),
            Tab(text: 'Questions'),
            Tab(text: 'Flipcards'),
            Tab(text: 'User Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _TracksTab(),
          _ModulesTab(),
          _ContentTab(),
          _QuestionsTab(),
          _FlipcardsTab(),
          _UserProfileTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// Constants
// =============================================================================

const _kTrackColors = <String, int>{
  'KOTLIN': 0xFF8B5CF6,
  'SWIFT': 0xFFF14C33,
  'FLUTTER': 0xFF2F6FED,
  'REACT_NATIVE': 0xFF61DAFB,
};

const _kTrackCategories = [
  'Mobile',
  'Backend',
  'Frontend',
  'Full Stack',
  'Data',
  'DevOps',
];

const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

const _kCodeLanguages = [
  'Kotlin',
  'Swift',
  'Dart',
  'JavaScript',
  'TypeScript',
  'Java',
  'Python',
  'Go',
  'Rust',
  'C++',
  'SQL',
  'Bash',
  'Other',
];

// =============================================================================
// Tracks Tab — CRUD for tracks collection
// =============================================================================

class _TracksTab extends StatefulWidget {
  const _TracksTab();
  @override
  State<_TracksTab> createState() => _TracksTabState();
}

class _TracksTabState extends State<_TracksTab> {
  List<Map<String, dynamic>> _tracks = [];
  bool _loading = false;
  bool _showForm = false;
  String? _editingId;

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _formCategory = 'Mobile';
  int _formColor = 0xFF8B5CF6;
  int _formOrder = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      setState(() {
        _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openAddForm() {
    _idCtrl.clear();
    _nameCtrl.clear();
    _descCtrl.clear();
    _formCategory = 'Mobile';
    _formColor = 0xFF8B5CF6;
    _formOrder = _tracks.length;
    _editingId = null;
    setState(() => _showForm = true);
  }

  void _openEditForm(Map<String, dynamic> track) {
    _idCtrl.text = track['id'] ?? '';
    _nameCtrl.text = track['name'] ?? '';
    _descCtrl.text = track['description'] ?? '';
    _formCategory = track['category'] ?? 'Mobile';
    _formColor = track['color'] ?? 0xFF8B5CF6;
    _formOrder = track['order'] ?? 0;
    _editingId = track['id'];
    setState(() => _showForm = true);
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
    });
  }

  Future<void> _saveTrack() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final docId = _editingId ?? _idCtrl.text.trim().toUpperCase();
      await FirebaseFirestore.instance.collection('tracks').doc(docId).set({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _formCategory,
        'color': _formColor,
        'order': _formOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Track $docId saved.')));
        _closeForm();
        _loadTracks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteTrack(String id) async {
    try {
      await FirebaseFirestore.instance.collection('tracks').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Track $id deleted.')));
        _loadTracks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) return _buildFormView();
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _tracks.isEmpty
              ? Center(
                  child: Text(
                    'No tracks yet.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _tracks.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final t = _tracks[i];
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: BoxDecoration(
                              color: Color(t['color'] ?? 0xFF888888),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['name'] ?? t['id'],
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if ((t['category'] ?? '').toString().isNotEmpty)
                                  Text(
                                    t['category'],
                                    style: AppTypography.codeSm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            'order: ${t['order'] ?? 0}',
                            style: AppTypography.codeSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: () => _openEditForm(t),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            color: AppColors.primary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          IconButton(
                            onPressed: () => _deleteTrack(t['id']),
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            color: AppColors.error,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Track'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              IconButton(
                onPressed: _closeForm,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _editingId != null ? 'Edit Track' : 'New Track',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_editingId == null) ...[
                    _SectionLabel('TRACK ID'),
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _idCtrl,
                      hint: 'e.g. KOTLIN',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],
                  _SectionLabel('NAME'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _nameCtrl,
                    hint: 'e.g. Kotlin',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('DESCRIPTION'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _descCtrl,
                    hint: 'Track description',
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('CATEGORY'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _formCategory,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        items: _kTrackCategories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _formCategory = v ?? 'Mobile'),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('COLOR'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _formColor,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        items: _kTrackColors.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12.r,
                                      height: 12.r,
                                      decoration: BoxDecoration(
                                        color: Color(e.value),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(e.key),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _formColor = v ?? 0xFF888888),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('ORDER'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: TextEditingController(text: '$_formOrder'),
                    hint: '0',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _editingId != null ? 'Update Track' : 'Save Track',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Modules Tab — tracks/{id}/modules subcollection
// =============================================================================

class _ModulesTab extends StatefulWidget {
  const _ModulesTab();
  @override
  State<_ModulesTab> createState() => _ModulesTabState();
}

class _ModulesTabState extends State<_ModulesTab> {
  String _selectedTrackId = 'KOTLIN';
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _modules = [];
  bool _loadingModules = false;
  bool _showForm = false;
  String? _editingId;

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _objectivesCtrl = TextEditingController();
  int _formOrder = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _objectivesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() => _loadingModules = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (_tracks.isNotEmpty) {
        _selectedTrackId = _tracks.first['id'] as String;
      }
      setState(() => _loadingModules = false);
      await _loadModules();
    } catch (e) {
      setState(() => _loadingModules = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadModules() async {
    setState(() => _loadingModules = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .orderBy('order')
          .get();
      setState(() {
        _modules = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loadingModules = false;
      });
    } catch (e) {
      setState(() => _loadingModules = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openAddForm() {
    _idCtrl.clear();
    _titleCtrl.clear();
    _descCtrl.clear();
    _objectivesCtrl.clear();
    _formOrder = _modules.length;
    _editingId = null;
    setState(() => _showForm = true);
  }

  void _openEditForm(Map<String, dynamic> mod) {
    _idCtrl.text = mod['id'] ?? '';
    _titleCtrl.text = mod['title'] ?? '';
    _descCtrl.text = mod['description'] ?? '';
    final objectives = mod['learningObjectives'] as List<dynamic>? ?? [];
    _objectivesCtrl.text = objectives.join('\n');
    _formOrder = mod['order'] ?? 0;
    _editingId = mod['id'];
    setState(() => _showForm = true);
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
    });
  }

  Future<void> _saveModule() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final docId =
          _editingId ??
          (_idCtrl.text.trim().isNotEmpty
              ? _idCtrl.text.trim()
              : '${_selectedTrackId}_MOD_${DateTime.now().millisecondsSinceEpoch}');

      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'learningObjectives': _objectivesCtrl.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'order': _formOrder,
        'trackId': _selectedTrackId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .doc(docId)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Module $docId saved.')));
        _closeForm();
        _loadModules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteModule(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .doc(id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Module $id deleted.')));
        _loadModules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) return _buildFormView();
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              _SectionLabel('TRACK'),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTrackId,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      items: _tracks
                          .map(
                            (t) => DropdownMenuItem(
                              value: t['id'] as String,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12.r,
                                    height: 12.r,
                                    decoration: BoxDecoration(
                                      color: Color(t['color'] ?? 0xFF888888),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(t['name'] ?? t['id']),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(
                          () => _selectedTrackId = v ?? _selectedTrackId,
                        );
                        _loadModules();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingModules
              ? const Center(child: CircularProgressIndicator())
              : _modules.isEmpty
              ? Center(
                  child: Text(
                    'No modules in this track yet.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _modules.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final m = _modules[i];
                    final content = m['content'] as List<dynamic>? ?? [];
                    final objectives =
                        m['learningObjectives'] as List<dynamic>? ?? [];
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.r,
                                  vertical: 2.r,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Text(
                                  '#${m['order'] ?? i}',
                                  style: AppTypography.codeSm.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  m['title'] ?? m['id'],
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openEditForm(m),
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              IconButton(
                                onPressed: () => _deleteModule(m['id']),
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                ),
                                color: AppColors.error,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          if ((m['description'] ?? '')
                              .toString()
                              .isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              m['description'],
                              style: AppTypography.codeSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(
                                '${content.length} content block${content.length == 1 ? '' : 's'}',
                                style: AppTypography.codeSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              if (objectives.isNotEmpty) ...[
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${objectives.length} objective${objectives.length == 1 ? '' : 's'}',
                                  style: AppTypography.codeSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Module'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              IconButton(
                onPressed: _closeForm,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _editingId != null
                      ? 'Edit Module'
                      : 'New Module — $_selectedTrackId',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_editingId == null) ...[
                    _SectionLabel('MODULE ID'),
                    SizedBox(height: AppSpacing.xs),
                    _Field(controller: _idCtrl, hint: 'e.g. basics_builders'),
                    SizedBox(height: AppSpacing.md),
                  ],
                  _SectionLabel('TITLE'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _titleCtrl,
                    hint: 'e.g. Basics & Builders',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('DESCRIPTION'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _descCtrl,
                    hint: 'Module description',
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('LEARNING OBJECTIVES (one per line)'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _objectivesCtrl,
                    hint: 'Understand Kotlin basics\nBuild simple apps',
                    maxLines: 4,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('ORDER'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _formOrder,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        items: List.generate(
                          _modules.length + 1,
                          (i) => DropdownMenuItem(value: i, child: Text('$i')),
                        ),
                        onChanged: (v) => setState(() => _formOrder = v ?? 0),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveModule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _editingId != null
                                ? 'Update Module'
                                : 'Save Module',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Content Tab — tracks/{id}/modules/{id} content blocks
// =============================================================================

class _ContentTab extends StatefulWidget {
  const _ContentTab();
  @override
  State<_ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<_ContentTab> {
  String _selectedTrackId = 'KOTLIN';
  String? _selectedModuleId;
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _modules = [];
  bool _loadingModules = false;
  bool _loadingContent = false;

  List<Map<String, dynamic>> _contentBlocks = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (_tracks.isNotEmpty) {
        _selectedTrackId = _tracks.first['id'] as String;
      }
      setState(() {});
      await _loadModules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadModules() async {
    setState(() {
      _loadingModules = true;
      _selectedModuleId = null;
      _contentBlocks = [];
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .orderBy('order')
          .get();
      _modules = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      setState(() => _loadingModules = false);
    } catch (e) {
      setState(() => _loadingModules = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadContent() async {
    if (_selectedModuleId == null) return;
    setState(() => _loadingContent = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .doc(_selectedModuleId)
          .get();
      final data = doc.data();
      final raw = data?['content'] as List<dynamic>? ?? [];
      setState(() {
        _contentBlocks = raw.cast<Map<String, dynamic>>();
        _loadingContent = false;
      });
    } catch (e) {
      setState(() => _loadingContent = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addBlock(String type) {
    setState(() => _contentBlocks.add({'type': type}));
  }

  void _removeBlock(int i) {
    setState(() => _contentBlocks.removeAt(i));
  }

  void _updateBlock(int i, String key, dynamic value) {
    setState(() => _contentBlocks[i][key] = value);
  }

  Future<void> _saveContent() async {
    if (_selectedModuleId == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .doc(_selectedModuleId)
          .update({
            'content': _contentBlocks,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Content saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Column(
            children: [
              Row(
                children: [
                  _SectionLabel('TRACK'),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTrackId,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceContainerHigh,
                          items: _tracks
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t['id'] as String,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12.r,
                                        height: 12.r,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            t['color'] ?? 0xFF888888,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(t['name'] ?? t['id']),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(
                              () => _selectedTrackId = v ?? _selectedTrackId,
                            );
                            _loadModules();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _SectionLabel('MODULE'),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _loadingModules
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedModuleId,
                                isExpanded: true,
                                dropdownColor: AppColors.surfaceContainerHigh,
                                hint: Text(
                                  'Select a module',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                items: _modules
                                    .map(
                                      (m) => DropdownMenuItem<String>(
                                        value: m['id'] as String,
                                        child: Text(
                                          m['title'] as String? ??
                                              m['id'] as String,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedModuleId = v);
                                  _loadContent();
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedModuleId == null
              ? Center(
                  child: Text(
                    'Select a module to manage its content.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : _loadingContent
              ? const Center(child: CircularProgressIndicator())
              : _contentBlocks.isEmpty
              ? Center(
                  child: Text(
                    'No content blocks yet. Add one below.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _contentBlocks.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final block = _contentBlocks[i];
                    final type = block['type'] ?? 'explanation';
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                type == 'heading'
                                    ? Icons.title
                                    : type == 'code'
                                    ? Icons.code
                                    : Icons.notes,
                                size: 14.r,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4.r),
                              Text(
                                '${type.toString().toUpperCase()} ${i + 1}',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeBlock(i),
                                icon: const Icon(Icons.close_rounded, size: 16),
                                color: AppColors.error,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xs),
                          if (type == 'heading')
                            _ContentTextField(
                              value: block['text'] ?? '',
                              hint: 'Heading text',
                              onChanged: (v) => _updateBlock(i, 'text', v),
                            )
                          else if (type == 'explanation')
                            _ContentTextField(
                              value: block['text'] ?? '',
                              hint: 'Explanation text',
                              maxLines: 4,
                              onChanged: (v) => _updateBlock(i, 'text', v),
                            )
                          else ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: AppRadius.radiusSm,
                                border: Border.all(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: block['language'] ?? 'Kotlin',
                                  isDense: true,
                                  isExpanded: true,
                                  dropdownColor: AppColors.surfaceContainerHigh,
                                  style: AppTypography.codeSm.copyWith(
                                    color: AppColors.onSurface,
                                    fontSize: 12.sp,
                                  ),
                                  items: _kCodeLanguages
                                      .map(
                                        (l) => DropdownMenuItem(
                                          value: l,
                                          child: Text(l),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => _updateBlock(
                                    i,
                                    'language',
                                    v ?? 'Kotlin',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.r),
                            _ContentTextField(
                              value: block['code'] ?? '',
                              hint: 'Paste code here...',
                              maxLines: 10,
                              onChanged: (v) => _updateBlock(i, 'code', v),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_selectedModuleId != null)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addBlock('heading'),
                          icon: const Icon(Icons.title, size: 16),
                          label: const Text('Heading'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addBlock('explanation'),
                          icon: const Icon(Icons.notes, size: 16),
                          label: const Text('Text'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addBlock('code'),
                          icon: const Icon(Icons.code, size: 16),
                          label: const Text('Code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveContent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                      child: _saving
                          ? SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Content'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ContentTextField extends StatelessWidget {
  const _ContentTextField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 12.r,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

// =============================================================================
// Questions Tab — tracks/{id}/modules/{id}/questions subcollection
// =============================================================================

class _QuestionsTab extends StatefulWidget {
  const _QuestionsTab();
  @override
  State<_QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<_QuestionsTab> {
  String _selectedTrackId = 'KOTLIN';
  String? _selectedModuleId;
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _modules = [];
  bool _loadingTracks = false;
  bool _loadingModules = false;
  String _selectedLevel = 'BEGINNER';

  final _formKey = GlobalKey<FormState>();
  final _docIdCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _optionCtrls = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  final _codeHeaderCtrl = TextEditingController();
  final _codeLangCtrl = TextEditingController();
  final _codeLinesCtrl = TextEditingController();
  bool _includeCode = false;
  bool _saving = false;
  bool _showForm = false;

  List<Map<String, dynamic>> _questions = [];
  bool _loadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _docIdCtrl.dispose();
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    _codeHeaderCtrl.dispose();
    _codeLangCtrl.dispose();
    _codeLinesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() => _loadingTracks = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (_tracks.isNotEmpty) {
        _selectedTrackId = _tracks.first['id'] as String;
      }
      setState(() => _loadingTracks = false);
      await _loadModules();
    } catch (e) {
      setState(() => _loadingTracks = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadModules() async {
    setState(() {
      _loadingModules = true;
      _selectedModuleId = null;
      _questions = [];
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .orderBy('order')
          .get();
      _modules = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      setState(() => _loadingModules = false);
      await _loadAllQuestionsForTrack();
    } catch (e) {
      setState(() => _loadingModules = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadAllQuestionsForTrack() async {
    setState(() => _loadingQuestions = true);
    try {
      final allQuestions = <Map<String, dynamic>>[];
      for (final mod in _modules) {
        final qSnap = await FirebaseFirestore.instance
            .collection('tracks')
            .doc(_selectedTrackId)
            .collection('modules')
            .doc(mod['id'] as String)
            .collection('questions')
            .get();
        for (final qDoc in qSnap.docs) {
          allQuestions.add({
            'id': qDoc.id,
            'moduleId': mod['id'],
            'moduleTitle': mod['title'] ?? mod['id'],
            ...qDoc.data(),
          });
        }
      }
      setState(() {
        _questions = allQuestions;
        _loadingQuestions = false;
      });
    } catch (e) {
      setState(() => _loadingQuestions = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openAddForm() {
    _docIdCtrl.clear();
    _questionCtrl.clear();
    for (final c in _optionCtrls) {
      c.clear();
    }
    _correctIndex = 0;
    _codeHeaderCtrl.clear();
    _codeLangCtrl.clear();
    _codeLinesCtrl.clear();
    _includeCode = false;
    setState(() => _showForm = true);
  }

  void _closeForm() => setState(() => _showForm = false);

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModuleId == null) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'question': _questionCtrl.text.trim(),
        'options': _optionCtrls.map((c) => c.text.trim()).toList(),
        'correctIndex': _correctIndex,
        'level': _selectedLevel,
      };

      if (_includeCode &&
          _codeHeaderCtrl.text.isNotEmpty &&
          _codeLangCtrl.text.isNotEmpty) {
        data['codeHeader'] = _codeHeaderCtrl.text.trim();
        data['codeLanguage'] = _codeLangCtrl.text.trim();
        data['codeLines'] = _codeLinesCtrl.text
            .split('\n')
            .where((l) => l.isNotEmpty)
            .toList();
      }

      final docId = _docIdCtrl.text.trim().isNotEmpty
          ? _docIdCtrl.text.trim()
          : '${_selectedModuleId}_Q${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('modules')
          .doc(_selectedModuleId)
          .collection('questions')
          .doc(docId)
          .set(data);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Question saved.')));
        _closeForm();
        _loadAllQuestionsForTrack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Map<String, dynamic>> get _filteredQuestions =>
      _questions.where((q) => q['level'] == _selectedLevel).toList();

  @override
  Widget build(BuildContext context) {
    if (_showForm) return _buildFormView();
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Column(
            children: [
              Row(
                children: [
                  _SectionLabel('TRACK'),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTrackId,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceContainerHigh,
                          items: _tracks
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t['id'] as String,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12.r,
                                        height: 12.r,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            t['color'] ?? 0xFF888888,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(t['name'] ?? t['id']),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(
                              () => _selectedTrackId = v ?? _selectedTrackId,
                            );
                            _loadModules();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              for (final level in _kLevels)
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Text(level),
                    selected: _selectedLevel == level,
                    onSelected: (_) => setState(() => _selectedLevel = level),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTypography.codeSm.copyWith(
                      color: _selectedLevel == level
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: _selectedLevel == level
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _loadingTracks || _loadingModules || _loadingQuestions
              ? const Center(child: CircularProgressIndicator())
              : _filteredQuestions.isEmpty
              ? Center(
                  child: Text(
                    'No $_selectedLevel questions in this track.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _filteredQuestions.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final q = _filteredQuestions[i];
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.r,
                                  vertical: 2.r,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Text(
                                  q['level'] ?? '?',
                                  style: AppTypography.codeSm.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.r,
                                    vertical: 2.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    q['moduleTitle'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.codeSm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  q['question'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if ((q['codeLanguage'] ?? '')
                              .toString()
                              .isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.code,
                                    size: 12.r,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.r),
                                  Text(
                                    '${q['codeLanguage']} \u2022 ${q['codeLines']?.length ?? 0} lines',
                                    style: AppTypography.codeSm.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_modules.isNotEmpty)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openAddForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              IconButton(
                onPressed: _closeForm,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'New Question — $_selectedTrackId',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel('MODULE'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedModuleId,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        hint: Text(
                          'Select a module',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                        items: _modules
                            .map(
                              (m) => DropdownMenuItem<String>(
                                value: m['id'] as String,
                                child: Text(
                                  m['title'] as String? ?? m['id'] as String,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedModuleId = v),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('LEVEL'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        items: _kLevels
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLevel = v ?? 'BEGINNER'),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('DOCUMENT ID (auto if empty)'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(controller: _docIdCtrl, hint: 'e.g. KTN_COR_Q0'),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('QUESTION'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _questionCtrl,
                    hint: 'Question text',
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('OPTIONS'),
                  SizedBox(height: AppSpacing.xs),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: _correctIndex,
                            onChanged: (v) =>
                                setState(() => _correctIndex = v ?? 0),
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Expanded(
                            child: _Field(
                              controller: _optionCtrls[i],
                              hint: 'Option ${i + 1}',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Correct answer: option ${_correctIndex + 1}',
                    style: AppTypography.codeSm.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _SectionLabel('CODE SNIPPET'),
                      const Spacer(),
                      Switch(
                        value: _includeCode,
                        onChanged: (v) => setState(() => _includeCode = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_includeCode) ...[
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _codeHeaderCtrl,
                      hint: 'Header (e.g. [DATA_SYNC])',
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _Field(controller: _codeLangCtrl, hint: 'Language'),
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _codeLinesCtrl,
                      hint: 'Code lines (one per line)',
                      maxLines: 6,
                    ),
                  ],
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save Question'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Flipcards Tab — tracks/{id}/flipcards subcollection
// =============================================================================

class _FlipcardsTab extends StatefulWidget {
  const _FlipcardsTab();
  @override
  State<_FlipcardsTab> createState() => _FlipcardsTabState();
}

class _FlipcardsTabState extends State<_FlipcardsTab> {
  String _selectedTrackId = 'KOTLIN';
  List<Map<String, dynamic>> _tracks = [];
  bool _loadingTracks = false;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _codeHeaderCtrl = TextEditingController();
  final _codeLangCtrl = TextEditingController();
  final _codeLinesCtrl = TextEditingController();
  bool _includeCode = false;
  bool _saving = false;
  bool _showForm = false;
  String? _editingId;

  List<Map<String, dynamic>> _flipcards = [];
  bool _loadingCards = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _codeHeaderCtrl.dispose();
    _codeLangCtrl.dispose();
    _codeLinesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() => _loadingTracks = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (_tracks.isNotEmpty) {
        _selectedTrackId = _tracks.first['id'] as String;
      }
      setState(() => _loadingTracks = false);
      await _loadFlipcards();
    } catch (e) {
      setState(() => _loadingTracks = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadFlipcards() async {
    setState(() => _loadingCards = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('flipcards')
          .get();
      setState(() {
        _flipcards = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loadingCards = false;
      });
    } catch (e) {
      setState(() => _loadingCards = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openAddForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _codeHeaderCtrl.clear();
    _codeLangCtrl.clear();
    _codeLinesCtrl.clear();
    _includeCode = false;
    _editingId = null;
    setState(() => _showForm = true);
  }

  void _openEditForm(Map<String, dynamic> flipcard) {
    _titleCtrl.text = flipcard['term'] ?? '';
    _descCtrl.text = flipcard['definition'] ?? '';
    _codeHeaderCtrl.text = flipcard['codeHeader'] ?? '';
    _codeLangCtrl.text = flipcard['codeLanguage'] ?? '';
    _codeLinesCtrl.text = ((flipcard['codeLines'] as List<dynamic>?) ?? [])
        .join('\n');
    _includeCode = (flipcard['codeHeader'] ?? '').toString().isNotEmpty;
    _editingId = flipcard['id'];
    setState(() => _showForm = true);
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
    });
  }

  Future<void> _saveFlipcard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'term': _titleCtrl.text.trim(),
        'definition': _descCtrl.text.trim(),
      };

      if (_includeCode &&
          _codeHeaderCtrl.text.isNotEmpty &&
          _codeLangCtrl.text.isNotEmpty) {
        data['codeHeader'] = _codeHeaderCtrl.text.trim();
        data['codeLanguage'] = _codeLangCtrl.text.trim();
        data['codeLines'] = _codeLinesCtrl.text
            .split('\n')
            .where((l) => l.isNotEmpty)
            .toList();
      }

      final ref = FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('flipcards');
      if (_editingId != null) {
        await ref.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await ref.add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId != null ? 'Flipcard updated.' : 'Flipcard saved.',
            ),
          ),
        );
        _closeForm();
        _loadFlipcards();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteFlipcard(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('tracks')
          .doc(_selectedTrackId)
          .collection('flipcards')
          .doc(id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Flipcard $id deleted.')));
        _loadFlipcards();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) return _buildFormView();
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              _SectionLabel('TRACK'),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTrackId,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      items: _tracks
                          .map(
                            (t) => DropdownMenuItem(
                              value: t['id'] as String,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12.r,
                                    height: 12.r,
                                    decoration: BoxDecoration(
                                      color: Color(t['color'] ?? 0xFF888888),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(t['name'] ?? t['id']),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(
                          () => _selectedTrackId = v ?? _selectedTrackId,
                        );
                        _loadFlipcards();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingTracks || _loadingCards
              ? const Center(child: CircularProgressIndicator())
              : _flipcards.isEmpty
              ? Center(
                  child: Text(
                    'No flipcards in this track.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _flipcards.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final fc = _flipcards[i];
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fc['term'] ?? '',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              IconButton(
                                onPressed: () => _openEditForm(fc),
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              IconButton(
                                onPressed: () => _deleteFlipcard(fc['id']),
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                ),
                                color: AppColors.error,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          if ((fc['definition'] ?? '')
                              .toString()
                              .isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              fc['definition'],
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if ((fc['codeLanguage'] ?? '')
                              .toString()
                              .isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.code,
                                    size: 12.r,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.r),
                                  Text(
                                    '${fc['codeLanguage']} \u2022 ${fc['codeLines']?.length ?? 0} lines',
                                    style: AppTypography.codeSm.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Flipcard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              IconButton(
                onPressed: _closeForm,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _editingId != null
                      ? 'Edit Flipcard — $_selectedTrackId'
                      : 'New Flipcard — $_selectedTrackId',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel('TITLE (TERM)'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _titleCtrl,
                    hint: 'Front of the flashcard',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('DESCRIPTION (DEFINITION)'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _descCtrl,
                    hint: 'Back of the flashcard',
                    maxLines: 5,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _SectionLabel('CODE SNIPPET'),
                      const Spacer(),
                      Switch(
                        value: _includeCode,
                        onChanged: (v) => setState(() => _includeCode = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_includeCode) ...[
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _codeHeaderCtrl,
                      hint: 'Header (e.g. main.kt)',
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _Field(controller: _codeLangCtrl, hint: 'Language'),
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _codeLinesCtrl,
                      hint: 'Code lines (one per line)',
                      maxLines: 6,
                    ),
                  ],
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveFlipcard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _editingId != null
                                ? 'Update Flipcard'
                                : 'Save Flipcard',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// User Profile Tab
// =============================================================================

class _UserProfileTab extends StatefulWidget {
  const _UserProfileTab();

  @override
  State<_UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<_UserProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _runtimeLevelCtrl = TextEditingController(text: 'senior');
  final _tracksCtrl = TextEditingController(text: 'kotlin, flutter');
  bool _saving = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _runtimeLevelCtrl.dispose();
    _tracksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No signed-in user.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final tracks = _tracksCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'userEmail': _emailCtrl.text.trim().isNotEmpty
            ? _emailCtrl.text.trim()
            : user.email,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'authProvider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'unknown',
        'tracks': tracks,
        'runtimeLevel': _runtimeLevelCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User profile saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed in as',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email ?? user.uid,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      'UID: ${user.uid}',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            _SectionLabel('EMAIL'),
            SizedBox(height: AppSpacing.xs),
            _Field(
              controller: _emailCtrl,
              hint: user?.email ?? 'user@example.com',
            ),
            SizedBox(height: AppSpacing.md),

            _SectionLabel('RUNTIME LEVEL'),
            SizedBox(height: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _runtimeLevelCtrl.text,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  items: const [
                    DropdownMenuItem(value: 'junior', child: Text('Junior')),
                    DropdownMenuItem(value: 'mid', child: Text('Mid-Level')),
                    DropdownMenuItem(value: 'senior', child: Text('Senior')),
                  ],
                  onChanged: (v) =>
                      setState(() => _runtimeLevelCtrl.text = v ?? 'mid'),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            _SectionLabel('SELECTED TRACKS (comma-separated)'),
            SizedBox(height: AppSpacing.xs),
            _Field(
              controller: _tracksCtrl,
              hint: 'kotlin, flutter',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.r),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
              child: _saving
                  ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save User Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Shared widgets
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelMono.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 11.sp,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    this.hint,
    this.label,
    this.maxLines = 1,
    this.isDense = false,
    this.validator,
  });

  final TextEditingController controller;
  final String? hint;
  final String? label;
  final int maxLines;
  final bool isDense;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: isDense ? 8.r : 12.r,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
