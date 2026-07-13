# Toy App

Ung dung thuong mai dien tu ban do choi va do dien tu duoc phat trien bang Flutter va Firebase.

## Cong nghe su dung

- Core: Flutter SDK
- State Management: Riverpod
- Database: Firebase Cloud Firestore
- Authentication: Firebase Authentication
- Local Testing: Flutter Chrome/Android

## Kien truc du an

Du an duoc thiet ke theo phuong phap Clean Architecture chia lam cac tang:
- Domain: Chua cac thuc the (Entities) va giao dien Repository (Repository Interfaces) doc lap voi framework.
- Data: Chua cac Model ke thua tu Entity ho tro serialization va lop trien khai Repository de tuong tac voi Firebase Firestore.
- Presentation: Chua cac Widget (Views) va cac StateNotifier/Providers de quan ly trang thai va logic giao dien.

## Cac tinh nang chinh

### Role Admin
- Quan ly danh muc san pham (Category): Them, sua, xoa, tim kiem va hien thi danh sach.
- Quan ly san pham (Product): Them, sua, xoa, tim kiem va hien thi thong tin.
- Quan ly thuong hieu (Brand): Them, sua, xoa va hien thi danh sach thuong hieu.
- Quan ly don hang (Order): Danh sach don hang phan chia theo tab trang thai (Dang xu ly, Da hoan thanh), cho phap cap nhat trang thai don hang.
- Quan ly khuyen mai (Promotion): Them, sua, xoa va hien thi ma khuyen mai de kich cau mua sam.
- Phan quyen tai khoan: Gan quyen Admin cho nguoi dung khac.
- Thong ke va bao cao: Theo doi doanh thu va danh sach san pham ban chay theo thoi gian.
- Xem phan hoi: Nhan va quan ly cac y kien, dong gop tu nguoi dung.

### Role User
- Tai khoan: Dang ky, dang nhap, quen mat khau, doi mat khau, hien thi thong tin profile va dang xuat.
- Trang chu va tim kiem: Tim kiem san pham theo tu khoa, slide banner san pham noi bat tu dong chuyen tiep.
- Danh sach san pham: Hien thi danh sach san pham theo phan loai tab realtime tu Firebase, loc san pham theo gia, xep hang va khuyen mai.
- Chi tiet san pham: Xem thong tin anh, ten, gia, mo ta va thong so ky thuat san pham.
- Danh gia san pham: Tinh nang gui xep hang va danh gia nhan xet san pham.
- Gio hang: Realtime dong bo hoa voi Firebase. Them/bot so luong hoac xoa san pham khoi gio hang.
- Thanh toan (Checkout):
  - Chon hoac them dia chi giao hang moi linh hoat.
  - Lua chon phuong thuc thanh toan: Thanh toan khi nhan hang (COD) hoac Chuyen khoan.
  - Tra cuu va ap dung tu dong ma giam gia hop le tu Firestore (ho tro autocomplete).
- Lich su don hang: Xem danh sach don hang va lich trinh trang thai giao nhan.
- Gui feedback: Gui kien nghi va danh gia ve chat luong ung dung.

## Huong dan chay ung dung

1. Cai dat cac dependency:
   ```bash
   flutter pub get
   ```
2. Chay ung dung tren trinh duyet Chrome hoac thiet bi Emulator:
   ```bash
   flutter run -d chrome
   ```
3. Cap nhat luat bao mat Firestore khi co thay doi (tren Firebase Console Rules hoac qua CLI):
   ```bash
   firebase deploy --only firestore:rules
   ```
