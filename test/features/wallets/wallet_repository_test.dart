import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = WalletRepository(db);
  });
  tearDown(() => db.close());

  Failure failureOf(Result<Object?> r) => (r as Err<Object?>).failure;

  test('tạo ví hợp lệ: tên được bỏ khoảng trắng hai đầu, có trong watchActive', () async {
    final result = await repo.create(
      name: '  Tiền mặt  ',
      type: WalletType.cash,
      initialBalance: 1250000,
    );
    final id = result.valueOrNull!;
    final wallets = await repo.watchActive().first;
    expect(wallets.single.id, id);
    expect(wallets.single.name, 'Tiền mặt');
    expect((await repo.watchBalances().first)[id], 1250000);
  });

  test('tên rỗng hoặc 65 ký tự → ValidationFailure, không ghi gì', () async {
    expect(
      failureOf(await repo.create(name: '   ', type: WalletType.cash)),
      isA<ValidationFailure>(),
    );
    expect(
      failureOf(await repo.create(name: 'a' * 65, type: WalletType.cash)),
      isA<ValidationFailure>(),
    );
    expect(await repo.watchActive().first, isEmpty);
  });

  test('tên đúng 64 ký tự được chấp nhận', () async {
    expect((await repo.create(name: 'a' * 64, type: WalletType.bank)).isOk, isTrue);
  });

  test('thẻ tín dụng lưu số dư ban đầu âm', () async {
    final id = (await repo.create(
      name: 'Thẻ tín dụng',
      type: WalletType.credit,
      initialBalance: -2000000,
    )).valueOrNull!;
    expect((await repo.watchBalances().first)[id], -2000000);
  });

  test('số dư ban đầu vượt giới hạn → ValidationFailure', () async {
    expect(
      failureOf(await repo.create(name: 'X', type: WalletType.cash, initialBalance: 1000000000000)),
      isA<ValidationFailure>(),
    );
  });

  test('hasActiveWallet phản ánh có ví hay chưa', () async {
    expect((await repo.hasActiveWallet()).valueOrNull, isFalse);
    await repo.create(name: 'Ví', type: WalletType.cash);
    expect((await repo.hasActiveWallet()).valueOrNull, isTrue);
  });

  test('lỗi DB → DatabaseFailure, không ném', () async {
    await breakWalletTables(db);
    expect(failureOf(await repo.create(name: 'Ví', type: WalletType.cash)), isA<DatabaseFailure>());
  });
}
