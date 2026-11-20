# Bộ prompt hoàn tất Giai đoạn 1 – Nền tảng (Ví Xanh)

## Context

Bạn đã xong bước 1 của giai đoạn 1 (khung kiến trúc). Khảo sát code cho thấy phần còn thiếu và phần lệch so với tài liệu kiến trúc:

- **Đã có, dùng lại:** `lib/core/` (`Result`/`guardAsync`, `Failure` sealed, `Money` int + `format()`, `Clock`/`FixedClock`, `DateOnly`), `lib/bootstrap.dart` (CrashLog + 2 error handler, ProviderScope overrides), `lib/app.dart` (MaterialApp.router + lifecycle observer), `lib/services/*` (interface + impl + provider ném lỗi đến khi override), `test/helpers.dart` (`inMemoryDatabase()`, `buildTestApp()`), gen-l10n (`l10n.yaml`, `app_vi.arb` là template).
- **Lệch tài liệu → sửa (đã chốt với bạn):** schema Drift v1 viết lại theo tài liệu (UUID, `amount > 0` + `type`, xóa mềm, đủ cột ví/chuyển tiền); cài đặt chuyển từ bảng `AppSettings` sang `shared_preferences`.
- **Còn thiếu:** font Be Vietnam Pro + typography, token màu theo bảng màu mới (hiện là seed `0xFF1B8A5A`), seed danh mục mặc định, `CategoriesDao`, `build.yaml`, snapshot schema, router dạng shell 4 tab + nút "+", formatter tiền/ngày, l10n cho các màn khung.
- **Ngoài phạm vi (đúng yêu cầu):** CI.

**Cách dùng:** dán lần lượt từng prompt cho agent code (Claude Code), mỗi prompt một phiên/một lượt, luôn dán kèm Prompt 0 ở đầu. Chạy kiểm tra xong mới sang prompt tiếp theo.

**Thứ tự:** 0 (bối cảnh chung, dán kèm mọi prompt) → 1 Cài đặt + bootstrap → 2 Schema Drift v1 → 3 Theme + font → 4 Formatter + l10n → 5 Router shell → 6 Rà soát cuối. Prompt 1 đi trước 2 vì nó gỡ bảng `AppSettings`; 3 đi trước 5 vì thanh điều hướng dùng token.

---

## PROMPT 0 – Bối cảnh chung (dán ở đầu mọi prompt)

```
Bạn đang làm app Flutter "Ví Xanh" (quản lý chi tiêu cá nhân, VND, offline-first) tại D:\Project4CV\vi_xanh_app.
Flutter 3.32.1 stable, Dart ^3.8.1. Riverpod 3.3 (không codegen), go_router 17, drift 2.29 + drift_flutter, intl 0.20, gen-l10n.

Quy ước bắt buộc (đã có trong code, giữ nguyên):
- Feature-first + MVVM 3 lớp: features/<x>/{data,domain,presentation}. View "dumb", Notifier giữ state bất biến, Repository là đường ghi duy nhất và trả Result<T> (lib/core/result.dart), không ném exception ra ngoài repository.
- Chỉ bootstrap.dart được nhắc tới implementation cụ thể; mọi provider hạ tầng ném lỗi đến khi bootstrap override.
- Tiền là int theo đơn vị nhỏ nhất (VND = 0 chữ số thập phân), dùng Money (lib/core/money.dart). Không bao giờ dùng double cho tiền.
- Thời gian lấy qua Clock (lib/core/clock.dart), không gọi DateTime.now() trực tiếp trong logic.
- Đường dẫn route chỉ khai báo trong lib/routing/routes.dart. Màu/spacing/bo góc chỉ lấy từ lib/theme/tokens.dart.
- Chuỗi hiển thị chỉ nằm trong lib/l10n/app_vi.arb (template) và app_en.arb.
- Test: tự viết fake, không dùng mock; DB test dùng inMemoryDatabase() trong test/helpers.dart.

Definition of Done cho mỗi prompt:
- dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n chạy sạch.
- dart format --set-exit-if-changed . và flutter analyze --fatal-infos sạch.
- flutter test xanh; logic mới có test.
- Không để lại TODO trống, không comment-out code cũ, không thêm package ngoài danh sách được nêu.
Cuối lượt: liệt kê file đã đổi, lệnh đã chạy và kết quả, việc chưa làm được (nếu có).
```

---

## PROMPT 1 – Cài đặt sang shared_preferences + hoàn thiện bootstrap

