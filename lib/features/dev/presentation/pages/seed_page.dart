import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

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
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Firestore Admin'),
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.onSurface,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Topics'),
            Tab(text: 'Questions'),
            Tab(text: 'Progress'),
            Tab(text: 'User Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _TopicsTab(),
          _QuestionsTab(),
          _ProgressTab(),
          _UserProfileTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// Topics Tab — Track → Topics list → Add/Edit topic with modules
// =============================================================================

const _kTracks = <String, int>{
  'KOTLIN': 0xFF8B5CF6,
  'SWIFT': 0xFFF14C33,
  'FLUTTER': 0xFF2F6FED,
  'REACT_NATIVE': 0xFF61DAFB,
};

const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

const _kCodeLanguages = [
  'Kotlin', 'Swift', 'Dart', 'JavaScript', 'TypeScript',
  'Java', 'Python', 'Go', 'Rust', 'C++', 'SQL', 'Bash', 'Other',
];

class _TopicsTab extends StatefulWidget {
  const _TopicsTab();
  @override
  State<_TopicsTab> createState() => _TopicsTabState();
}

class _TopicsTabState extends State<_TopicsTab> {
  String _selectedTrack = 'KOTLIN';
  List<Map<String, dynamic>> _topics = [];
  bool _loading = false;
  bool _showForm = false;
  String? _editingTopicId;

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _formLevel = 'INTERMEDIATE';
  final _modules = <_ModuleEntry>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final m in _modules) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTopics() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('topics')
          .where('trackName', isEqualTo: _selectedTrack)
          .get();
      setState(() {
        _topics = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading topics: $e')),
        );
      }
    }
  }

  void _openAddForm() {
    _idCtrl.clear();
    _titleCtrl.clear();
    _descCtrl.clear();
    _formLevel = 'INTERMEDIATE';
    for (final m in _modules) {
      m.dispose();
    }
    _modules.clear();
    _editingTopicId = null;
    setState(() => _showForm = true);
  }

  void _openEditForm(Map<String, dynamic> topic) {
    _idCtrl.text = topic['id'] ?? '';
    _titleCtrl.text = topic['title'] ?? '';
    _descCtrl.text = topic['description'] ?? '';
    _formLevel = topic['level'] ?? 'INTERMEDIATE';
    for (final m in _modules) {
      m.dispose();
    }
    _modules.clear();
    final rawModules = topic['modules'] as List<dynamic>? ?? [];
    for (final rm in rawModules) {
      final entry = _ModuleEntry();
      entry.titleCtrl.text = rm['title'] ?? '';
      entry.descCtrl.text = rm['description'] ?? '';
      entry.taskCountCtrl.text = '${rm['taskCount'] ?? 0}';
      entry.durationCtrl.text = rm['duration'] ?? '';
      final rawContent = rm['content'] as List<dynamic>? ?? [];
      for (final rc in rawContent) {
        final typeStr = rc['type'] ?? 'explanation';
        final type = _ContentType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => _ContentType.explanation,
        );
        final block = _ContentBlock(type: type);
        block.headingCtrl.text = rc['text'] ?? '';
        block.textCtrl.text = rc['text'] ?? '';
        block.language = rc['language'] ?? 'Kotlin';
        block.codeCtrl.text = rc['code'] ?? '';
        entry.contentBlocks.add(block);
      }
      _modules.add(entry);
    }
    _editingTopicId = topic['id'];
    setState(() => _showForm = true);
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingTopicId = null;
    });
  }

  void _addModule() => setState(() => _modules.add(_ModuleEntry()));

  void _removeModule(int i) {
    setState(() {
      _modules[i].dispose();
      _modules.removeAt(i);
    });
  }

  Map<String, dynamic> _moduleToMap(_ModuleEntry m) {
    final contentBlocks = <Map<String, dynamic>>[];
    for (final block in m.contentBlocks) {
      final b = <String, dynamic>{'type': block.type.name};
      if (block.type == _ContentType.heading) {
        b['text'] = block.headingCtrl.text.trim();
      } else if (block.type == _ContentType.explanation) {
        b['text'] = block.textCtrl.text.trim();
      } else if (block.type == _ContentType.code) {
        b['language'] = block.language;
        b['code'] = block.codeCtrl.text;
      }
      contentBlocks.add(b);
    }
    return {
      'title': m.titleCtrl.text.trim(),
      'description': m.descCtrl.text.trim(),
      'taskCount': int.tryParse(m.taskCountCtrl.text) ?? 0,
      'duration': m.durationCtrl.text.trim(),
      if (contentBlocks.isNotEmpty) 'content': contentBlocks,
    };
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final modules = _modules.map(_moduleToMap).toList();
      final docId = _editingTopicId ?? _idCtrl.text.trim();

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(docId)
          .set({
        'level': _formLevel,
        'trackName': _selectedTrack,
        'trackColor': _kTracks[_selectedTrack] ?? 0,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'modules': modules,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic $docId saved.')),
        );
        _closeForm();
        _loadTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteTopic(String id) async {
    try {
      await FirebaseFirestore.instance.collection('topics').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic $id deleted.')),
        );
        _loadTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        // Track selector
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                      value: _selectedTrack,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      items: _kTracks.keys
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12.r,
                                      height: 12.r,
                                      decoration: BoxDecoration(
                                        color: Color(_kTracks[t]!),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(t),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedTrack = v ?? 'KOTLIN');
                        _loadTopics();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Topic list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _topics.isEmpty
                  ? Center(
                      child: Text(
                        'No topics for $_selectedTrack yet.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: _topics.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final t = _topics[i];
                        final modules = t['modules'] as List<dynamic>? ?? [];
                        return Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(
                                color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.r,
                                        vertical: 3.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius:
                                          AppRadius.radiusSm,
                                    ),
                                    child: Text(
                                      t['level'] ?? '',
                                      style: AppTypography.codeSm
                                          .copyWith(
                                        color: AppColors
                                            .onPrimaryContainer,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      t['title'] ?? t['id'],
                                      style: AppTypography.bodyMd
                                          .copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _openEditForm(t),
                                    icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 18),
                                    color: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(),
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteTopic(t['id']),
                                    icon: const Icon(
                                        Icons.delete_rounded,
                                        size: 18),
                                    color: AppColors.error,
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(),
                                  ),
                                ],
                              ),
                              if ((t['description'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  t['description'],
                                  style: AppTypography.codeSm
                                      .copyWith(
                                    color: AppColors
                                        .onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                '${modules.length} module${modules.length == 1 ? '' : 's'}',
                                style: AppTypography.codeSm
                                    .copyWith(
                                  color:
                                      AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        // Add button
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Topic'),
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
        // Form header
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                  _editingTopicId != null
                      ? 'Edit Topic'
                      : 'New Topic — $_selectedTrack',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Form body
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_editingTopicId == null) ...[
                    _SectionLabel('TOPIC ID'),
                    SizedBox(height: AppSpacing.xs),
                    _Field(
                      controller: _idCtrl,
                      hint: 'e.g. KTN_COR',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],
                  _SectionLabel('TITLE'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _titleCtrl,
                    hint: 'e.g. Kotlin Coroutines',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('DESCRIPTION'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _descCtrl,
                    hint: 'Topic description',
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('LEVEL'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                      border:
                          Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _formLevel,
                        isExpanded: true,
                        dropdownColor:
                            AppColors.surfaceContainerHigh,
                        items: _kLevels
                            .map((l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(l),
                                ))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _formLevel = v ?? 'INTERMEDIATE'),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // Modules
                  Row(
                    children: [
                      _SectionLabel('MODULES'),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addModule,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Module'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < _modules.length; i++)
                    _ModuleCard(
                      entry: _modules[i],
                      index: i,
                      onRemove: () => _removeModule(i),
                    ),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveTopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding:
                          EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child:
                                const CircularProgressIndicator(
                                    strokeWidth: 2),
                          )
                        : Text(_editingTopicId != null
                            ? 'Update Topic'
                            : 'Save Topic'),
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
// Module entry + card (with content blocks)
// =============================================================================

enum _ContentType { heading, explanation, code }

class _ContentBlock {
  _ContentBlock({required this.type});
  final _ContentType type;
  final headingCtrl = TextEditingController();
  final textCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  String language = 'Kotlin';

  void dispose() {
    headingCtrl.dispose();
    textCtrl.dispose();
    codeCtrl.dispose();
  }
}

class _ModuleEntry {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final taskCountCtrl = TextEditingController(text: '5');
  final durationCtrl = TextEditingController(text: '~20m');
  final contentBlocks = <_ContentBlock>[];

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    taskCountCtrl.dispose();
    durationCtrl.dispose();
    for (final b in contentBlocks) {
      b.dispose();
    }
  }
}

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  final _ModuleEntry entry;
  final int index;
  final VoidCallback onRemove;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  void _addContentBlock(_ContentType type) {
    setState(() =>
        widget.entry.contentBlocks.add(_ContentBlock(type: type)));
  }

  void _removeContentBlock(int i) {
    setState(() {
      widget.entry.contentBlocks[i].dispose();
      widget.entry.contentBlocks.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.entry;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Module ${widget.index + 1}',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onRemove,
                icon:
                    const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          _Field(controller: m.titleCtrl, hint: 'Module title'),
          SizedBox(height: AppSpacing.xs),
          _Field(
              controller: m.descCtrl,
              hint: 'Module description',
              maxLines: 2),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _Field(
                    controller: m.taskCountCtrl,
                    hint: 'Tasks',
                    isDense: true),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Field(
                    controller: m.durationCtrl,
                    hint: 'Duration',
                    isDense: true),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Content blocks header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 6.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Row(
              children: [
                Text(
                  'CONTENT',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                const Spacer(),
                _ContentAddButton(
                  label: 'Heading',
                  icon: Icons.title,
                  onTap: () => _addContentBlock(
                      _ContentType.heading),
                ),
                _ContentAddButton(
                  label: 'Text',
                  icon: Icons.notes,
                  onTap: () => _addContentBlock(
                      _ContentType.explanation),
                ),
                _ContentAddButton(
                  label: 'Code',
                  icon: Icons.code,
                  onTap: () => _addContentBlock(
                      _ContentType.code),
                ),
              ],
            ),
          ),
          for (var i = 0;
              i < m.contentBlocks.length;
              i++)
            _ContentBlockCard(
              block: m.contentBlocks[i],
              index: i,
              onRemove: () => _removeContentBlock(i),
            ),
        ],
      ),
    );
  }
}

class _ContentAddButton extends StatelessWidget {
  const _ContentAddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 6.r, vertical: 4.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: AppColors.primary),
            SizedBox(width: 2.r),
            Text(
              label,
              style: AppTypography.codeSm.copyWith(
                color: AppColors.primary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentBlockCard extends StatelessWidget {
  const _ContentBlockCard({
    required this.block,
    required this.index,
    required this.onRemove,
  });

  final _ContentBlock block;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(
          color:
              AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                block.type == _ContentType.heading
                    ? Icons.title
                    : block.type == _ContentType.explanation
                        ? Icons.notes
                        : Icons.code,
                size: 14.r,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.r),
              Text(
                '${block.type.name.toUpperCase()} ${index + 1}',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded,
                    size: 14),
                color: AppColors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 4.r),
          if (block.type == _ContentType.heading)
            _Field(
              controller: block.headingCtrl,
              hint: 'Heading text',
              isDense: true,
            )
          else if (block.type ==
              _ContentType.explanation)
            _Field(
              controller: block.textCtrl,
              hint: 'Explanation text',
              maxLines: 4,
              isDense: true,
            )
          else ...[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.radiusSm,
                border: Border.all(
                    color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: block.language,
                  isDense: true,
                  isExpanded: true,
                  dropdownColor:
                      AppColors.surfaceContainerHigh,
                  style: AppTypography.codeSm.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12.sp,
                  ),
                  items: _kCodeLanguages
                      .map((l) => DropdownMenuItem(
                          value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) {
                    block.language = v ?? 'Kotlin';
                  },
                ),
              ),
            ),
            SizedBox(height: 4.r),
            _Field(
              controller: block.codeCtrl,
              hint:
                  'Paste implementation code here...',
              maxLines: 10,
              isDense: true,
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Questions Tab — Track → Topic → Level → Questions
// =============================================================================

class _QuestionsTab extends StatefulWidget {
  const _QuestionsTab();
  @override
  State<_QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<_QuestionsTab> {
  String _selectedTrack = 'KOTLIN';
  String? _selectedTopicId;
  List<Map<String, dynamic>> _topics = [];
  bool _loadingTopics = false;
  String _selectedLevel = 'BEGINNER';

  final _formKey = GlobalKey<FormState>();
  final _docIdCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _optionCtrls =
      List.generate(4, (_) => TextEditingController());
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
    _loadTopicsForTrack();
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

  Future<void> _loadTopicsForTrack() async {
    setState(() {
      _loadingTopics = true;
      _selectedTopicId = null;
      _questions = [];
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('topics')
          .where('trackName', isEqualTo: _selectedTrack)
          .get();
      setState(() {
        _topics =
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loadingTopics = false;
      });
    } catch (e) {
      setState(() => _loadingTopics = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadQuestions() async {
    if (_selectedTopicId == null) return;
    setState(() => _loadingQuestions = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('topics')
          .doc(_selectedTopicId)
          .collection('questions')
          .get();
      setState(() {
        _questions = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        _loadingQuestions = false;
      });
    } catch (e) {
      setState(() => _loadingQuestions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
    if (_selectedTopicId == null) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'question': _questionCtrl.text.trim(),
        'options':
            _optionCtrls.map((c) => c.text.trim()).toList(),
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
          : '${_selectedTopicId}_Q${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(_selectedTopicId)
          .collection('questions')
          .doc(docId)
          .set(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question saved.')),
        );
        _closeForm();
        _loadQuestions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Map<String, dynamic>> get _filteredQuestions =>
      _questions
          .where((q) => q['level'] == _selectedLevel)
          .toList();

  @override
  Widget build(BuildContext context) {
    if (_showForm) return _buildFormView();
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Track + Topic selectors
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          color: AppColors.surfaceContainer,
          child: Column(
            children: [
              Row(
                children: [
                  _SectionLabel('TRACK'),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(
                            color: AppColors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTrack,
                          isExpanded: true,
                          dropdownColor:
                              AppColors.surfaceContainerHigh,
                          items: _kTracks.keys
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12.r,
                                          height: 12.r,
                                          decoration:
                                              BoxDecoration(
                                            color: Color(
                                                _kTracks[t]!),
                                            shape:
                                                BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(
                                            width: AppSpacing
                                                .sm),
                                        Text(t),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() =>
                                _selectedTrack = v ?? 'KOTLIN');
                            _loadTopicsForTrack();
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
                  _SectionLabel('TOPIC'),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _loadingTopics
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                      strokeWidth: 2),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors
                                  .surfaceContainerHigh,
                              borderRadius:
                                  AppRadius.radiusMd,
                              border: Border.all(
                                  color: AppColors
                                      .outlineVariant),
                            ),
                            child:
                                DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTopicId,
                                isExpanded: true,
                                dropdownColor: AppColors
                                    .surfaceContainerHigh,
                                hint: Text(
                                  'Select a topic',
                                  style: TextStyle(
                                      color: AppColors
                                          .onSurfaceVariant),
                                ),
                                items: _topics
                                    .map((t) =>
                                        DropdownMenuItem<String>(
                                          value: t['id'] as String,
                                          child: Text(
                                              t['title'] as String? ??
                                                  t['id'] as String),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() =>
                                      _selectedTopicId =
                                          v);
                                  _loadQuestions();
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
        // Level filter chips
        if (_selectedTopicId != null)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs),
            child: Row(
              children: [
                for (final level in _kLevels)
                  Padding(
                    padding: EdgeInsets.only(
                        right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(level),
                      selected:
                          _selectedLevel == level,
                      onSelected: (_) => setState(
                          () => _selectedLevel = level),
                      selectedColor:
                          AppColors.primaryContainer,
                      labelStyle:
                          AppTypography.codeSm.copyWith(
                        color: _selectedLevel == level
                            ? AppColors
                                .onPrimaryContainer
                            : AppColors.onSurfaceVariant,
                      ),
                      side: BorderSide(
                        color:
                            _selectedLevel == level
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Questions list
        Expanded(
          child: _selectedTopicId == null
              ? Center(
                  child: Text(
                    'Select a topic to see questions.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : _loadingQuestions
                  ? const Center(
                      child: CircularProgressIndicator())
                  : _filteredQuestions.isEmpty
                      ? Center(
                          child: Text(
                            'No $_selectedLevel questions yet.',
                            style: AppTypography.bodyMd
                                .copyWith(
                              color: AppColors
                                  .onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              EdgeInsets.all(AppSpacing.md),
                          itemCount:
                              _filteredQuestions.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(
                                  height: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final q =
                                _filteredQuestions[i];
                            return Container(
                              padding:
                                  EdgeInsets.all(
                                      AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .surfaceContainer,
                                borderRadius:
                                    AppRadius.radiusMd,
                                border: Border.all(
                                    color: AppColors
                                        .outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                6.r,
                                            vertical:
                                                2.r),
                                        decoration:
                                            BoxDecoration(
                                          color: AppColors
                                              .primaryContainer,
                                          borderRadius:
                                              AppRadius
                                                  .radiusSm,
                                        ),
                                        child: Text(
                                          q['level'] ??
                                              '?',
                                          style: AppTypography
                                              .codeSm
                                              .copyWith(
                                            color: AppColors
                                                .onPrimaryContainer,
                                            fontSize:
                                                9.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: AppSpacing
                                              .xs),
                                      Expanded(
                                        child: Text(
                                          q['question'] ??
                                              '',
                                          style: AppTypography
                                              .bodyMd
                                              .copyWith(
                                            color: AppColors
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((q['codeLanguage'] ??
                                          '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    SizedBox(
                                        height: AppSpacing
                                            .xs),
                                    Container(
                                      padding:
                                          EdgeInsets.all(
                                              6.r),
                                      decoration:
                                          BoxDecoration(
                                        color: AppColors
                                            .surfaceContainerHigh,
                                        borderRadius:
                                            AppRadius
                                                .radiusSm,
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          Icon(
                                              Icons
                                                  .code,
                                              size:
                                                  12.r,
                                              color: AppColors
                                                  .primary),
                                          SizedBox(
                                              width:
                                                  4.r),
                                          Text(
                                            '${q['codeLanguage']} • ${q['codeLines']?.length ?? 0} lines',
                                            style: AppTypography
                                                .codeSm
                                                .copyWith(
                                              color: AppColors
                                                  .primary,
                                              fontSize:
                                                  10.sp,
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
        // Add button
        if (_selectedTopicId != null)
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
                    padding: EdgeInsets.symmetric(
                        vertical: 14.r),
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
              vertical: AppSpacing.sm),
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              IconButton(
                onPressed: _closeForm,
                icon: const Icon(
                    Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'New Question — $_selectedTrack',
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
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel('LEVEL'),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color:
                          AppColors.surfaceContainer,
                      borderRadius:
                          AppRadius.radiusMd,
                      border: Border.all(
                          color: AppColors
                              .outlineVariant),
                    ),
                    child:
                        DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        dropdownColor: AppColors
                            .surfaceContainerHigh,
                        items: _kLevels
                            .map((l) =>
                                DropdownMenuItem(
                                  value: l,
                                  child: Text(l),
                                ))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _selectedLevel =
                                v ?? 'BEGINNER'),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel(
                      'DOCUMENT ID (auto if empty)'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _docIdCtrl,
                    hint:
                        'e.g. KTN_COR_Q0',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('QUESTION'),
                  SizedBox(height: AppSpacing.xs),
                  _Field(
                    controller: _questionCtrl,
                    hint: 'Question text',
                    maxLines: 3,
                    validator: (v) => v == null ||
                            v.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _SectionLabel('OPTIONS'),
                  SizedBox(height: AppSpacing.xs),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue:
                                _correctIndex,
                            onChanged: (v) =>
                                setState(() =>
                                    _correctIndex =
                                        v ?? 0),
                            activeColor:
                                AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                          ),
                          Expanded(
                            child: _Field(
                              controller:
                                  _optionCtrls[i],
                              hint:
                                  'Option ${i + 1}',
                              validator: (v) =>
                                  v == null ||
                                          v.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                      height: AppSpacing.sm),
                  Text(
                    'Correct answer: option ${_correctIndex + 1}',
                    style: AppTypography.codeSm
                        .copyWith(
                      color:
                          AppColors.primary,
                    ),
                  ),
                  SizedBox(
                      height: AppSpacing.md),
                  Row(
                    children: [
                      _SectionLabel(
                          'CODE SNIPPET'),
                      const Spacer(),
                      Switch(
                        value: _includeCode,
                        onChanged: (v) =>
                            setState(() =>
                                _includeCode = v),
                        activeColor:
                            AppColors.primary,
                      ),
                    ],
                  ),
                  if (_includeCode) ...[
                    SizedBox(
                        height: AppSpacing.xs),
                    _Field(
                      controller:
                          _codeHeaderCtrl,
                      hint:
                          'Header (e.g. [DATA_SYNC])',
                    ),
                    SizedBox(
                        height: AppSpacing.xs),
                    _Field(
                      controller: _codeLangCtrl,
                      hint: 'Language',
                    ),
                    SizedBox(
                        height: AppSpacing.xs),
                    _Field(
                      controller:
                          _codeLinesCtrl,
                      hint:
                          'Code lines (one per line)',
                      maxLines: 6,
                    ),
                  ],
                  SizedBox(
                      height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed:
                        _saving ? null : _saveQuestion,
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(
                          vertical: 14.r),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            AppRadius.radiusMd,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child:
                                const CircularProgressIndicator(
                                    strokeWidth: 2),
                          )
                        : const Text(
                            'Save Question'),
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
// Progress Tab
// =============================================================================

class _ProgressTab extends StatefulWidget {
  const _ProgressTab();

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  final _formKey = GlobalKey<FormState>();
  final _streakCtrl = TextEditingController(text: '0');
  final _sessionsCtrl = TextEditingController(text: '0');
  final _readinessCtrl = TextEditingController(text: '0');
  final _globalCtrl = TextEditingController(text: '0');
  final _targetCtrl = TextEditingController(text: '0.90');
  final _competencies = <_CompetencyEntry>[];
  final _focusAreas = <_FocusAreaEntry>[];
  bool _saving = false;

  @override
  void dispose() {
    _streakCtrl.dispose();
    _sessionsCtrl.dispose();
    _readinessCtrl.dispose();
    _globalCtrl.dispose();
    _targetCtrl.dispose();
    for (final c in _competencies) {
      c.dispose();
    }
    for (final f in _focusAreas) {
      f.dispose();
    }
    super.dispose();
  }

  void _addCompetency() => setState(() => _competencies.add(_CompetencyEntry()));
  void _removeCompetency(int i) {
    setState(() {
      _competencies[i].dispose();
      _competencies.removeAt(i);
    });
  }

  void _addFocusArea() => setState(() => _focusAreas.add(_FocusAreaEntry()));
  void _removeFocusArea(int i) {
    setState(() {
      _focusAreas[i].dispose();
      _focusAreas.removeAt(i);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'summary': {
          'currentStreakDays': int.tryParse(_streakCtrl.text) ?? 0,
          'totalSessions': int.tryParse(_sessionsCtrl.text) ?? 0,
          'readinessScore':
              double.tryParse(_readinessCtrl.text) ?? 0,
          'globalReadinessScore':
              double.tryParse(_globalCtrl.text) ?? 0,
          'targetScore':
              double.tryParse(_targetCtrl.text) ?? 0,
        },
        'competencies': _competencies
            .map((c) => {
                  'trackId': c.trackIdCtrl.text.trim(),
                  'score': int.tryParse(c.scoreCtrl.text) ?? 0,
                  'level': c.levelCtrl.text.trim(),
                })
            .toList(),
        'focusAreas': _focusAreas
            .map((f) => {
                  'title': f.titleCtrl.text.trim(),
                  'percent': double.tryParse(f.percentCtrl.text) ?? 0,
                  'critical': f.critical,
                  'trend': f.trend,
                  'trendLabel': f.labelCtrl.text.trim(),
                })
            .toList(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('overview')
          .set(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLabel('READINESS SUMMARY'),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _Field(
                      controller: _streakCtrl,
                      hint: 'Streak days',
                      label: 'Streak'),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                      controller: _sessionsCtrl,
                      hint: 'Sessions',
                      label: 'Sessions'),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _Field(
                      controller: _readinessCtrl,
                      hint: '0.0 - 1.0',
                      label: 'Readiness'),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                      controller: _globalCtrl,
                      hint: '0.0 - 1.0',
                      label: 'Global'),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                      controller: _targetCtrl,
                      hint: '0.0 - 1.0',
                      label: 'Target'),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Competencies
            Row(
              children: [
                _SectionLabel('COMPETENCIES'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addCompetency,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            for (var i = 0; i < _competencies.length; i++)
              _CompetencyCard(
                entry: _competencies[i],
                index: i,
                onRemove: () => _removeCompetency(i),
              ),
            SizedBox(height: AppSpacing.lg),

            // Focus Areas
            Row(
              children: [
                _SectionLabel('FOCUS AREAS'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addFocusArea,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            for (var i = 0; i < _focusAreas.length; i++)
              _FocusAreaCard(
                entry: _focusAreas[i],
                index: i,
                onRemove: () => _removeFocusArea(i),
              ),
            SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: _saving ? null : _save,
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
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Progress'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetencyEntry {
  final trackIdCtrl = TextEditingController();
  final scoreCtrl = TextEditingController(text: '0');
  final levelCtrl = TextEditingController();

  void dispose() {
    trackIdCtrl.dispose();
    scoreCtrl.dispose();
    levelCtrl.dispose();
  }
}

class _CompetencyCard extends StatelessWidget {
  const _CompetencyCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  final _CompetencyEntry entry;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Competency ${index + 1}',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          _Field(controller: entry.trackIdCtrl, hint: 'Track ID (e.g. kotlin)'),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _Field(
                    controller: entry.scoreCtrl, hint: 'Score (0-100)'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Field(
                    controller: entry.levelCtrl, hint: 'Level'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusAreaEntry {
  final titleCtrl = TextEditingController();
  final percentCtrl = TextEditingController(text: '0');
  final labelCtrl = TextEditingController();
  bool critical = false;
  String trend = 'flat';

  void dispose() {
    titleCtrl.dispose();
    percentCtrl.dispose();
    labelCtrl.dispose();
  }
}

class _FocusAreaCard extends StatelessWidget {
  const _FocusAreaCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  final _FocusAreaEntry entry;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Focus Area ${index + 1}',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          _Field(controller: entry.titleCtrl, hint: 'Title'),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _Field(
                    controller: entry.percentCtrl,
                    hint: 'Percent (0.0-1.0)'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Field(
                    controller: entry.labelCtrl,
                    hint: 'Trend label'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Row(
                children: [
                  _SectionLabel('CRITICAL'),
                  SizedBox(width: AppSpacing.xs),
                  Switch(
                    value: entry.critical,
                    onChanged: (v) {
                      entry.critical = v;
                      (context as Element).markNeedsBuild();
                    },
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.md),
              _SectionLabel('TREND'),
              SizedBox(width: AppSpacing.xs),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: entry.trend,
                  isDense: true,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  items: const [
                    DropdownMenuItem(value: 'up', child: Text('up')),
                    DropdownMenuItem(value: 'flat', child: Text('flat')),
                    DropdownMenuItem(
                        value: 'levelUp', child: Text('levelUp')),
                  ],
                  onChanged: (v) {
                    entry.trend = v ?? 'flat';
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user.')),
      );
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
        'authProvider':
            user.providerData.isNotEmpty ? user.providerData[0].providerId : 'unknown',
        'tracks': tracks,
        'runtimeLevel': _runtimeLevelCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
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
