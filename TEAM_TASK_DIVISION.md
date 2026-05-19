# 📋 SMART CARPOOL CONNECT — PHÂN CHIA CÔNG VIỆC TEAM

> **Dự án:** Smart Carpool Connect (Flutter + Firebase)  
> **Team size:** 3 người  
> **Ngày tạo:** 18/05/2026  
> **Trạng thái:** 🔄 Đang phát triển

---

## 📐 Kiến Trúc Tổng Quan

```
lib/
├── main.dart                     ← [SHARED] Entry point (chỉ Lead sửa)
├── firebase_options.dart         ← [SHARED] Config Firebase (không sửa)
│
├── models/
│   ├── user.dart                 ← Lead
│   ├── booking.dart              ← Lead
│   ├── trip.dart                 ← Dev A (CHỈ class Trip)
│   ├── vehicle.dart              ← Dev A
│   ├── community_post.dart       ← Dev B (TÁCH từ trip.dart)
│   └── notification.dart         ← Dev B (MỚI)
│
├── services/
│   ├── auth_service.dart         ← Lead
│   ├── booking_service.dart      ← Lead
│   ├── vehicle_service.dart      ← Lead (MỚI)
│   ├── trip_service.dart         ← Dev A
│   ├── community_service.dart    ← Dev B
│   ├── notification_service.dart ← Dev B (MỚI)
│   └── firestore_seeder.dart     ← Lead
│
├── providers/
│   ├── auth_provider.dart        ← Lead
│   ├── booking_provider.dart     ← Lead (MỚI - tách từ trip_provider)
│   ├── trip_provider.dart        ← Dev A (chỉ giữ phần trip)
│   ├── community_provider.dart   ← Dev B (MỚI)
│   └── notification_provider.dart← Dev B (MỚI)
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart     ← Lead
│   │   └── register_screen.dart  ← Lead
│   ├── welcome_screen.dart       ← Lead
│   ├── main_screen.dart          ← Lead
│   ├── home_screen.dart          ← Lead
│   ├── profile_screen.dart       ← Lead
│   ├── my_trips_screen.dart      ← Lead (tab Đã đặt / Booking history)
│   ├── rating_screen.dart        ← Lead (MỚI)
│   ├── vehicle_screen.dart       ← Lead (MỚI)
│   ├── search_screen.dart        ← Dev A
│   ├── trip_detail_screen.dart   ← Dev A
│   ├── create_trip_screen.dart   ← Dev A
│   ├── driver_trips_screen.dart  ← Dev A (MỚI - tách tab Đã tạo)
│   ├── community_screen.dart     ← Dev B
│   └── notifications_screen.dart ← Dev B
│
├── widgets/
│   ├── booking_bottom_sheet.dart ← Lead
│   ├── history_card.dart         ← Lead
│   ├── trip_card.dart            ← Dev A
│   ├── filter_bottom_sheet.dart  ← Dev A
│   ├── post_card.dart            ← Dev B (MỚI)
│   └── comment_section.dart      ← Dev B (MỚI)
│
└── theme/
    └── app_theme.dart            ← [SHARED] Chỉ Lead sửa
```

---

## 🎯 DANH SÁCH CHỨC NĂNG HỆ THỐNG (34 chức năng)

### Module 1: Authentication & User Management

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 1.1 | Đăng ký tài khoản | Firebase Auth + Firestore profile | **Lead** |
| 1.2 | Đăng nhập | Email/Password | **Lead** |
| 1.3 | Đăng xuất | Sign out | **Lead** |
| 1.4 | Quên mật khẩu | Email reset password | **Lead** |
| 1.5 | Xem & sửa hồ sơ | Update fullName, phone, avatar | **Lead** |
| 1.6 | Auth state stream | Real-time auth listener | **Lead** |
| 1.7 | Upload avatar | Firebase Storage | **Lead** |

### Module 2: Trip Management

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 2.1 | Tạo chuyến đi mới | Driver tạo trip | **Dev A** |
| 2.2 | Xem danh sách chuyến | Stream real-time available | **Dev A** |
| 2.3 | Xem chi tiết chuyến | Info đầy đủ driver, xe, giá | **Dev A** |
| 2.4 | Tìm kiếm chuyến đi | Search điểm đón/trả | **Dev A** |
| 2.5 | Lọc & sắp xếp | Filter loại xe, ghế, sort giá/rating | **Dev A** |
| 2.6 | Hủy chuyến (tài xế) | Cancel trip đã tạo | **Dev A** |
| 2.7 | Chuyến đi đã tạo | Danh sách trips của driver | **Dev A** |

### Module 3: Booking Management ⭐ (Core phức tạp)

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 3.1 | Đặt chỗ (Transaction) | Tạo booking + giảm seats (atomic) | **Lead** |
| 3.2 | Hủy đặt chỗ (Transaction) | Cancel + khôi phục seats (atomic) | **Lead** |
| 3.3 | Xem lịch sử booking | Stream real-time bookings | **Lead** |
| 3.4 | Đánh giá sau chuyến | Rate + comment UI + backend | **Lead** |
| 3.5 | Xem bookings của chuyến | Driver xem danh sách passenger | **Lead** |

