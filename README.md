# Mobile Tech Store

Ứng dụng thương mại điện tử bán đồ điện tử được phát triển bằng Flutter và Firebase.

## Công nghệ sử dụng

- Core: Flutter SDK
- State Management: Riverpod
- Database: Firebase Cloud Firestore
- Authentication: Firebase Authentication
- Local Testing: Flutter Chrome/Android

## Kiến trúc dự án

Dự án được thiết kế theo phương pháp Clean Architecture chia làm các tầng:
- Domain: Chứa các thực thể (Entities) và giao diện Repository (Repository Interfaces) độc lập với framework.
- Data: Chứa các Model kế thừa từ Entity hỗ trợ serialization và lớp triển khai Repository để tương tác với Firebase Firestore.
- Presentation: Chứa các Widget (Views) và các StateNotifier/Providers để quản lý trạng thái và logic giao diện.

## Các tính năng chính

### Giao diện & Điều hướng (UI & Navigation)
- **Thanh điều hướng dưới (Bottom Navigation Bar)**: Giúp người dùng dễ dàng chuyển đổi nhanh chóng giữa các màn hình chính:
  - **Trang chủ**: Tìm kiếm, lọc danh mục sản phẩm và danh sách sản phẩm.
  - **Đơn hàng**: Lịch sử đặt hàng và trạng thái đơn hàng.
  - **Phản hồi**: Gửi ý kiến đóng góp trực tiếp về ứng dụng.
  - **Hồ sơ**: Quản lý thông tin tài khoản, đổi mật khẩu và đăng xuất.

### Quyền Admin (Admin Role)
- Quản lý danh mục sản phẩm (Category): Thêm, sửa, xóa, tìm kiếm và hiển thị danh sách.
- Quản lý sản phẩm (Product): Thêm, sửa, xóa, tìm kiếm và hiển thị thông tin.
- Quản lý thương hiệu (Brand): Thêm, sửa, xóa và hiển thị danh sách thương hiệu.
- Quản lý đơn hàng (Order): Danh sách đơn hàng phân chia theo tab trạng thái (Đang xử lý, Đã hoàn thành), cho phép cập nhật trạng thái đơn hàng.
- Quản lý khuyến mãi (Promotion): Thêm, sửa, xóa và hiển thị mã khuyến mãi để kích cầu mua sắm. Hỗ trợ thiết lập thời gian hết hạn (ngày & giờ); mã sẽ tự động dừng hoạt động khi quá hạn.
- Thống kê và báo cáo: Theo dõi doanh thu và danh sách sản phẩm bán chạy theo thời gian.
- Xem phản hồi: Nhận và quản lý các ý kiến, đóng góp từ người dùng.

### Quyền Người dùng (User Role)
- Tài khoản: Đăng ký, đăng nhập, quên mật khẩu, đổi mật khẩu, hiển thị thông tin profile và đăng xuất.
- Trang chủ và tìm kiếm: Tìm kiếm sản phẩm theo từ khóa, slide banner sản phẩm nổi bật tự động chuyển tiếp.
- Danh sách sản phẩm: Hiển thị danh sách sản phẩm theo phân loại tab realtime từ Firebase, lọc sản phẩm theo giá, xếp hạng và khuyến mãi.
- Chi tiết sản phẩm: Xem thông tin ảnh, tên, giá, mô tả và thông số kỹ thuật sản phẩm.
- Đánh giá sản phẩm: Tính năng gửi xếp hạng và đánh giá nhận xét sản phẩm.
- Giỏ hàng: Realtime đồng bộ hóa với Firebase. Thêm/bớt số lượng hoặc xóa sản phẩm khỏi giỏ hàng.
- Thanh toán (Checkout):
  - Chọn hoặc thêm địa chỉ giao hàng mới linh hoạt.
  - Lựa chọn phương thức thanh toán: Thanh toán khi nhận hàng (COD) hoặc Chuyển khoản.
  - Tra cứu và áp dụng tự động mã giảm giá hợp lệ từ Firestore (hỗ trợ autocomplete). Hiển thị thông báo "Mã giảm giá không khả dụng." khi áp dụng mã đã hết hạn hoặc không hợp lệ.
- Lịch sử đơn hàng: Xem danh sách đơn hàng và lịch trình trạng thái giao nhận.
- Gửi feedback: Gửi kiến nghị và đánh giá về chất lượng ứng dụng.

## Hướng dẫn chạy và triển khai ứng dụng

1. Cài đặt các thư viện:
   ```bash
   flutter pub get
   ```
2. Chạy ứng dụng trên trình duyệt Chrome hoặc thiết bị giả lập ở môi trường local:
   ```bash
   flutter run -d chrome
   ```
3. Triển khai ứng dụng (Deploy):
   > [!IMPORTANT]
   > Để các thay đổi code mới nhất xuất hiện trên web đã deploy, bạn **bắt buộc** phải biên dịch lại phiên bản web trước khi deploy lên Firebase:
   
   *Bước 3.1. Biên dịch ứng dụng cho nền tảng Web:*
   ```bash
   flutter build web
   ```
   *Bước 3.2. Deploy lên Firebase Hosting:*
   ```bash
   firebase deploy --only hosting
   ```
4. Cập nhật quy tắc bảo mật Firestore (nếu có thay đổi trong `firestore.rules`):
   ```bash
   firebase deploy --only firestore:rules
   ```

