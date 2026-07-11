# Quy tắc phát triển (Development Rules)

## Quy tắc bắt buộc khi hoàn thành một tính năng

Mỗi khi làm **xong một tính năng**, bắt buộc phải:

1. **Kiểm thử tính năng** — chạy thử luồng thực tế (không chỉ build/analyze) để xác nhận tính năng hoạt động đúng như mong đợi.

2. **Viết testcase** — viết test tự động cho tính năng vừa làm, đặt trong thư mục `test/`.

3. **Xử lý tất cả các lỗi có thể xảy ra** — testcase phải bao phủ:
   - **Happy path**: luồng thành công bình thường.
   - **Đầu vào không hợp lệ**: rỗng, sai định dạng, vượt giới hạn, giá trị biên.
   - **Lỗi từ dịch vụ ngoài**: mạng lỗi/timeout, Firebase/API trả lỗi, dữ liệu trả về sai định dạng.
   - **Trạng thái đặc biệt**: danh sách rỗng, chưa đăng nhập, phiên hết hạn, quyền bị từ chối.
   - **Lỗi nghiệp vụ**: mật khẩu yếu/không khớp, email đã tồn tại, tài khoản không tồn tại, sai thông tin đăng nhập.

## Tiêu chuẩn chất lượng

- `flutter analyze` phải sạch (không warning, không error) trước khi coi là xong.
- `flutter test` phải pass toàn bộ.
- Mọi lỗi phải được bắt và hiển thị thông điệp rõ ràng cho người dùng (tiếng Việt), không để app crash.
- Test đặt đúng cấu trúc theo feature, ví dụ: `test/features/auth/...`.

## Quy trình chốt tính năng (Definition of Done)

- [ ] Code hoàn thành theo đúng kiến trúc hiện có (clean architecture + Riverpod).
- [ ] `flutter analyze` sạch.
- [ ] Đã viết testcase bao phủ happy path + tất cả trường hợp lỗi ở trên.
- [ ] `flutter test` pass toàn bộ.
- [ ] Đã kiểm thử luồng thực tế của tính năng.