### Module 4: Community

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 4.1 | Bảng tin cộng đồng | Stream real-time posts | **Dev B** |
| 4.2 | Tạo bài đăng | Text + topic | **Dev B** |
| 4.3 | Like / Unlike | Toggle arrayUnion/Remove | **Dev B** |
| 4.4 | Bình luận | Subcollection + batch count | **Dev B** |
| 4.5 | Xóa bình luận | Batch delete + giảm count | **Dev B** |
| 4.6 | Xóa bài đăng | Owner delete | **Dev B** |
| 4.7 | Báo cáo bài vi phạm | → reports collection | **Dev B** |
| 4.8 | Lọc theo chủ đề | Filter topic | **Dev B** |

### Module 5: Notifications

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 5.1 | Hiển thị thông báo | Real-time notification list | **Dev B** |
| 5.2 | Thông báo tự động | Auto-create khi booking/cancel | **Dev B** |
| 5.3 | Đánh dấu đã đọc | Mark as read | **Dev B** |
| 5.4 | Push notification (FCM) | Push khi có booking mới | **Dev B** |

### Module 6: Vehicle Management

| # | Chức năng | Mô tả | Người làm |
|---|-----------|-------|-----------|
| 6.1 | Thêm phương tiện | CRUD xe mới | **Lead** |
| 6.2 | Sửa/xóa phương tiện | Update/delete vehicle | **Lead** |
| 6.3 | Chọn xe mặc định | Set isDefault | **Lead** |

---

## 👥 TỔNG KẾT PHÂN CÔNG

### 🟢 LEAD (Bạn - Người làm chính) → 15 chức năng ⭐ NHIỀU NHẤT

| Module | Số lượng | Độ khó |
|--------|---------|--------|
| Auth & User (1.1→1.7) | 7 | ⭐⭐ |
| Booking (3.1→3.5) | 5 | ⭐⭐⭐ (Firestore Transaction!) |
| Vehicle (6.1→6.3) | 3 | ⭐⭐ |

**Điểm mạnh khi chấm điểm:**
- ✅ Xử lý **Firestore Transaction** (đặt chỗ/hủy chỗ) — kỹ thuật phức tạp nhất
- ✅ **Firebase Auth** đầy đủ (register, login, reset, stream)
- ✅ **Firebase Storage** (upload avatar)
- ✅ **CRUD hoàn chỉnh** (Vehicle management)
- ✅ **Rating system** (đánh giá sau chuyến)
- ✅ Quản lý **state management** cho auth + booking

**Files của Lead:**
```
lib/models/user.dart, booking.dart
lib/services/auth_service.dart, booking_service.dart, vehicle_service.dart, firestore_seeder.dart
lib/providers/auth_provider.dart, booking_provider.dart (MỚI)
lib/screens/auth/*, welcome, main, home, profile, my_trips, rating_screen (MỚI), vehicle_screen (MỚI)
lib/widgets/booking_bottom_sheet.dart, history_card.dart
firestore.rules, firestore.indexes.json, pubspec.yaml
```

---

### 🔵 DEV A → 7 chức năng

| Module | Số lượng | Độ khó |
|--------|---------|--------|
| Trip Management (2.1→2.7) | 7 | ⭐⭐ |

**Files của Dev A:**
```
lib/models/trip.dart (chỉ class Trip), vehicle.dart
lib/services/trip_service.dart
lib/providers/trip_provider.dart (chỉ phần trip, booking methods đã tách ra)
lib/screens/search_screen.dart, trip_detail_screen.dart, create_trip_screen.dart, driver_trips_screen.dart (MỚI)
lib/widgets/trip_card.dart, filter_bottom_sheet.dart
```

---

### 🟡 DEV B → 12 chức năng

| Module | Số lượng | Độ khó |
|--------|---------|--------|
| Community (4.1→4.8) | 8 | ⭐⭐ |
| Notification (5.1→5.4) | 4 | ⭐⭐ |

**Files của Dev B:**
```
lib/models/community_post.dart (MỚI), notification.dart (MỚI)
lib/services/community_service.dart, notification_service.dart (MỚI)
lib/providers/community_provider.dart (MỚI), notification_provider.dart (MỚI)
lib/screens/community_screen.dart, notifications_screen.dart
lib/widgets/post_card.dart (MỚI), comment_section.dart (MỚI)
```

---

## ⚠️ QUY TẮC TRÁNH XUNG ĐỘT MERGE

### 1. Git Branch Strategy

```
main (production)
 └── develop (integration)
      ├── feature/auth-*          ← Lead
      ├── feature/booking-*       ← Lead
      ├── feature/vehicle-*       ← Lead
      ├── feature/trip-*          ← Dev A
      ├── feature/community-*     ← Dev B
      └── feature/notification-*  ← Dev B
```

### 2. Quy tắc vàng 🏆