```
Mục tiêu: chuyển cài đặt app từ bảng Drift AppSettings sang shared_preferences, và chốt thứ tự khởi động trong bootstrap.dart.

Hiện trạng:
- lib/data/tables/settings_table.dart (AppSettings) + lib/data/daos/settings_dao.dart đang lưu theme_mode, locale.
- lib/features/settings/data/settings_repository.dart: SettingsRepository(load/save, cache AppPreferences), settingsRepositoryProvider.
- lib/features/settings/domain/app_preferences.dart: AppPreferences(themeMode, localeCode).
- lib/features/settings/presentation/settings_notifier.dart: appPreferencesProvider, chỉ có setThemeMode. save() không xóa được locale về null.

Việc cần làm:
1. flutter pub add shared_preferences (bản ổn định mới nhất).
2. Tạo lib/services/key_value_store.dart:
   - interface KeyValueStore { String? getString(k); int? getInt(k); bool? getBool(k); Future<void> setString/setInt/setBool(k, v); Future<void> remove(k); }
   - SharedPrefsKeyValueStore bọc SharedPreferencesWithCache (đọc đồng bộ sau khi create), allowList chỉ gồm các key ở bước 3.
   - keyValueStoreProvider ném lỗi đến khi override (giống các service khác).
   - test/fakes/in_memory_key_value_store.dart: fake dùng Map.
3. Mở rộng AppPreferences (bất biến, có copyWith, ==, hashCode):
   themeMode (ThemeMode, mặc định system), localeCode (String?, null = theo hệ thống),
   onboardingCompleted (bool, mặc định false), monthStartDay (int 1..28, mặc định 1), hideBalance (bool, mặc định false).
   Key lưu: 'theme_mode', 'locale', 'onboarding_completed', 'month_start_day', 'hide_balance'. Giá trị lạ/hỏng → dùng mặc định, không crash.
4. Viết lại SettingsRepository dựa trên KeyValueStore: load() đồng bộ (đọc từ cache), save(AppPreferences) trả Future<Result<void>>; locale null thì remove key.
5. AppPreferencesNotifier: thêm setLocale(String?), setOnboardingCompleted(bool), setMonthStartDay(int) (kiểm tra 1..28, sai trả ValidationFailure), setHideBalance(bool). Cập nhật state lạc quan, nếu save lỗi thì trả state cũ.
6. Xóa AppSettings và SettingsDao khỏi @DriftDatabase, xóa file tương ứng và test/data/settings_dao_test.dart.
7. bootstrap.dart, đúng thứ tự:
   WidgetsFlutterBinding.ensureInitialized → CrashLog.open → installErrorHandlers (giữ nguyên, không dùng runZonedGuarded)
   → SharedPrefsKeyValueStore.create() → SettingsRepository.load() (theme có trước khung hình đầu)
   → openAppDatabase() → ProviderScope(overrides: [...]) → runApp.
   Sau khung hình đầu (addPostFrameCallback, unawaited + catchError ghi CrashLog): chạm DB một lần (customSelect('SELECT 1')) để mở DB và chạy seed sớm.
   Nếu tạo prefs thất bại: ghi CrashLog và chạy tiếp với AppPreferences mặc định (không treo app).
8. SettingsScreen: thêm mục chọn ngôn ngữ (Theo hệ thống / Tiếng Việt / English); chuỗi mới vào cả 2 file ARB.
9. test/helpers.dart: buildTestApp override keyValueStoreProvider bằng fake, và override đủ cả 7 provider hạ tầng bằng fake/noop.

Test bắt buộc:
- SettingsRepository: round-trip từng trường; locale null xóa key; giá trị hỏng ('abc' cho theme_mode, 99 cho month_start_day) → mặc định.
- Notifier: setMonthStartDay(0) và (29) trả lỗi, state không đổi.
- app_smoke_test vẫn xanh.

Xong khi: không còn tham chiếu AppSettings/SettingsDao; đổi theme/ngôn ngữ trong Cài đặt, tắt hẳn app mở lại vẫn giữ.
```

---

## PROMPT 2 – Viết lại schema Drift v1 + seed danh mục mặc định

