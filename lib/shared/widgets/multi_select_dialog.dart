import 'package:flutter/material.dart';
import '../../res/theme/app_colors.dart';
import '../../res/theme/app_text_styles.dart';

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelected;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: AppTextStyles.h3),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isChecked = _selected.contains(item);
            return CheckboxListTile(
              title: Text(item, style: AppTextStyles.body),
              value: isChecked,
              activeColor: AppColors.primary,
              onChanged: (bool? val) {
                setState(() {
                  if (val == true) {
                    _selected.add(item);
                  } else {
                    _selected.remove(item);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected.toList()),
          child: const Text('Save Selection'),
        ),
      ],
    );
  }
}
