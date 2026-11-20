import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/setup_notifier.dart';
import 'package:vi_xanh_app/features/settings/presentation/settings_notifier.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late FakeKeyValueStore store;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    store = FakeKeyValueStore();
    container = ProviderContainer(
      overrides: testOverrides(db: db, store: store),
    );
    // Provider autoDispose: giữ sống suốt test.
    container.listen(setupNotifierProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  SetupNotifier notifier() => container.read(setupNotifierProvider.notifier);
  SetupState state() => container.read(setupNotifierProvider);

  void fillValidSetup({WalletType type = WalletType.cash, int balance = 1250000}) {
    notifier()
      ..setUserName('  Minh ')
      ..increaseDay() // 1 → 2
      ..next()
      ..pickWalletType(type, 'Tiền mặt')
      ..setBalance(balance);
  }

  test('ngày bắt đầu tháng xoay vòng trong 1..28', () {
    notifier().decreaseDay();
    expect(state().monthStartDay, 28);
    notifier().increaseDay();
    expect(state().monthStartDay, 1);
  });

  test('chọn loại ví điền tên gợi ý; đã tự sửa tên thì không ghi đè', () {
    notifier()
      ..next()
      ..pickWalletType(WalletType.cash, 'Tiền mặt');
    expect(state().walletName, 'Tiền mặt');
    notifier().pickWalletType(WalletType.bank, 'Tài khoản ngân hàng');
    expect(state().walletName, 'Tài khoản ngân hàng');
    notifier()
      ..setWalletName('VCB lương')
      ..pickWalletType(WalletType.ewallet, 'Ví MoMo');
    expect(state().walletName, 'VCB lương');
  });

  test('bước 2 chưa chọn loại ví hoặc tên rỗng → chưa được tiếp tục', () {
    notifier().next();
    expect(state().canContinue, isFalse);
    notifier()
      ..pickWalletType(WalletType.cash, 'Tiền mặt')
      ..setWalletName('   ');
    expect(state().canContinue, isFalse);
  });

  test('back: bước 2 → bước 1; ở bước 1 trả false', () {
    notifier().next();
    expect(notifier().back(), isTrue);
    expect(state().step, SetupStep.profile);
    expect(notifier().back(), isFalse);
  });

  test('luồng đủ → đúng 1 ví + cài đặt đã lưu', () async {
    fillValidSetup();
    expect((await notifier().submit()).isOk, isTrue);

    final wallets = await db.walletsDao.watchActive().first;
    expect(wallets.single.name, 'Tiền mặt');
    expect(wallets.single.initialBalance, 1250000);
    final prefs = container.read(appPreferencesProvider);
    expect(prefs.onboardingCompleted, isTrue);
    expect(prefs.userName, 'Minh');
    expect(prefs.monthStartDay, 2);
    expect(store.values['user_name'], 'Minh');
  });

  test('thẻ tín dụng: dư nợ nhập vào lưu thành số dư ban đầu âm', () async {
    fillValidSetup(type: WalletType.credit, balance: 2000000);
    await notifier().submit();
    expect((await db.walletsDao.watchActive().first).single.initialBalance, -2000000);
  });

  test('tạo ví lỗi (DB hỏng) → chưa đánh dấu xong onboarding', () async {
    fillValidSetup();
    await breakWalletTables(db);
    final result = await notifier().submit();
    expect((result as Err<void>).failure, isA<DatabaseFailure>());
    expect(container.read(appPreferencesProvider).onboardingCompleted, isFalse);
    expect(state().submitting, isFalse);
  });

  test('lưu cài đặt lỗi sau khi đã có ví → thử lại không tạo ví trùng', () async {
    fillValidSetup();
    store.failWrites = true;
    expect((await notifier().submit()).isOk, isFalse);
    expect(container.read(appPreferencesProvider).onboardingCompleted, isFalse);
    expect(await db.walletsDao.watchActive().first, hasLength(1));

    store.failWrites = false;
    expect((await notifier().submit()).isOk, isTrue);
    expect(await db.walletsDao.watchActive().first, hasLength(1));
    expect(container.read(appPreferencesProvider).onboardingCompleted, isTrue);
  });
}