```
Mục tiêu: viết lại schema v1 đúng tài liệu kiến trúc. App chưa phát hành nên GIỮ schemaVersion = 1, không viết migration; xóa app/DB cũ trên máy dev rồi chạy lại.

Hiện trạng: lib/data/database.dart (AppDatabase, openAppDatabase, appDatabaseProvider), tables/{wallets,categories,transactions}_table.dart dùng id int, amount có dấu; migrations/migration_strategy.dart (onCreate chỉ createAll, beforeOpen bật foreign_keys); daos/{wallets,transactions}_dao.dart; lib/core/ids.dart (extension type bọc int). Không có build.yaml, không có CategoriesDao.

Quy ước chung cho mọi bảng:
- id TEXT UUID v4 (package uuid), sinh ở Dart qua một IdGenerator inject được (lib/core/ids.dart) để test cố định được.
- created_at, updated_at, deleted_at (NULL = chưa xóa). Thời gian lưu INTEGER epoch milliseconds UTC qua một TypeConverter EpochMsConverter (DateTime <-> int, luôn .toUtc()).
- Tiền INTEGER. Bảng STRICT (override isStrict => true), có CHECK và khóa ngoại.
- Đổi WalletId/CategoryId/TransactionId trong lib/core/ids.dart sang extension type bọc String.

Bảng (chỉ 3 bảng của giai đoạn 1):
- wallets: id, name (1..64), type CHECK IN ('cash','bank','ewallet','credit'), currency TEXT mặc định 'VND', initial_balance INT mặc định 0 (được âm với thẻ tín dụng), bank_code TEXT NULL, account_masked TEXT NULL, auto_sync BOOL mặc định false, archived BOOL mặc định false, sort_order INT, timestamps.
- categories: id, parent_id FK categories NULL, name (1..64), type CHECK IN ('income','expense'), icon TEXT (khóa icon, không lưu codepoint), color INT (ARGB), sort_order INT, is_default BOOL, system_key TEXT NULL UNIQUE, timestamps.
  Ràng buộc: chỉ 2 cấp (con không có con) – kiểm tra ở DAO; con phải cùng type với cha.
- transactions: id, wallet_id FK, to_wallet_id FK NULL, category_id FK NULL, type CHECK IN ('income','expense','transfer'), amount INT CHECK (amount > 0), occurred_at, note TEXT NULL, source CHECK IN ('manual','notification','webhook','recurring','import') mặc định 'manual', bank_event_id TEXT NULL, recurring_id TEXT NULL (chưa đặt FK – 2 bảng này thêm ở giai đoạn sau bằng migration), timestamps.
  CHECK cấp bảng (customConstraints):
    (type = 'transfer') = (to_wallet_id IS NOT NULL)
    to_wallet_id IS NULL OR to_wallet_id <> wallet_id
    type <> 'transfer' OR category_id IS NULL
- Index: transactions(occurred_at), transactions(wallet_id, occurred_at), transactions(category_id, occurred_at).

Việc cần làm:
1. flutter pub add uuid. Tạo build.yaml: cấu hình drift_dev (sql dialect sqlite, store_date_time_values_as_text: false), khai báo databases: { default: lib/data/database.dart } và schema_dir: drift_schemas/, generate_for giới hạn ở lib/data/**.
2. Viết lại các file bảng + enum Dart tương ứng (WalletType, CategoryType, TransactionType, TransactionSource) dùng textEnum.
3. Migration strategy: beforeOpen bật PRAGMA foreign_keys = ON và kiểm tra lại bằng PRAGMA foreign_keys (sai thì ném StateError ngay khi dev). Bật WAL: dùng tham số setup của DriftNativeOptions trong openAppDatabase nếu bản drift_flutter hiện tại có; nếu không thì customStatement('PRAGMA journal_mode = WAL') trong beforeOpen.
4. onCreate: createAll rồi seed danh mục mặc định trong cùng một transaction. id danh mục mặc định là UUID v5 cố định sinh từ system_key (để sao lưu/đồng bộ sau này nhận ra cùng một danh mục giữa các máy).
   Chi: an_uong "Ăn uống" #E8A87C, di_chuyen "Di chuyển" #7FA7D9, nha_cua "Nhà cửa" #A99BD6, hoa_don "Hóa đơn" #6FB7B7, mua_sam "Mua sắm" #E59AB0, giai_tri "Giải trí" #F0C66B, suc_khoe "Sức khỏe" #8CC79A, giao_duc "Giáo dục" #9BB0E0, khac_chi "Khác" #B5B5B5.
   Thu: luong "Lương" #5FAE8C, thuong "Thưởng" #C9B26B, khac_thu "Khác" #B5B5B5.
   Thêm vài danh mục con cho Ăn uống (Cà phê, Đi chợ) và Hóa đơn (Điện, Nước, Internet) để có dữ liệu cha–con thật.
   Khóa icon dạng chuỗi ('restaurant', 'directions_car', ...). Tạo lib/features/categories/domain/category_icons.dart map khóa → IconData (Icons.*_rounded), khóa lạ → Icons.category_rounded.
   Ghi chú giới hạn đã biết: tên danh mục mặc định lưu tiếng Việt; dịch theo system_key để sau.
5. DAO (mọi truy vấn đọc lọc deleted_at IS NULL; mọi cập nhật tự đặt updated_at từ Clock):
   - WalletsDao: watchActive() (archived = false, theo sort_order), insert, update, archive, watchBalances() trả Map<WalletId, int> tính bằng SQL: initial_balance + SUM(income) − SUM(expense) − SUM(transfer đi) + SUM(transfer đến). Số dư KHÔNG lưu thành cột.
   - CategoriesDao (mới): watchByType(type) trả cây cha–con theo sort_order, insert (kiểm tra 2 cấp, cùng type), update, softDelete.
   - TransactionsDao: watchRecent({limit}), watchInRange(from, to), insert, update, softDelete(id), restore(id) (cho nút Hoàn tác).
   DAO chỉ là truy cập dữ liệu; kiểm tra nghiệp vụ trả Result đặt ở repository của giai đoạn sau – ở đây chỉ cần DAO + test.
6. Chạy dart run drift_dev make-migrations để tạo drift_schemas/ snapshot v1 và khung test migration (test/drift/...). Commit cả snapshot.
7. Cập nhật mọi chỗ đang dùng schema cũ (home_screen, test/helpers.dart, integration_test).

Test bắt buộc (NativeDatabase.memory()):
- Seed: đúng 12 danh mục gốc + các con; chạy onCreate 2 lần trên 2 DB cho ra cùng id (v5 cố định).
- CHECK: insert amount = 0, amount âm, transfer thiếu to_wallet_id, transfer có category_id, to_wallet_id = wallet_id → đều bị từ chối.
- Khóa ngoại: transaction trỏ tới wallet không tồn tại → bị từ chối (chứng minh foreign_keys đang bật).
- Số dư: ví A (initial 1.000.000) có thu 500.000, chi 200.000, chuyển sang B 100.000 → A = 1.200.000, B = initial_B + 100.000. Giao dịch đã xóa mềm không được tính; restore thì tính lại.
- Thời gian: lưu rồi đọc lại DateTime giữ đúng mili giây và là UTC.
- Danh mục: tạo cháu (cấp 3) hoặc con khác type → lỗi.

Xong khi: build_runner sạch, drift_schemas/drift_schema_v1.json tồn tại, toàn bộ test xanh.
```

