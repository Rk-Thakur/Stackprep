import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/terminal_text_field.dart';

/// The word the user has to type to arm the delete button. Requiring it keeps
/// a stray tap from destroying an account that cannot be recovered.
const String kDeleteAccountConfirmWord = 'DELETE';

/// Confirmation step for account deletion.
///
/// Resolves true only when the user typed [kDeleteAccountConfirmWord]; every
/// other path (cancel, back, wrong word) resolves false or null, which the
/// caller treats as "leave everything alone".
class DeleteAccountConfirmDialog extends StatefulWidget {
  const DeleteAccountConfirmDialog({super.key, this.email});

  /// Shown back to the user so they can see which account they are destroying.
  final String? email;

  /// Returns true when the deletion was confirmed.
  static Future<bool> show(BuildContext context, {String? email}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAccountConfirmDialog(email: email),
    );
    return confirmed ?? false;
  }

  @override
  State<DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<DeleteAccountConfirmDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final armed =
        _controller.text.trim().toUpperCase() == kDeleteAccountConfirmWord;
    if (armed != _armed) setState(() => _armed = armed);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: ConstrainedBox(
        // Short viewports and large text scales would otherwise overflow the
        // dialog, and a confirmation you cannot read is worse than one that
        // scrolls.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELETE ACCOUNT',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'This permanently erases your account and cannot be undone.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                _DestructiveList(const [
                  'Your profile and sign-in identity',
                  'Every track you selected, on this device and in the backend',
                  'All practice history, streaks and competency scores',
                ]),
                SizedBox(height: AppSpacing.lg),
                if (email != null && email.isNotEmpty) ...[
                  Text(
                    'Confirming for $email',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  'Type $kDeleteAccountConfirmWord to confirm',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TerminalTextField(
                  controller: _controller,
                  icon: Icons.warning_amber_rounded,
                  hintText: kDeleteAccountConfirmWord,
                ),
                SizedBox(height: AppSpacing.lg),
                // Stacked rather than side by side: at 393pt there is not
                // enough width for both labels, and a full-width destructive
                // action is harder to hit by accident.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _armed
                          ? () => Navigator.of(context).pop(true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onError,
                        disabledBackgroundColor: AppColors.error.withValues(
                          alpha: 0.25,
                        ),
                        disabledForegroundColor: AppColors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                      child: const Text('Delete permanently'),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DestructiveList extends StatelessWidget {
  const _DestructiveList(this._items);

  final List<String> _items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in _items)
          Padding(
            padding: EdgeInsets.only(bottom: 6.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5.r, right: 8.r),
                  child: Icon(Icons.close, size: 13.r, color: AppColors.error),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
