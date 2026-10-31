// ============================================================================
// File: lib/features/admin/presentation/admin_reviews_screen.dart
// Mục đích: Màn hình kiểm duyệt đánh giá & xử lý vi phạm cho Admin.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/admin_provider.dart';

class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends ConsumerState<AdminReviewsScreen> {
  int? _selectedRating;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteReview(Map<String, dynamic> review) async {
    final messenger = ScaffoldMessenger.of(context);
    final reviewId = review['id'] as String? ?? '';
    final barberId = review['barberId'] as String? ?? '';
    final appointmentId = review['appointmentId'] as String?;
    final rating = (review['rating'] as num?)?.toInt() ?? 5;
    final customerName = review['customerName'] as String? ?? 'Khách';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa đánh giá này?'),
        content: Text(
          'Đánh giá của $customerName sẽ bị xóa khỏi hệ thống, gỡ khỏi lịch hẹn tương ứng và tự động tính lại điểm trung bình cho thợ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminControllerProvider.notifier)
          .deleteReview(
            reviewId,
            barberId,
            rating,
            appointmentId: appointmentId,
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa đánh giá và cập nhật lại điểm thợ thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsProvider(_selectedRating));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Thanh tìm kiếm & Bộ lọc số sao
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Tìm theo tên khách, mã thợ, nội dung đánh giá...',
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStarFilterChip('Tất cả', null),
                      const SizedBox(width: 8),
                      _buildStarFilterChip('5 sao ⭐', 5),
                      const SizedBox(width: 8),
                      _buildStarFilterChip('4 sao ⭐', 4),
                      const SizedBox(width: 8),
                      _buildStarFilterChip('3 sao ⭐', 3),
                      const SizedBox(width: 8),
                      _buildStarFilterChip('2 sao ⚠️', 2),
                      const SizedBox(width: 8),
                      _buildStarFilterChip('1 sao 🚨', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách Review
          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (reviews) {
                final filtered = reviews.where((r) {
                  if (_searchQuery.isEmpty) return true;
                  final customer = (r['customerName'] as String? ?? '')
                      .toLowerCase();
                  final barber = (r['barberId'] as String? ?? '').toLowerCase();
                  final comment = (r['reviewComment'] as String? ?? '')
                      .toLowerCase();
                  return customer.contains(_searchQuery) ||
                      barber.contains(_searchQuery) ||
                      comment.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chưa có đánh giá nào phù hợp.',
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
                    final r = filtered[idx];
                    final customerName =
                        r['customerName'] as String? ?? 'Khách hàng';
                    final barberId = r['barberId'] as String? ?? 'Không rõ';
                    final appointmentId = r['appointmentId'] as String? ?? '';
                    final rating = (r['rating'] as num?)?.toInt() ?? 5;
                    final comment = r['reviewComment'] as String? ?? '';
                    final rawDate = r['createdAt'];
                    String dateStr = '';
                    if (rawDate is Timestamp) {
                      dateStr = DateFormat('dd/MM/yyyy HH:mm')
                          .format(rawDate.toDate());
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                radius: 18,
                                child: Text(
                                  customerName.isNotEmpty
                                      ? customerName[0].toUpperCase()
                                      : 'K',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Tiệm nhận đánh giá: $barberId',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (dateStr.isNotEmpty)
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    starIdx < rating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.isNotEmpty
                                ? comment
                                : '(Không có nhận xét chi tiết)',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: comment.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: comment.isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (appointmentId.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    'Mã lịch: $appointmentId',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              TextButton.icon(
                                onPressed: () => _confirmDeleteReview(r),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                label: const Text(
                                  'Xóa đánh giá',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildStarFilterChip(String label, int? rating) {
    final isSelected = _selectedRating == rating;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRating = rating;
          });
        }
      },
    );
  }
}

// CreBy: MenBoyBMN
