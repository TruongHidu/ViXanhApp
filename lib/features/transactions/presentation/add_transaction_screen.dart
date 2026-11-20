import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/amount_input.dart';
import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/ids.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../data/daos/categories_dao.dart';
import '../../../data/database.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/amount_keypad.dart';
import '../../../theme/widgets/category_avatar.dart';
import '../../../theme/widgets/thousands_input_formatter.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category_icons.dart';
import '../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../wallets/data/wallet_repository.dart';
import '../../wallets/presentation/wallet_type_ui.dart';
import '../../wallets/presentation/widgets/wallet_picker_sheet.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_draft.dart';
import 'add_transaction_notifier.dart';

/// Danh mục gợi ý trên dải ngang: dùng gần đây trước, bù bằng danh mục gốc.
final _recentCategoriesProvider = FutureProvider.autoDispose
    .family<List<CategoryRow>, CategoryType>(
      (ref, type) async =>
          (await ref.watch(transactionRepositoryProvider).recentCategories(type, limit: 8))
              .valueOrNull ??
          const [],
    );

/// Màn Thêm giao dịch (mở từ nút "+"), hoặc Sửa khi có [transactionId].
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    this.transactionId,
    this.initialType = TransactionType.expense,
    super.key,
  });

  final TransactionId? transactionId;

  /// Tab chọn sẵn khi thêm mới.
  final TransactionType initialType;

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  AddTransactionArgs get _args =>
      (editingId: widget.transactionId, initialType: widget.initialType);

  final _note = TextEditingController();
  bool _noteLoaded = false;

  AddTransactionNotifier get _notifier => ref.read(addTransactionProvider(_args).notifier);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save({required bool keepOpen}) async {
    final state = ref.read(addTransactionProvider(_args)).value;
    if (state == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final label = _summaryLabel(state, l10n);

    final result = await _notifier.save(keepOpen: keepOpen);
    // Danh mục vừa dùng phải lên đầu dải gợi ý ở lần nhập tiếp theo.
    if (result.isOk && mounted) ref.invalidate(_recentCategoriesProvider);
    switch (result) {
      case Err(:final failure):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(_errorMessage(failure, l10n))));
      case Ok(:final value) when keepOpen:
        _note.clear();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.txnSaved(formatSigned(Money(value.amount), value.type), label)),
            ),
          );
      case Ok():
        await navigator.maybePop();
    }
  }

  String _summaryLabel(AddTransactionState s, AppLocalizations l10n) {
    if (s.isTransfer) {
      final wallets = ref.read(activeWalletsProvider).value ?? const [];
      String name(WalletId? id) => wallets.where((w) => w.id == id).firstOrNull?.name ?? '';
      return '${name(s.walletId)} → ${name(s.toWalletId)}';
    }
    final recent = ref.read(_recentCategoriesProvider(_categoryType(s.type))).value ?? const [];
    return recent.where((c) => c.id == s.categoryId).firstOrNull?.name ?? '';
  }

  static String _errorMessage(Failure failure, AppLocalizations l10n) => switch (failure.code) {
    TransactionErrors.amountInvalid => l10n.txnErrorAmount,
    TransactionErrors.categoryRequired ||
    TransactionErrors.categoryInvalid => l10n.txnErrorCategory,
    TransactionErrors.walletInvalid => l10n.txnErrorWallet,
    TransactionErrors.transferWallets => l10n.txnErrorTransfer,
    TransactionErrors.textTooLong => l10n.txnErrorTooLong,
    _ => l10n.txnSaveFailed,
  };

  Future<void> _pickDateTime(DateTime current) async {
    final local = current.toLocal();
    final now = ref.read(clockProvider).now();
    final date = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(local));
    if (!mounted) return;
    final t = time ?? TimeOfDay.fromDateTime(local);
    _notifier.setOccurredAt(DateTime(date.year, date.month, date.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(addTransactionProvider(_args));
    final isEditing = widget.transactionId != null;

    final state = async.value;
    if (state != null && !_noteLoaded) {
      _note.text = state.note;
      _noteLoaded = true;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    const CloseButton(),
                    const Spacer(),
                    if (!isEditing && state != null)
                      Flexible(
                        flex: 8,
                        child: TextButton(
                          onPressed: state.saving ? null : () => _save(keepOpen: true),
                          child: Text(l10n.txnSaveMore, textAlign: TextAlign.end),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: switch (async) {
                AsyncData(:final value) => _Form(
                  state: value,
                  noteController: _note,
                  notifier: _notifier,
                  onPickDateTime: () => _pickDateTime(value.occurredAt),
                ),
                AsyncError() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenGutter),
                    child: Text(l10n.txnLoadFailed, textAlign: TextAlign.center),
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
            if (state != null)
              AmountKeypad(
                saving: state.saving,
                onDigit: _notifier.pressDigit,
                onThousand: _notifier.pressThousand,
                onSign: _notifier.pressSign,
                onBackspace: _notifier.backspace,
                onSave: () => _save(keepOpen: false),
              ),
          ],
        ),
      ),
    );
  }
}

