import '../models/community_post.dart';
import '../models/trip.dart';

class MockData {
  static List<Trip> get recentTrips => [
    Trip(
      id: '1',
      driverName: 'Minh Tuấn',
      driverRating: 4.9,
      vehicleName: 'Toyota Vios',
      licensePlate: '51G-123.45',
      pickupLocation: 'Quận 7, TP. HCM',
      dropoffLocation: 'Quận 1, TP. HCM',
      pickupTime: '08:30',
      dropoffTime: '09:15',
      pricePerSeat: 50000,
      availableSeats: 3,
      driverNote:
          'Xe sạch sẽ, không hút thuốc. Có thể chở thêm tối đa 1 vali nhỏ. Vui lòng có mặt đúng giờ nhé!',
    ),
    Trip(
      id: '2',
      driverName: 'Hải Yến',
      driverRating: 4.8,
      vehicleName: 'Honda City',
      licensePlate: '30A-456.78',
      pickupLocation: 'Bình Thạnh',
      dropoffLocation: 'Quận 3',
      pickupTime: '07:45',
      dropoffTime: '08:20',
      pricePerSeat: 35000,
      availableSeats: 2,
    ),
  ];

  static List<Trip> get searchResults => [
    Trip(
      id: '3',
      driverName: 'Hoàng Nam',
      driverRating: 4.7,
      vehicleName: 'VinFast VF8',
      licensePlate: '29A-123.45',
      pickupLocation: 'Bến xe Mỹ Đình, Hà Nội',
      dropoffLocation: 'Vincom Plaza, Hải Phòng',
      pickupTime: '08:30',
      dropoffTime: '10:45',
      pricePerSeat: 150000,
      availableSeats: 4,
    ),
    Trip(
      id: '4',
      driverName: 'Minh Anh',
      driverRating: 4.6,
      vehicleName: 'Mazda 3',
      licensePlate: '15A-888.66',
      pickupLocation: 'Big C Thăng Long, Hà Nội',
      dropoffLocation: 'Đồ Sơn, Hải Phòng',
      pickupTime: '14:00',
      dropoffTime: '16:30',
      pricePerSeat: 120000,
      availableSeats: 3,
    ),
    Trip(
      id: '5',
      driverName: 'Quốc Bảo',
      driverRating: 4.9,
      vehicleName: 'Toyota Camry',
      licensePlate: '30F-555.55',
      pickupLocation: 'Nhà hát Lớn, Hà Nội',
      dropoffLocation: 'Trung tâm TP Hải Phòng',
      pickupTime: '17:15',
      dropoffTime: '19:30',
      pricePerSeat: 180000,
      availableSeats: 2,
    ),
  ];

  static List<Trip> get tripHistory => [
    Trip(
      id: '6',
      driverName: 'Trần Thị Bích',
      driverRating: 4.8,
      vehicleName: 'Toyota Camry',
      licensePlate: '29A-123.45',
      pickupLocation: 'Hà Nội',
      dropoffLocation: 'Vinhomes Ocean Park',
      pickupTime: '08:30 AM',
      pricePerSeat: 120000,
      status: 'completed',
    ),
    Trip(
      id: '7',
      driverName: 'Lê Hoàng Nam',
      driverRating: 4.5,
      vehicleName: 'Honda CR-V',
      licensePlate: '30G-999.88',
      pickupLocation: 'Cầu Giấy',
      dropoffLocation: 'Sân bay Nội Bài',
      pickupTime: '04:15 PM',
      pricePerSeat: 85000,
      status: 'cancelled',
    ),
    Trip(
      id: '8',
      driverName: 'Ngô Anh Quân',
      driverRating: 4.7,
      vehicleName: 'Mazda 3',
      licensePlate: '29D-567.89',
      pickupLocation: 'Hà Đông',
      dropoffLocation: 'Hải Phòng City',
      pickupTime: '07:00 AM',
      pricePerSeat: 250000,
      status: 'completed',
    ),
  ];

  static List<CommunityPost> get communityPosts => [
    CommunityPost(
      id: '1',
      authorName: 'Quốc Trung',
      content:
          'Chuyến đi sáng nay thật tuyệt vời! Thời tiết mát mẻ, đường vắng. Có ai muốn đi ké cung đường này vào mỗi sáng thứ Hai không?',
      timeAgo: '2 giờ trước',
      likes: 24,
      comments: 8,
    ),
    CommunityPost(
      id: '2',
      authorName: 'Hoàng Nam',
      content:
          'Cuối tuần này mình có chuyến đi làm sớm từ Quận 7 sang Quận 1. Xe rộng rãi, âm nhạc chill. Ưu tiên các bạn văn phòng đi cùng nhé!',
      timeAgo: '5 giờ trước',
      likes: 15,
      comments: 3,
    ),
    CommunityPost(
      id: '3',
      authorName: 'Thu Hương',
      content:
          'Cảm ơn bác tài Minh Tuấn vì chuyến đi an toàn sáng nay. Xe sạch sẽ, thơm tho, lái xe cẩn thận. Sẽ book lại lần sau!',
      timeAgo: '1 ngày trước',
      likes: 42,
      comments: 12,
    ),
  ];
}
