# Ảnh chụp MVP — rà soát giao diện

Chụp ngày 20/11/2026 trên emulator Android 9, màn **360×640 dp** (720×1280 px, mật độ 2x), dữ liệu
giả (2 ví, 60 giao dịch trong 28 ngày, tên "Minh"). Thiết kế gốc vẽ ở 390×844, nên đây là trường hợp
màn **nhỏ hơn** thiết kế.

| Tiền tố | Biến thể |
|---|---|
| `light-vi-*` | Sáng, tiếng Việt, chữ 1x |
| `dark-vi-*` | Tối, tiếng Việt, chữ 1x |
| `light-en-*` | Sáng, English, chữ 1x |
| `large-vi-*` | Sáng, tiếng Việt, **chữ 2x** |

Màn: `1-overview`, `2-transactions`, `3-reports`, `4-account`, `5-add`, `6-wallets`, `7-categories`.

Chụp lại (cần thiết bị/emulator đang chạy và `adb` trong PATH, hoặc đặt biến `ADB`):

```bash
bash tool/capture_screenshots.sh emulator-5554
```

## Chỗ lệch tìm thấy

Đây là phần rà bằng mắt từng ảnh, không phải so pixel với artboard.

### BLOCKER

Không còn chỗ nào.

### FIX — đã sửa trong lượt rà soát này

1. **Số tiền lớn bị ngắt giữa các chữ số** ở màn 360dp, ví dụ "130.513.0 / 00 ₫" ở Tài sản ròng,
   "+110.946.00 / 0 ₫" ở tóm tắt tháng của Giao dịch, và số dư Tổng quan khi chữ 2x. Đã thêm
   `AmountText`: số tiền luôn nằm trên một dòng, chỉ thu nhỏ khi thiếu chỗ.
2. **Nhãn thanh điều hướng bị ngắt giữa chữ**: "Transacti / ons" (en), "Tài khoả / n" (chữ 2x).
   Nhãn giờ nằm trên một dòng, thiếu chỗ thì thu nhỏ, như thiết kế.
3. **Đổi "Ngày bắt đầu tháng" ở Tài khoản làm Tổng quan và Báo cáo báo lỗi rồi giữ số cũ.** Nguyên
   nhân: Riverpod 3 tạm dừng provider của tab ẩn. Đã thay khung tab bằng `BranchStack` (không tắt
   ticker của tab ẩn).
4. **Báo cáo không tính lại kỳ** sau khi đổi ngày bắt đầu tháng: kỳ đang xem giờ theo ngày mới.
5. **File sao lưu cũ tích lại trong máy** sau mỗi lần sao lưu: giờ chỉ giữ bản mới nhất (bản đã
   chia sẻ ra ngoài thì vẫn còn ở nơi người dùng lưu).

### FIX — còn mở

6. **Thêm giao dịch trên màn thấp (640dp).** Ở chữ 1x, lưới danh mục nằm dưới bàn phím số, phải
   cuộn mới thấy. Ở chữ 2x, ô số tiền cũng bị bàn phím che. Cần làm lại bố cục, ví dụ bàn phím thu
   gọn được hoặc phím nhỏ hơn khi màn thấp.
7. **Tên ví một từ dài bị ngắt giữa chữ** ("Vietcomba / nk") ở thẻ ví của Tổng quan và ở danh sách
   Ví của tôi.

### NOTE

8. Ở tâm biểu đồ tròn của Báo cáo, ký hiệu "₫" xuống dòng riêng khi màn 360dp. Con số vẫn nguyên.
9. Hàng chip lọc ở Giao dịch bị cắt ở mép phải. Đây là chủ ý, vì hàng đó cuộn ngang.
10. Ở chữ 2x, nhiều nhãn xuống 2–3 dòng ("Ví của / tôi", "Tổng tài / sản"). Không tràn, đọc được.
11. Chế độ tối: màu nền, thẻ, chữ phụ và màu thu/chi nhất quán, chưa thấy chỗ tương phản kém.
12. Chưa chụp ở màn cao (≥ 800dp) giống khung thiết kế. Nên chụp thêm khi có máy thật.
