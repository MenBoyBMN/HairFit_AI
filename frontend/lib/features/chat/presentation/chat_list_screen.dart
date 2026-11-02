// ============================================================================
// File: lib/features/chat/presentation/chat_list_screen.dart
// Mục đích: Màn hình giao diện (Screen) chính của tính năng chat.
// Kết cấu:
//  - Sử dụng ConsumerWidget/StatefulWidget, kết nối UI với Provider để hiển thị trạng thái và xử lý sự kiện người dùng.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/platform_helper.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/web_nav_shell.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import 'chat_screen.dart';

/// Màn hình danh sách các cuộc trò chuyện (Hộp thư tin nhắn)
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  ChatConversation? _selectedConversation;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final currentUserId = currentUser?.uid ?? '';
    final isDesktop = PlatformHelper.isDesktopLayout(context);

    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: isDesktop
            ? const WebTopNavBar(currentRoute: '/conversations')
            : AppBar(title: const Text('Tin Nhắn', style: AppTextStyles.h3)),
        body: const Center(child: Text('Vui lòng đăng nhập để xem tin nhắn')),
      );
    }

    final conversationsAsync = ref.watch(
      userConversationsStreamProvider(currentUserId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? const WebTopNavBar(currentRoute: '/conversations')
          : AppBar(
              title: const Text('Tin Nhắn 1:1', style: AppTextStyles.h3),
              centerTitle: true,
            ),
      body: conversationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (err, _) => Center(
          child: ErrorRetry(
            errorMessage: 'Không thể tải danh sách tin nhắn: $err',
            onRetry: () =>
                ref.refresh(userConversationsStreamProvider(currentUserId)),
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              title: 'Hộp thư trống',
              message: 'Bạn chưa có cuộc trò chuyện nào. Hãy mở hồ sơ thợ hoặc lịch hẹn để bắt đầu trao đổi!',
            );
          }

          final isCustomer = currentUser?.role == UserRole.customer;

          if (isDesktop) {
            final activeConv = _selectedConversation ?? conversations.first;
            final activeOtherName = isCustomer
                ? activeConv.barberName
                : activeConv.customerName;
            final activeOtherId = isCustomer
                ? activeConv.barberId
                : activeConv.customerId;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: PlatformHelper.maxWebContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.borderRadiusLg,
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        // Cột trái (360px): Danh sách hội thoại
                        Container(
                          width: 360,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            border: Border(
                              right: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppDimensions.md),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.forum_rounded,
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppDimensions.sm),
                                    const Text(
                                      'Hộp thư trực tuyến',
                                      style: AppTextStyles.h4,
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${conversations.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: conversations.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        height: 1,
                                        color: AppColors.divider,
                                      ),
                                  itemBuilder: (context, index) {
                                    final conv = conversations[index];
                                    final otherName = isCustomer
                                        ? conv.barberName
                                        : conv.customerName;
                                    final isSelected = conv.id == activeConv.id;

                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor: AppColors.accent
                                          .withValues(alpha: 0.08),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: AppDimensions.md,
                                            vertical: AppDimensions.xs,
                                          ),
                                      leading: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          otherName.isNotEmpty
                                              ? otherName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              otherName,
                                              style: AppTextStyles.h4,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            DateFormatter.formatShortDate(
                                              conv.updatedAt,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          conv.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                conv.lastSenderId ==
                                                    currentUserId
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                            fontWeight:
                                                conv.lastSenderId ==
                                                    currentUserId
                                                ? FontWeight.normal
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedConversation = conv;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cột phải (Expanded): Cửa sổ chat trực tiếp
                        Expanded(
                          child: ChatScreen(
                            key: ValueKey(activeConv.id),
                            chatId: activeConv.id,
                            otherUserId: activeOtherId,
                            otherUserName: activeOtherName,
                            customerId: activeConv.customerId,
                            customerName: activeConv.customerName,
                            barberId: activeConv.barberId,
                            barberName: activeConv.barberName,
                            isEmbedded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                itemCount: conversations.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final otherName = isCustomer
                      ? conv.barberName
                      : conv.customerName;
                  final otherId = isCustomer ? conv.barberId : conv.customerId;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.xs,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherName,
                            style: AppTextStyles.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormatter.formatShortDate(conv.updatedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        conv.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: conv.lastSenderId == currentUserId
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontWeight: conv.lastSenderId == currentUserId
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      context.push(
                        '/chat/${conv.id}'
                        '?otherUserId=$otherId'
                        '&otherUserName=${Uri.encodeComponent(otherName)}'
                        '&customerId=${conv.customerId}'
                        '&customerName=${Uri.encodeComponent(conv.customerName)}'
                        '&barberId=${conv.barberId}'
                        '&barberName=${Uri.encodeComponent(conv.barberName)}',
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// CreBy: MenBoyBMN