---

## PROMPT 3 – Theme: token màu, font Be Vietnam Pro, typography, component theme

```
Mục tiêu: dựng hệ thống thiết kế theo đặc tả dưới đây thành ThemeData sáng/tối. Không làm màn hình mới.

Chuẩn bị (bạn tự làm trước, agent KHÔNG tải từ mạng): tải Be Vietnam Pro từ Google Fonts, chép BeVietnamPro-Regular.ttf, -Medium.ttf, -SemiBold.ttf, -Bold.ttf và OFL.txt vào assets/fonts/. Agent kiểm tra đủ 5 file, thiếu thì dừng và báo.

Hiện trạng: lib/theme/ có AppColors (seed 0xFF1B8A5A, income, expense), AppSpacing (xs 4..xl 32), AppRadius (sm 8, md 12, lg 20), AppTheme.light()/dark() dùng ColorScheme.fromSeed; chưa có font/typography/ThemeExtension.

Đặc tả (nguồn duy nhất):
BẢNG MÀU – CHẾ ĐỘ SÁNG
- Màu chủ đạo (primary): #3F7D6E (xanh lá ngả ngọc, trầm và dịu)
- Nền nhạt của primary (primary container): #DCEFE9
- Nền app: #F7F6F2 (trắng ngà ấm, không dùng trắng tinh)
- Thẻ / bề mặt: #FFFFFF
- Bề mặt phụ (ô nhập, chip chưa chọn): #EFEEE9
- Chữ chính: #1F2A2E | Chữ phụ: #5F6B70 | Chữ mờ / placeholder: #9AA3A7
- Đường kẻ phân cách: #E6E4DE
- Thu nhập: #2E8B6A, nền #E3F4EC
- Chi tiêu: #D0685A (đỏ san hô dịu, KHÔNG dùng đỏ tươi), nền #FBE9E6
- Cảnh báo (gần hết ngân sách): #D9A441, nền #FBF1DC
- Chuyển khoản giữa các ví / thông tin: #5B7FB5, nền #E7EEF8

BẢNG MÀU – CHẾ ĐỘ TỐI (không dùng đen tuyền)
- Nền: #121615 | Thẻ: #1A201F | Bề mặt phụ: #222A28
- Chữ chính: #E6ECEA | Chữ phụ: #A3B0AC
- Primary: #7CC2AE | Thu: #6FCF9F | Chi: #EE8F82 | Cảnh báo: #E8BE6A

MÀU DANH MỤC (pastel, độ bão hòa thấp; icon trong vòng tròn nền nhạt)
Ăn uống #E8A87C, Di chuyển #7FA7D9, Nhà cửa #A99BD6, Hóa đơn #6FB7B7,
Mua sắm #E59AB0, Giải trí #F0C66B, Sức khỏe #8CC79A, Giáo dục #9BB0E0,
Lương #5FAE8C, Thưởng #C9B26B, Khác #B5B5B5

KIỂU CHỮ
- Font: "Be Vietnam Pro" (hiển thị dấu tiếng Việt đẹp). Toàn bộ chữ trên giao diện bằng tiếng Việt có dấu.
- Số tiền dùng chữ số đều độ rộng (tabular numbers) để các cột thẳng hàng.
- Số dư lớn: 32px, đậm (700)
- Tiêu đề màn hình: 22px, 600
- Tiêu đề mục / thẻ: 17px, 600
- Nội dung: 15–16px, 400; số tiền trong danh sách: 16px, 600
- Chú thích: 13px, 400, màu chữ phụ. Không dùng chữ nhỏ hơn 12px.

ĐỊNH DẠNG DỮ LIỆU
- Tiền: "1.250.000 ₫" (dấu chấm phân cách hàng nghìn, ký hiệu ₫ đặt sau).
- Khoản thu có dấu "+" và màu thu nhập; khoản chi có dấu "−" và màu chi tiêu.
  Không chỉ phân biệt bằng màu: luôn kèm dấu +/− và icon mũi tên.
- Ngày: "Hôm nay", "Hôm qua", "Thứ Hai, 16/11/2026". Giờ: "14:30".

KHOẢNG CÁCH & HÌNH KHỐI
- Lưới 8px. Lề hai bên màn hình 20px. Khoảng cách giữa các thẻ 12–16px.
- Bo góc: thẻ 20px, nút 14px, ô nhập 14px, bottom sheet 28px (góc trên), chip dạng viên thuốc.
- Đổ bóng rất nhẹ hoặc không có; phân lớp chủ yếu bằng màu nền.
- Vùng chạm tối thiểu 48x48px.

ICON
- Bộ icon nét tròn mềm (Material Symbols Rounded hoặc Phosphor), độ dày nét 1.5–2px.
- Icon danh mục: đặt trong vòng tròn 40px, nền là màu danh mục độ đậm 20%, icon là màu danh mục.

THÀNH PHẦN DÙNG CHUNG
- Nút chính: nền primary, chữ trắng, cao 52px, bo 14px, rộng toàn màn hình khi ở cuối form.
- Nút phụ: viền 1px primary hoặc nền primary container.
- Nút nổi (FAB) "+": tròn 60px, màu primary, nằm giữa thanh điều hướng dưới.
- Thanh điều hướng dưới 5 vị trí: "Tổng quan", "Giao dịch", [nút + ở giữa], "Báo cáo", "Tài khoản".
  Mục đang chọn: icon đậm + chữ màu primary + nền viên thuốc primary container.
- Dòng giao dịch: [icon danh mục tròn] [tên danh mục đậm + ghi chú/ví nhỏ bên dưới] ......... [số tiền căn phải + giờ nhỏ bên dưới].
- Thanh tiến độ ngân sách: cao 8px, bo tròn; dưới 80% màu primary, 80–100% màu cảnh báo, vượt 100% màu chi tiêu.
- Trạng thái trống: hình minh họa đường nét mảnh, màu pastel + 1 câu hướng dẫn thân thiện + 1 nút hành động.
- Skeleton loading màu bề mặt phụ, không dùng vòng xoay.
- Snackbar thông báo nhỏ ở phía dưới, có nút "Hoàn tác" khi xóa.

KHẢ NĂNG TIẾP CẬN
- Độ tương phản chữ đạt WCAG AA trở lên.
- Hỗ trợ phóng to chữ hệ thống mà không vỡ bố cục.
- Không đặt thông tin quan trọng ở góc trên cùng khó với tới bằng một tay; hành động chính đặt ở nửa dưới màn hình.

Việc cần làm:
1. pubspec.yaml: khai báo family 'BeVietnamPro' với 4 weight 400/500/600/700. Không dùng google_fonts.
2. lib/theme/tokens.dart viết lại:
   - AppPalette.light / AppPalette.dark: đúng mã hex trong đặc tả.
   - AppSpacing theo lưới 8 (4, 8, 12, 16, 20, 24, 32) + screenGutter = 20, cardGap = 12.
   - AppRadius: card 20, button 14, input 14, sheet 28, pill = StadiumBorder.
   - AppSizes: minTouch 48, buttonHeight 52, fab 60, categoryIcon 40, progressBar 8.
   - CategoryPalette: map system_key → màu (khớp seed ở prompt 2).
3. ThemeExtension AppColors (có copyWith + lerp) cho màu ngữ nghĩa mà ColorScheme không có: income/incomeBg, expense/expenseBg, warning/warningBg, transfer/transferBg, textSecondary, textMuted, divider, surfaceAlt, và các biến thể chữ incomeText/expenseText/warningText.
   Lý do có biến thể chữ: theo tính toán, #D0685A trên nền trắng chỉ đạt ~3,6:1 và #2E8B6A ~4,2:1, chưa đủ 4,5:1 (AA) cho số tiền 16px. Giữ màu gốc cho icon, nền, biểu đồ; dùng biến thể đậm hơn cho CHỮ (gợi ý bắt đầu: expenseText #B5523F, incomeText #2A7A5E), chỉnh tới khi test tương phản qua.
   textMuted (#9AA3A7 ~2,4:1) chỉ dùng cho placeholder, trạng thái disabled, đồ họa trang trí – chú thích dùng textSecondary.
   Chế độ tối: đặc tả không cho primaryContainer, divider, textMuted, transfer, nền thu/chi – tự suy ra (ví dụ màu gốc ở độ đục 16–20% trên nền thẻ) và cũng phải qua test tương phản.
4. ColorScheme dựng tay (không fromSeed) từ AppPalette: primary, onPrimary trắng, primaryContainer, surface = nền thẻ, surfaceContainerLowest/Low = nền app/bề mặt phụ, error = chi tiêu, outlineVariant = divider. scaffoldBackgroundColor = nền app.
5. lib/theme/typography.dart: TextTheme dùng fontFamily 'BeVietnamPro', ánh xạ:
   headlineMedium 22/600 (tiêu đề màn hình), titleMedium 17/600 (tiêu đề mục/thẻ), bodyLarge 16/400, bodyMedium 15/400, bodySmall 13/400 màu textSecondary, labelLarge 16/600.
   Thêm AppTextStyles (ThemeExtension) cho tiền: balanceLarge 32/700, amountList 16/600 – cả hai bật FontFeature.tabularFigures(). Không style nào nhỏ hơn 12px.
6. Component theme: FilledButton (cao 52, bo 14, rộng tối thiểu 48), OutlinedButton (viền 1px primary), InputDecorationTheme (filled surfaceAlt, bo 14, không viền khi chưa focus), CardTheme (bo 20, elevation 0), BottomSheetTheme (bo trên 28), ChipTheme (StadiumBorder), SnackBarTheme (floating), DividerTheme, FloatingActionButtonTheme (tròn, primary), materialTapTargetSize padded, visualDensity standard.
7. Thêm 2 widget dùng chung vào lib/theme/widgets/: CategoryAvatar (vòng 40px, nền màu danh mục 20%, icon màu danh mục; có Semantics label) và EmptyState (icon/hình nét mảnh + 1 câu + 1 nút hành động tùy chọn). Màn hình tạm có thể dùng EmptyState.

Test bắt buộc:
- test/theme/contrast_test.dart: hàm tính tỉ lệ tương phản WCAG; assert ≥ 4,5 cho mọi cặp chữ/nền thực dùng (textPrimary, textSecondary, incomeText, expenseText, warningText, onPrimary/primary) ở CẢ sáng và tối; ≥ 3 cho icon/viền quan trọng.
- AppColors.lerp và copyWith đúng.
- Widget test: Theme.of(context).textTheme.bodyLarge.fontFamily == 'BeVietnamPro'; balanceLarge có tabularFigures.
- Widget test render CategoryAvatar + EmptyState với textScaler 2.0 không overflow.

Xong khi: app chạy với font mới, sáng/tối đúng bảng màu, test tương phản xanh.
```

