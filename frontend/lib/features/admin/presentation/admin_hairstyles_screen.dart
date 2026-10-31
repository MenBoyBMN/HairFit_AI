// ============================================================================
// File: lib/features/admin/presentation/admin_hairstyles_screen.dart
// Mục đích: Màn hình quản lý danh mục kiểu tóc & gắn dáng mặt AI cho Admin.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/hairstyle_model.dart';
import '../../../../providers/admin_provider.dart';

class AdminHairstylesScreen extends ConsumerStatefulWidget {
  const AdminHairstylesScreen({super.key});

  @override
  ConsumerState<AdminHairstylesScreen> createState() =>
      _AdminHairstylesScreenState();
}

class _AdminHairstylesScreenState extends ConsumerState<AdminHairstylesScreen> {
  String _selectedFaceShape = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _faceShapeLabels = {
    'round': 'Mặt tròn',
    'oval': 'Trái xoan',
    'square': 'Mặt vuông',
    'heart': 'Trái tim',
    'oblong': 'Mặt dài',
    'diamond': 'Kim cương',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHairstyleDialog([HairstyleModel? existing]) {
    final messenger = ScaffoldMessenger.of(context);
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final imgController = TextEditingController(text: existing?.imageUrl ?? '');
    final extraImgsController = TextEditingController(
      text: existing?.imageUrls.join(', ') ?? '',
    );
    final tagsController = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    final selectedShapes = Set<String>.from(existing?.faceShapes ?? ['oval']);
    bool isActive = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Sửa kiểu tóc' : 'Thêm kiểu tóc mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên kiểu tóc *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imgController,
                  decoration: const InputDecoration(
                    labelText: 'URL ảnh đại diện chính',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: extraImgsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText:
                        'Album ảnh đa góc độ (các URL cách nhau dấu phẩy)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.collections_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả & mẹo tạo kiểu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (cách nhau bởi dấu phẩy)',
                    border: OutlineInputBorder(),
                    hintText: 'ngắn, sáp vuốt, công sở',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Hiển thị trong gợi ý AI',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dáng mặt phù hợp (AI Recommendation):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _faceShapeLabels.entries.map((entry) {
                    final shapeKey = entry.key;
                    final isChecked = selectedShapes.contains(shapeKey);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isChecked,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            selectedShapes.add(shapeKey);
                          } else {
                            selectedShapes.remove(shapeKey);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(ctx);
                final id =
                    existing?.id ??
                    'style_${DateTime.now().millisecondsSinceEpoch}';
                final tags = tagsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final primaryUrl = imgController.text.trim();
                final extraUrls = extraImgsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final finalImageUrls = extraUrls.isNotEmpty
                    ? extraUrls
                    : (primaryUrl.isNotEmpty ? [primaryUrl] : <String>[]);

                final model = HairstyleModel(
                  id: id,
                  name: name,
                  description: descController.text.trim(),
                  imageUrl: primaryUrl,
                  imageUrls: finalImageUrls,
                  faceShapes: selectedShapes.toList(),
                  tags: tags,
                  active: isActive,
                );

                await ref
                    .read(adminControllerProvider.notifier)
                    .saveHairstyle(model);

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Đã cập nhật kiểu tóc!'
                          : 'Đã thêm kiểu tóc mới!',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm mới'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHairstyle(HairstyleModel style) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa kiểu tóc?'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${style.name}" khỏi danh mục kiểu tóc không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminControllerProvider.notifier)
          .deleteHairstyle(style.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã xóa kiểu tóc "${style.name}"'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hairstylesAsync = ref.watch(allHairstylesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Thanh công cụ: Thêm mới, Tìm kiếm & Lọc dáng mặt
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiểu tóc theo tên, tags...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(
                            () => _searchQuery = val.trim().toLowerCase(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _showHairstyleDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Thêm mới'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildShapeChip('Tất cả', 'all'),
                      const SizedBox(width: 8),
                      ..._faceShapeLabels.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildShapeChip(e.value, e.key),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách kiểu tóc
          Expanded(
            child: hairstylesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (hairstyles) {
                final filtered = hairstyles.where((h) {
                  final matchQuery =
                      _searchQuery.isEmpty ||
                      h.name.toLowerCase().contains(_searchQuery) ||
                      h.tags.any((t) => t.toLowerCase().contains(_searchQuery));
                  final matchShape =
                      _selectedFaceShape == 'all' ||
                      h.faceShapes.contains(_selectedFaceShape);
                  return matchQuery && matchShape;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_cut_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có kiểu tóc nào phù hợp.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final style = filtered[idx];

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: style.imageUrl.isNotEmpty
                                ? Image.network(
                                    style.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.content_cut,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.content_cut,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        style.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: style.active
                                              ? null
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    if (!style.active)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorLight,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Đang ẩn',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          _showHairstyleDialog(style),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          _confirmDeleteHairstyle(style),
                                    ),
                                  ],
                                ),
                                if (style.description.isNotEmpty) ...[
                                  Text(
                                    style.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    ...style.faceShapes.map((shape) {
                                      final label =
                                          _faceShapeLabels[shape] ?? shape;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    }),
                                    if (style.imageUrls.length > 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.infoLight,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${style.imageUrls.length} ảnh góc độ',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeChip(String label, String value) {
    final isSelected = _selectedFaceShape == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFaceShape = value;
          });
        }
      },
    );
  }
}

// CreBy: MenBoyBMN
