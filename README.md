# Ví Xanh

App quản lý chi tiêu cá nhân (VND), offline-first: dữ liệu nằm trong SQLite trên máy là bản chuẩn.
Flutter 3.32.1 stable · Dart ^3.8.1 · Riverpod 3 · go_router · drift · gen-l10n.

## Chạy app

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib/data
flutter gen-l10n
flutter run
```

Trên Windows cần bật **Developer Mode** (`start ms-settings:developers`), nếu không `flutter pub get`
báo lỗi symlink và không build được app (test vẫn chạy).

Đổi schema DB hoặc cài lại sau khi schema v1 thay đổi trong lúc phát triển: gỡ app cũ trên máy trước.

## Sinh code

| Lệnh | Sinh ra |
|---|---|
| `dart run build_runner build --delete-conflicting-outputs` | `lib/data/**/*.g.dart` (drift) |
| `dart format lib/data` | Chạy ngay sau build_runner: bản build sạch sinh `database.g.dart` chưa theo `page_width: 100` |
| `flutter gen-l10n` | `lib/l10n/gen/` từ `app_vi.arb` (template) và `app_en.arb` |
| `dart run drift_dev make-migrations` | `drift_schemas/` + test migration, chạy mỗi khi tăng `schemaVersion` |

## Kiểm tra trước khi xong một việc

```bash
dart format --set-exit-if-changed .
```

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

```bash
flutter test integration_test
```

(integration test cần thiết bị/emulator Android.)

## Cấu trúc thư mục

```
lib/
├── main.dart          # chỉ gọi bootstrap()
├── bootstrap.dart     # composition root: bắt lỗi → đọc cài đặt → mở DB → ProviderScope → runApp
├── app.dart           # MaterialApp.router
├── core/              # thuần Dart: Result, Failure, Money, Clock, ids, enums, formatting/
├── data/              # drift: database.dart, tables/, daos/, seed/, migrations/
├── services/          # interface + impl hạ tầng (key-value store, backup, notification, ...)
├── native/            # MethodChannel/EventChannel — nơi duy nhất gọi native
├── routing/           # routes.dart, router.dart, app_shell.dart
├── theme/             # tokens, AppColors, typography, AppTheme, widgets/ dùng chung
├── l10n/              # app_vi.arb, app_en.arb, gen/
└── features/<x>/{data,domain,presentation}
assets/fonts/          # Be Vietnam Pro + OFL.txt
drift_schemas/         # snapshot schema từng phiên bản
test/                  # cấu trúc giống lib/, fakes/, policy/
```

## Quy ước

- Feature-first + MVVM 3 lớp. View "dumb", Notifier giữ state bất biến, Repository là đường ghi duy
  nhất và trả `Result<T>` — không ném exception ra ngoài repository.
- Chỉ `bootstrap.dart` nhắc tới implementation cụ thể; provider hạ tầng ném lỗi tới khi được override.
- Tiền là `int` theo đơn vị nhỏ nhất (VND = đồng), dùng `Money`. Không bao giờ dùng `double` cho tiền.
  `amount` của giao dịch luôn > 0, chiều tiền nằm ở `type`. Số dư luôn tính lại từ giao dịch.
- Thời gian lấy qua `Clock`, không gọi `DateTime.now()` trong logic. DB lưu epoch ms UTC.
- Id là UUID (v4; danh mục mặc định dùng v5 cố định theo `system_key`). Xóa là xóa mềm (`deleted_at`).
- Route path chỉ khai báo trong `lib/routing/routes.dart`. Màu/spacing/bo góc chỉ lấy từ `lib/theme/`.
- Chuỗi hiển thị chỉ nằm trong ARB (`test/policy/` chặn `Text('...')` tiếng Việt viết cứng).
- Định dạng tiền/ngày chỉ qua `lib/core/formatting/`.
- Test tự viết fake (`test/fakes/`), không mock; DB test dùng `inMemoryDatabase()`.
- Migration: mỗi lần tăng `schemaVersion` thêm một nhánh `from < N`, không sửa nhánh cũ.

## Font

Be Vietnam Pro (Regular 400, Medium 500, SemiBold 600, Bold 700) đóng gói trong `assets/fonts/`, lấy từ
kho [google/fonts](https://github.com/google/fonts/tree/main/ofl/bevietnampro). Giấy phép SIL Open Font
License 1.1 — xem `assets/fonts/OFL.txt`. Font không có chữ số đều độ rộng (`tnum`), nên số tiền không
thẳng cột tuyệt đối.

## Nợ kỹ thuật còn lại (sau giai đoạn 1)

- Chưa chạy app/integration test trên thiết bị thật; chưa có ảnh chụp màn hình sáng/tối/chữ lớn.
- Thư mục chưa phải git repo.
- `applicationId`/`namespace` Android còn `com.example.vi_xanh_app`; label app còn `vi_xanh_app`.
- Bản release đang ký bằng debug key.
- Tên danh mục mặc định lưu tiếng Việt, chưa dịch theo ngôn ngữ app (`system_key` đã có sẵn để làm).
- Be Vietnam Pro không có `tnum`: số tiền chưa thẳng cột.
- FK `transactions.bank_event_id` / `recurring_id` chưa có — thêm bằng migration khi tạo 2 bảng đó.
- Test giữ vị trí cuộn khi đổi tab mới kiểm tra tab còn trong cây widget; làm lại khi có danh sách thật.
- Test widget chạy bằng font giả của Flutter, chưa kiểm chứng bố cục với font thật.
- `NotificationService`, `BackupService.restoreFrom`, `SyncService`, `AuthService` vẫn là bản tạm/noop.
- Lỗi chưa gửi lên dịch vụ giám sát (Crashlytics/Sentry) — mới ghi file `crash.log` cục bộ.
- Chưa có CI (cố ý để sau).