---

## PROMPT 4 – Formatter tiền/ngày + l10n cho khung app

```
Mục tiêu: một chỗ duy nhất định dạng tiền và ngày theo đặc tả, và đủ chuỗi l10n cho các màn khung.

Hiện trạng: Money.format({locale='vi_VN'}) dùng NumberFormat.currency với ký hiệu ₫. ARB có 8 key. Có Clock/FixedClock và extension DateOnly.

Việc cần làm:
1. lib/core/formatting/money_format.dart:
   - formatMoney(Money) → "1.250.000 ₫" (dấu chấm nghìn, khoảng trắng không ngắt, ₫ phía sau, 0 chữ số thập phân), tái dùng Money.format nếu đã đúng, nếu không thì sửa Money.format.
   - formatSigned(Money, TransactionType) → thu "+1.250.000 ₫", chi "−1.250.000 ₫" (U+2212, không phải gạch nối), chuyển khoản không dấu.
   - formatMasked() → "••••••" cho chế độ ẩn số dư.
2. lib/core/formatting/date_format.dart: nhận Clock + locale + chuỗi l10n (không tự gọi DateTime.now):
   - dayLabel(DateTime) → "Hôm nay" / "Hôm qua" / "Thứ Hai, 16/11/2026" (vi) và "Today" / "Yesterday" / "Monday, 16/11/2026" (en). So sánh theo ngày giờ địa phương, không theo UTC.
   - timeLabel → "14:30" (24h).
   - Gọi initializeDateFormatting cho 'vi' và 'en' ở bootstrap (trước runApp) và trong setUpAll của test.
3. ARB (vi là template, en dịch tương ứng, có @description cho mỗi key): tabOverview "Tổng quan", tabTransactions "Giao dịch", tabReports "Báo cáo", tabAccount "Tài khoản", addTransaction "Thêm giao dịch", today, yesterday, languageSystem/languageVi/languageEn, undo "Hoàn tác", và câu trạng thái trống cho từng tab (giọng thân thiện, 1 câu).
4. Thay mọi chuỗi cứng còn sót trong lib/ bằng l10n (tìm bằng grep các literal tiếng Việt trong Text(...)).

Test bắt buộc:
- Tiền: 0, 1.000, 1.250.000, 1.000.000.000, số âm; ký tự trừ là U+2212; khoảng trắng là U+00A0.
- Ngày với FixedClock: hôm nay, hôm qua, 2 ngày trước, qua nửa đêm, đầu năm (31/12 → 1/1), cả vi và en.
- Policy test: không file nào trong lib/ (trừ lib/l10n/gen) chứa literal tiếng Việt có dấu trong Text(' – chỉ cần grep đơn giản.

Xong khi: formatter có test đầy đủ, đổi ngôn ngữ trong Cài đặt thì toàn bộ chuỗi khung đổi theo.
```