CategoryType _categoryType(TransactionType type) =>
    type == TransactionType.income ? CategoryType.income : CategoryType.expense;

class _Form extends ConsumerWidget {
  const _Form({
    required this.state,
    required this.noteController,
    required this.notifier,
    required this.onPickDateTime,
  });

  final AddTransactionState state;
  final TextEditingController noteController;
  final AddTransactionNotifier notifier;
  final VoidCallback onPickDateTime;

  static const _quickAmounts = [20000, 50000, 100000, 200000, 500000];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wallets = ref.watch(activeWalletsProvider).value ?? const <WalletRow>[];
    WalletRow? wallet(WalletId? id) => wallets.where((w) => w.id == id).firstOrNull;
    final labels = dateLabelsOf(context, ref.watch(clockProvider));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        0,
        AppSpacing.screenGutter,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TypeTabs(selected: state.type, onSelect: notifier.setType),
          const SizedBox(height: AppSpacing.sm),
          _AmountDisplay(amount: state.amount, type: state.type),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final v in _quickAmounts)
                _QuickChip(
                  label: '${v ~/ 1000}k',
                  semantics: l10n.txnQuickAmount(formatMoney(Money(v))),
                  onTap: () => notifier.quickAmount(v),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.isTransfer)
            _TransferWallets(
              from: wallet(state.walletId),
              to: wallet(state.toWalletId),
              onPickFrom: () async {
                final id = await showWalletPicker(context, selected: state.walletId);
                if (id != null) notifier.pickWallet(id);
              },
              onPickTo: () async {
                final id = await showWalletPicker(context, selected: state.toWalletId);
                if (id != null) notifier.pickToWallet(id);
              },
              onSwap: notifier.swapWallets,
            )
          else
            _CategoryStrip(
              type: _categoryType(state.type),
              selected: state.categoryId,
              onPick: notifier.pickCategory,
            ),
          const SizedBox(height: AppSpacing.md),
          _DetailsCard(
            children: [
              if (!state.isTransfer)
                _DetailRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.txnFieldWallet,
                  value: wallet(state.walletId)?.name ?? l10n.txnNoWallet,
                  onTap: () async {
                    final id = await showWalletPicker(context, selected: state.walletId);
                    if (id != null) notifier.pickWallet(id);
                  },
                ),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: l10n.txnFieldTime,
                value: l10n.txnDateTime(
                  labels.dayLabel(state.occurredAt),
                  labels.timeLabel(state.occurredAt),
                ),
                onTap: onPickDateTime,
              ),
              _NoteRow(controller: noteController, onChanged: notifier.setNote),
            ],
          ),
        ],
      ),
    );
  }
}