| # | Quy tắc |
|---|---------|
| 1 | **KHÔNG sửa file người khác** — mỗi người chỉ sửa file trong phạm vi được giao |
| 2 | **File SHARED chỉ Lead sửa** — `main.dart`, `app_theme.dart`, `pubspec.yaml` |
| 3 | **Model mới = file mới** — KHÔNG thêm class vào file có sẵn |
| 4 | **Provider mới = file mới** — KHÔNG sửa provider người khác |
| 5 | **Thêm dependency → báo Lead** — KHÔNG tự sửa `pubspec.yaml` |

### 3. ⚡ Việc đầu tiên PHẢI LÀM TRƯỚC

> **Bước 1:** Tách `CommunityPost` class ra khỏi `trip.dart` → file mới `community_post.dart` (Dev B tạo)  
> **Bước 2:** Tách booking methods ra khỏi `trip_provider.dart` → file mới `booking_provider.dart` (Lead tạo)  
> **Bước 3:** Tách tab "Đã tạo" ra khỏi `my_trips_screen.dart` → file mới `driver_trips_screen.dart` (Dev A tạo)  
> → **Merge 3 việc này TRƯỚC rồi mới bắt đầu code feature mới**

### 4. Giao tiếp giữa modules

| Tình huống | Cách xử lý |
|-----------|-----------|
| Booking cần update trip seats | `booking_service.dart` dùng Firestore Transaction trực tiếp (không cần import trip_service) |
| Notification cần biết booking event | Dev B tạo `NotificationService.onBookingCreated()` → Lead gọi hàm đó |
| Community cần info User | Import `models/user.dart` (read-only) |
| Main screen thêm provider mới | Báo Lead thêm vào `main.dart` |

### 5. Commit message format

```
[Auth] Thêm upload avatar Firebase Storage
[Booking] Fix transaction race condition
[Trip] Thêm sort theo rating
[Community] Tách CommunityPost thành file riêng
[Notification] Tạo notification_service.dart
```

### 6. Quy trình merge

```
1. Push code lên branch feature/*
2. Tạo Pull Request vào develop
3. Lead review & merge theo thứ tự:
   ① Models (tách file trước)
   ② Services
   ③ Providers
   ④ Screens & Widgets
4. Test develop → merge main
```

---

## 📊 BẢNG THEO DÕI TIẾN ĐỘ

### 🟢 Lead — Auth + Booking + Vehicle (15 chức năng)

| # | Chức năng | Trạng thái | Ghi chú |
|---|-----------|-----------|---------|
| 1.1 | Đăng ký | ✅ Done | Firebase Auth + Firestore |
| 1.2 | Đăng nhập | ✅ Done | |
| 1.3 | Đăng xuất | ✅ Done | |
| 1.4 | Quên mật khẩu | ✅ Done | |
| 1.5 | Xem/sửa hồ sơ | ✅ Done | |
| 1.6 | Auth state stream | ✅ Done | |
| 1.7 | Upload avatar | ⬜ Todo | Firebase Storage |
| 3.1 | Đặt chỗ (Transaction) | ✅ Done | Firestore Transaction |
| 3.2 | Hủy đặt chỗ (Transaction) | ✅ Done | Transaction + restore |
| 3.3 | Lịch sử booking | ✅ Done | Real-time stream |
| 3.4 | Đánh giá chuyến | 🔧 Backend | **Cần thêm rating_screen.dart** |
| 3.5 | Xem bookings chuyến | 🔧 Backend | **Cần thêm UI driver view** |
| 6.1 | Thêm phương tiện | ⬜ Todo | vehicle_service.dart |
| 6.2 | Sửa/xóa phương tiện | ⬜ Todo | |
| 6.3 | Xe mặc định | ⬜ Todo | |

### 🔵 Dev A — Trip Management (7 chức năng)

| # | Chức năng | Trạng thái | Ghi chú |
|---|-----------|-----------|---------|
| 2.1 | Tạo chuyến đi | ✅ Done | |
| 2.2 | Danh sách chuyến | ✅ Done | Real-time |
| 2.3 | Chi tiết chuyến | ✅ Done | |
| 2.4 | Tìm kiếm | ✅ Done | |
| 2.5 | Lọc & sắp xếp | ✅ Done | |
| 2.6 | Hủy chuyến | ✅ Done | |
| 2.7 | Chuyến đã tạo | ✅ Done | |

### 🟡 Dev B — Community + Notification (12 chức năng)

| # | Chức năng | Trạng thái | Ghi chú |
|---|-----------|-----------|---------|
| 4.1 | Bảng tin | ✅ Done | |
| 4.2 | Tạo bài đăng | ✅ Done | |
| 4.3 | Like/Unlike | ✅ Done | |
| 4.4 | Bình luận | ✅ Done | |
| 4.5 | Xóa bình luận | ✅ Done | |
| 4.6 | Xóa bài đăng | ✅ Done | |
| 4.7 | Báo cáo bài | ✅ Done | |
| 4.8 | Lọc chủ đề | ✅ Done | |
| 5.1 | Hiển thị thông báo | 🔧 UI có | Cần Firestore |
| 5.2 | Thông báo tự động | ⬜ Todo | notification_service |
| 5.3 | Đánh dấu đã đọc | ⬜ Todo | |
| 5.4 | Push notification | ⬜ Todo | FCM |