---

## PROMPT 5 – Router: StatefulShellRoute 4 tab + nút "+" ở giữa

```
Mục tiêu: khung điều hướng chính theo đặc tả: thanh dưới 5 vị trí "Tổng quan", "Giao dịch", [nút + ở giữa], "Báo cáo", "Tài khoản".

Hiện trạng: lib/routing/routes.dart (home '/', settings '/settings'); lib/routing/router.dart: routerProvider (Provider<GoRouter>), 1 GoRoute + con 'settings', có ref.onDispose(router.dispose). HomeScreen có nút mở settings.

Việc cần làm:
1. Routes: onboarding '/onboarding', overview '/overview', transactions '/transactions', reports '/reports', account '/account', settings '/account/settings', addTransaction '/add'. initialLocation = overview.
2. router.dart: rootNavigatorKey; StatefulShellRoute.indexedStack với 4 branch (mỗi branch một navigatorKey riêng, giữ state cuộn khi đổi tab). settings là route con của account. addTransaction là route cấp gốc (parentNavigatorKey: root) mở dạng fullscreenDialog / trang trượt từ dưới lên, che thanh điều hướng.
3. Redirect onboarding: đọc appPreferencesProvider; chưa onboardingCompleted → '/onboarding'; đã xong mà vào '/onboarding' → overview. Dùng refreshListenable (hoặc ref.listen + router.refresh) để không tạo lại GoRouter khi prefs đổi. Màn onboarding tạm: 1 nút "Bắt đầu" gọi setOnboardingCompleted(true).
4. lib/theme/widgets/app_bottom_bar.dart (không dùng NavigationBar mặc định vì cần nút giữa):
   - 4 mục + FAB tròn 60px màu primary ở giữa, Semantics label = l10n.addTransaction.
   - Mục đang chọn: icon filled + chữ màu primary + nền viên thuốc primaryContainer; mục khác: icon outlined/rounded + textSecondary. Không chỉ phân biệt bằng màu (icon đổi kiểu filled/outlined).
   - Mỗi mục vùng chạm ≥ 48x48, Semantics(selected:, button: true). Bấm lại tab đang mở → goBranch(index, initialLocation: true).
   - Tôn trọng SafeArea dưới; textScaler lớn thì thanh cao lên, không cắt chữ, không ellipsis, không FittedBox.
5. Màn tạm cho 4 tab trong features/<x>/presentation/ (overview → features/home, transactions, reports, account → features/settings hoặc features/account): mỗi màn có tiêu đề (headlineMedium) và EmptyState với câu l10n ở prompt 4. Tài khoản có mục mở Cài đặt. Bỏ nút settings trên HomeScreen.
6. Màn Thêm giao dịch tạm: tiêu đề + nút đóng, chưa có form.
7. Nút Back Android: ở tab khác Tổng quan → về Tổng quan; ở Tổng quan → thoát app.

Test bắt buộc (widget test qua buildTestApp):
- Chưa onboarding → thấy màn onboarding; bấm Bắt đầu → thấy "Tổng quan".
- Bấm từng tab → đúng màn; đổi tab rồi quay lại giữ vị trí cuộn của danh sách giả.
- Bấm "+" → mở màn Thêm giao dịch, thanh dưới bị che; đóng → về đúng tab cũ.
- Tab Tài khoản → Cài đặt → back → về Tài khoản.
- textScaler 2.0 và màn rộng 320px: không overflow ở thanh dưới.
- Cập nhật app_smoke_test và integration_test/app_test.dart theo luồng mới.

Xong khi: chạy trên emulator Android chuyển tab mượt, nút + mở/đóng đúng, back hoạt động như trên.
```