/// Màu theo loại giao dịch: (màu gốc cho số lớn/icon, nền nhạt, màu chữ đạt AA).
(Color, Color, Color) _typeColors(BuildContext context, TransactionType type) {
  final c = context.appColors;
  return switch (type) {
    TransactionType.expense => (c.expense, c.expenseBg, c.expenseText),
    TransactionType.income => (c.income, c.incomeBg, c.incomeText),
    TransactionType.transfer => (c.transfer, c.transferBg, c.transferText),
  };
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({required this.selected, required this.onSelect});

  final TransactionType selected;
  final ValueChanged<TransactionType> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final tabs = [
      (TransactionType.expense, l10n.txnTypeExpense),
      (TransactionType.income, l10n.txnTypeIncome),
      (TransactionType.transfer, l10n.txnTypeTransfer),
    ];
    return Semantics(
      label: l10n.txnTypeTabsLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: ShapeDecoration(color: colors.surfaceAlt, shape: const StadiumBorder()),
        child: Row(
          children: [
            for (final (type, label) in tabs)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final on = type == selected;
                    final (_, bg, fg) = _typeColors(context, type);
                    return Semantics(
                      selected: on,
                      button: true,
                      label: label,
                      onTap: () => onSelect(type),
                      excludeSemantics: true,
                      child: Material(
                        color: on ? bg : Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: on ? fg.withValues(alpha: 0.25) : Colors.transparent,
                          ),
                        ),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => onSelect(type),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 40),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (on) ...[
                                    Icon(Icons.check_rounded, size: 16, color: fg),
                                    const SizedBox(width: AppSpacing.xs),
                                  ],
                                  Flexible(
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: on ? fg : colors.textSecondary,
                                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amount, required this.type});

  final AmountInput amount;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (color, _, _) = _typeColors(context, type);
    final total = amount.total;
    final expression = amount.hasOperator
        ? '${amount.parts.map((p) => int.tryParse(p) == null ? ' $p ' : ThousandsInputFormatter.format(int.parse(p))).join()} ='
        : '';
    final icon = switch (type) {
      TransactionType.expense => Icons.arrow_upward_rounded,
      TransactionType.income => Icons.arrow_downward_rounded,
      TransactionType.transfer => Icons.swap_horiz_rounded,
    };

    return Semantics(
      liveRegion: true,
      label: l10n.txnAmountLabel(formatMoney(Money(total))),
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Text(expression, style: theme.textTheme.bodySmall?.copyWith(fontSize: 14)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  ThousandsInputFormatter.format(total),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 40,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Con trỏ tĩnh (không nhấp nháy): báo đang nhập mà không thêm chuyển động liên tục.
              Container(
                width: 3,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              Text(
                '₫',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.semantics, required this.onTap});

  final String label;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semantics,
    onTap: onTap,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch, minWidth: 64),
        child: Center(
          widthFactor: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
            decoration: ShapeDecoration(
              color: context.appColors.surfaceAlt,
              shape: const StadiumBorder(),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip({required this.type, required this.selected, required this.onPick});

  final CategoryType type;
  final CategoryId? selected;
  final ValueChanged<CategoryId> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(_recentCategoriesProvider(type)).value ?? const <CategoryRow>[];
    final all = [
      for (final node in ref.watch(categoryTreeProvider(type)).value ?? const <CategoryNode>[]) ...[
        node.category,
        ...node.children,
      ],
    ];
    // Danh mục chọn từ "Tất cả" có thể không nằm trong danh sách gần đây → đưa lên đầu.
    final chosen = all.where((c) => c.id == selected).firstOrNull;
    final items = [if (chosen != null && !recent.any((c) => c.id == chosen.id)) chosen, ...recent];

    return Semantics(
      label: l10n.txnCategoriesLabel,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final c in items)
              _CategoryItem(
                label: c.name,
                selected: c.id == selected,
                onTap: () => onPick(c.id),
                avatar: CategoryAvatar(
                  icon: categoryIcon(c.icon),
                  color: Color(c.color),
                  semanticLabel: c.name,
                  size: 52,
                ),
              ),
            _CategoryItem(
              label: l10n.categoryAll,
              selected: false,
              onTap: () async {
                final id = await showCategoryPicker(context, type: type, selected: selected);
                if (id != null) onPick(id);
              },
              avatar: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.appColors.textMuted, width: 1.5),
                ),
                child: Icon(Icons.grid_view_rounded, color: context.appColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.avatar,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget avatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.button),
        child: SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(padding: const EdgeInsets.all(2), child: avatar),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected ? theme.colorScheme.onSurface : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferWallets extends StatelessWidget {
  const _TransferWallets({
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final WalletRow? from;
  final WalletRow? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: _WalletCard(label: l10n.txnFromWallet, wallet: from, onTap: onPickFrom),
        ),
        IconButton(
          tooltip: l10n.swapWallets,
          onPressed: onSwap,
          style: IconButton.styleFrom(backgroundColor: colors.transferBg),
          icon: Icon(Icons.arrow_forward_rounded, color: colors.transferText),
        ),
        Expanded(
          child: _WalletCard(label: l10n.txnToWallet, wallet: to, onTap: onPickTo),
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.label, required this.wallet, required this.onTap});

  final String label;
  final WalletRow? wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final w = wallet;
    final name = w?.name ?? l10n.txnNoWallet;
    return Semantics(
      button: true,
      label: '$label: $name',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(AppRadius.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (w != null) ...[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: w.type.color.withValues(alpha: 0.2),
                      child: Icon(w.type.icon, size: 20, color: w.type.color),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.bodySmall),
                        Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: const BorderRadius.all(AppRadius.card),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(indent: 50),
          children[i],
        ],
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, size: 22, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLength: TransactionRepository.maxNoteLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                hintText: l10n.txnNoteHint,
                labelText: null,
                semanticCounterText: '',
              ).copyWith(hintMaxLines: 2),
            ),
          ),
        ],
      ),
    );
  }
}