---

## PROMPT 6 – Rà soát cuối giai đoạn 1

```
Mục tiêu: xác nhận khung app đạt "Kết quả: khung app chạy được" của giai đoạn 1 (bỏ qua CI). Không thêm tính năng mới; chỉ sửa lỗi tìm thấy.

1. Chạy: flutter clean → flutter pub get → dart run build_runner build --delete-conflicting-outputs → flutter gen-l10n → dart format --set-exit-if-changed . → flutter analyze --fatal-infos → flutter test → flutter test integration_test (trên emulator). Báo kết quả từng lệnh.
2. Kiểm tra file sinh ra: chạy lại build_runner lần 2, git diff (hoặc so sánh) không đổi gì.
3. Rà bằng grep, báo vi phạm kèm file:dòng:
   - DateTime.now( ngoài lib/core/clock.dart
   - double đi cùng amount/balance/money
   - Color(0x / Colors. ngoài lib/theme/
   - chuỗi đường dẫn '/...' trong GoRoute/context.go ngoài lib/routing/routes.dart
   - catch rỗng, catch (_) {} không ghi log
4. Chạy app thật trên emulator Android: sáng, tối, cỡ chữ hệ thống lớn nhất, tiếng Việt và tiếng Anh. Chụp màn hình 4 tab + Thêm giao dịch + Cài đặt ở mỗi chế độ, lưu vào docs/screenshots/phase1/.
5. Cập nhật README.md: cách chạy, lệnh codegen, cấu trúc thư mục, quy ước (lấy từ Prompt 0), vị trí font và giấy phép OFL.
6. Liệt kê nợ kỹ thuật còn lại (ví dụ: dịch tên danh mục mặc định, applicationId còn com.example, ký release bằng debug key) – chỉ liệt kê, không sửa.
```
