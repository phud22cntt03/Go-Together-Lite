const Configstore = require("C:/Users/admin/AppData/Local/npm-cache/_npx/ba4f1959e38407b5/node_modules/configstore");
const pkg = require("C:/Users/admin/AppData/Local/npm-cache/_npx/ba4f1959e38407b5/node_modules/firebase-tools/package.json");

const projectId = "smart-carpool-connect";
const databaseId = "(default)";

function firestoreValue(value) {
  if (value === null || value === undefined) {
    return { nullValue: null };
  }
  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(firestoreValue) } };
  }
  if (typeof value === "string") {
    if (value.endsWith("Z") && !Number.isNaN(Date.parse(value))) {
      return { timestampValue: value };
    }
    return { stringValue: value };
  }
  if (typeof value === "number") {
    if (Number.isInteger(value)) {
      return { integerValue: String(value) };
    }
    return { doubleValue: value };
  }
  if (typeof value === "boolean") {
    return { booleanValue: value };
  }
  if (typeof value === "object") {
    const fields = {};
    for (const [key, nested] of Object.entries(value)) {
      fields[key] = firestoreValue(nested);
    }
    return { mapValue: { fields } };
  }
  throw new Error(`Unsupported value type: ${typeof value}`);
}

function toDocumentFields(data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    fields[key] = firestoreValue(value);
  }
  return fields;
}

function docWrite(path, data) {
  return {
    update: {
      name: `projects/${projectId}/databases/${databaseId}/documents/${path}`,
      fields: toDocumentFields(data),
    },
  };
}

function minutesFromNow(base, mins) {
  return new Date(base.getTime() + mins * 60 * 1000);
}

async function main() {
  const cs = new Configstore(pkg.name);
  const tokens = cs.get("tokens");
  if (!tokens?.access_token) {
    throw new Error("Firebase CLI access token not found. Run `firebase login` first.");
  }

  const now = new Date();
  const t5 = minutesFromNow(now, 5);
  const t10 = minutesFromNow(now, 10);
  const t20 = minutesFromNow(now, 20);
  const t30ago = minutesFromNow(now, -30);
  const t15ago = minutesFromNow(now, -15);

  const users = [
    {
      id: "prod_user_driver_1",
      fullName: "Minh Tuan",
      email: "minhtuan@example.com",
      phone: "0901112233",
      avatarUrl: null,
      rating: 4.9,
      totalTrips: 128,
      totalKm: 3720,
      role: "both",
      isVerified: true,
      createdAt: t30ago,
    },
    {
      id: "prod_user_driver_2",
      fullName: "Hai Yen",
      email: "haiyen@example.com",
      phone: "0902223344",
      avatarUrl: null,
      rating: 4.8,
      totalTrips: 84,
      totalKm: 2140,
      role: "driver",
      isVerified: true,
      createdAt: t30ago,
    },
    {
      id: "prod_user_passenger_1",
      fullName: "Thu Huong",
      email: "thuhuong@example.com",
      phone: "0903334455",
      avatarUrl: null,
      rating: 4.7,
      totalTrips: 26,
      totalKm: 610,
      role: "passenger",
      isVerified: true,
      createdAt: t15ago,
    },
    {
      id: "prod_user_passenger_2",
      fullName: "Quoc Trung",
      email: "quoctrung@example.com",
      phone: "0904445566",
      avatarUrl: null,
      rating: 4.6,
      totalTrips: 19,
      totalKm: 430,
      role: "passenger",
      isVerified: false,
      createdAt: t15ago,
    },
    {
      id: "prod_user_passenger_3",
      fullName: "Lan Anh",
      email: "lananh@example.com",
      phone: "0905556677",
      avatarUrl: null,
      rating: 4.9,
      totalTrips: 41,
      totalKm: 980,
      role: "both",
      isVerified: true,
      createdAt: t15ago,
    },
  ];

  const vehicles = [
    {
      id: "prod_vehicle_1",
      ownerId: "prod_user_driver_1",
      name: "Toyota Vios",
      licensePlate: "51G-123.45",
      type: "car",
      color: "Trang",
      seats: 4,
      isDefault: true,
      createdAt: t30ago,
    },
    {
      id: "prod_vehicle_2",
      ownerId: "prod_user_driver_2",
      name: "Honda City",
      licensePlate: "30A-456.78",
      type: "car",
      color: "Den",
      seats: 4,
      isDefault: true,
      createdAt: t30ago,
    },
    {
      id: "prod_vehicle_3",
      ownerId: "prod_user_passenger_3",
      name: "Mazda 3",
      licensePlate: "59A-987.65",
      type: "car",
      color: "Do",
      seats: 4,
      isDefault: false,
      createdAt: t15ago,
    },
  ];

  const trips = [
    {
      id: "prod_trip_1",
      driverId: "prod_user_driver_1",
      driverName: "Minh Tuan",
      driverAvatar: "",
      driverRating: 4.9,
      vehicleName: "Toyota Vios",
      licensePlate: "51G-123.45",
      vehicleType: "car",
      pickupLocation: "Quan 7, TP. HCM",
      dropoffLocation: "Quan 1, TP. HCM",
      pickupTime: "08:30 - 19/05",
      dropoffTime: "09:15 - 19/05",
      pricePerSeat: 50000,
      totalSeats: 3,
      availableSeats: 2,
      driverNote: "Xe sach se, khong hut thuoc. Co the cho them toi da 1 vali nho.",
      status: "available",
      createdAt: now,
    },
    {
      id: "prod_trip_2",
      driverId: "prod_user_driver_2",
      driverName: "Hai Yen",
      driverAvatar: "",
      driverRating: 4.8,
      vehicleName: "Honda City",
      licensePlate: "30A-456.78",
      vehicleType: "car",
      pickupLocation: "Binh Thanh",
      dropoffLocation: "Quan 3",
      pickupTime: "07:45 - 19/05",
      dropoffTime: "08:20 - 19/05",
      pricePerSeat: 35000,
      totalSeats: 3,
      availableSeats: 2,
      driverNote: "Di dung gio, co nuoc suoI cho hanh khach.",
      status: "available",
      createdAt: t10,
    },
    {
      id: "prod_trip_3",
      driverId: "prod_user_driver_1",
      driverName: "Minh Tuan",
      driverAvatar: "",
      driverRating: 4.9,
      vehicleName: "Toyota Vios",
      licensePlate: "51G-123.45",
      vehicleType: "car",
      pickupLocation: "TP. Thu Duc",
      dropoffLocation: "San bay Tan Son Nhat",
      pickupTime: "18:10 - 19/05",
      dropoffTime: "19:00 - 19/05",
      pricePerSeat: 75000,
      totalSeats: 3,
      availableSeats: 0,
      driverNote: "Chuyen cong tac, co cop rong.",
      status: "full",
      createdAt: t15ago,
    },
    {
      id: "prod_trip_4",
      driverId: "prod_user_driver_2",
      driverName: "Hai Yen",
      driverAvatar: "",
      driverRating: 4.8,
      vehicleName: "Honda City",
      licensePlate: "30A-456.78",
      vehicleType: "car",
      pickupLocation: "Quan 5",
      dropoffLocation: "Quan 10",
      pickupTime: "06:45 - 18/05",
      dropoffTime: "07:10 - 18/05",
      pricePerSeat: 30000,
      totalSeats: 3,
      availableSeats: 3,
      driverNote: null,
      status: "completed",
      createdAt: t30ago,
    },
    {
      id: "prod_trip_5",
      driverId: "prod_user_driver_1",
      driverName: "Minh Tuan",
      driverAvatar: "",
      driverRating: 4.9,
      vehicleName: "Toyota Vios",
      licensePlate: "51G-123.45",
      vehicleType: "car",
      pickupLocation: "Quan 1",
      dropoffLocation: "Quan 7",
      pickupTime: "12:15 - 19/05",
      dropoffTime: "13:00 - 19/05",
      pricePerSeat: 45000,
      totalSeats: 3,
      availableSeats: 1,
      driverNote: "Co dieu hoa, di ngay trong gio nghi trua.",
      status: "available",
      createdAt: t5,
    },
    {
      id: "prod_trip_6",
      driverId: "prod_user_driver_2",
      driverName: "Hai Yen",
      driverAvatar: "",
      driverRating: 4.8,
      vehicleName: "Honda City",
      licensePlate: "30A-456.78",
      vehicleType: "car",
      pickupLocation: "Tan Binh",
      dropoffLocation: "Thu Duc",
      pickupTime: "17:30 - 19/05",
      dropoffTime: "18:20 - 19/05",
      pricePerSeat: 65000,
      totalSeats: 3,
      availableSeats: 1,
      driverNote: "Co the don tren duong.",
      status: "available",
      createdAt: t20,
    },
    {
      id: "prod_trip_7",
      driverId: "prod_user_driver_1",
      driverName: "Minh Tuan",
      driverAvatar: "",
      driverRating: 4.9,
      vehicleName: "Toyota Vios",
      licensePlate: "51G-123.45",
      vehicleType: "car",
      pickupLocation: "Quan 3",
      dropoffLocation: "San bay Tan Son Nhat",
      pickupTime: "05:50 - 18/05",
      dropoffTime: "06:20 - 18/05",
      pricePerSeat: 55000,
      totalSeats: 3,
      availableSeats: 3,
      driverNote: "Chuyen cu, da hoan thanh.",
      status: "completed",
      createdAt: t30ago,
    },
    {
      id: "prod_trip_8",
      driverId: "prod_user_driver_2",
      driverName: "Hai Yen",
      driverAvatar: "",
      driverRating: 4.8,
      vehicleName: "Honda City",
      licensePlate: "30A-456.78",
      vehicleType: "car",
      pickupLocation: "Binh Thanh",
      dropoffLocation: "Quan 1",
      pickupTime: "09:10 - 18/05",
      dropoffTime: "09:40 - 18/05",
      pricePerSeat: 32000,
      totalSeats: 3,
      availableSeats: 3,
      driverNote: "Chuyen da huy do thoi tiet.",
      status: "cancelled",
      createdAt: t30ago,
    },
  ];

  const bookings = [
    {
      id: "prod_booking_1",
      tripId: "prod_trip_1",
      passengerId: "prod_user_passenger_1",
      passengerName: "Thu Huong",
      passengerAvatar: null,
      seatsBooked: 1,
      totalPrice: 50000,
      status: "confirmed",
      driverRating: 5,
      cancelReason: null,
      cancelledAt: null,
      passengerRating: null,
      ratingComment: null,
      ratedAt: null,
      createdAt: now,
    },
    {
      id: "prod_booking_2",
      tripId: "prod_trip_2",
      passengerId: "prod_user_passenger_2",
      passengerName: "Quoc Trung",
      passengerAvatar: null,
      seatsBooked: 2,
      totalPrice: 70000,
      status: "confirmed",
      driverRating: 4.7,
      cancelReason: null,
      cancelledAt: null,
      passengerRating: null,
      ratingComment: null,
      ratedAt: null,
      createdAt: t10,
    },
    {
      id: "prod_booking_3",
      tripId: "prod_trip_4",
      passengerId: "prod_user_passenger_3",
      passengerName: "Lan Anh",
      passengerAvatar: null,
      seatsBooked: 1,
      totalPrice: 30000,
      status: "completed",
      driverRating: 4.9,
      cancelReason: null,
      cancelledAt: null,
      passengerRating: 4.8,
      ratingComment: "Tai xe dung gio, xe sach.",
      ratedAt: t20,
      createdAt: t30ago,
    },
    {
      id: "prod_booking_4",
      tripId: "prod_trip_7",
      passengerId: "prod_user_passenger_1",
      passengerName: "Thu Huong",
      passengerAvatar: null,
      seatsBooked: 1,
      totalPrice: 55000,
      status: "completed",
      driverRating: 5,
      cancelReason: null,
      cancelledAt: null,
      passengerRating: 4.9,
      ratingComment: "Tuan thu xep, xe rat sach.",
      ratedAt: t5,
      createdAt: t30ago,
    },
    {
      id: "prod_booking_5",
      tripId: "prod_trip_8",
      passengerId: "prod_user_passenger_2",
      passengerName: "Quoc Trung",
      passengerAvatar: null,
      seatsBooked: 1,
      totalPrice: 32000,
      status: "cancelled",
      driverRating: null,
      cancelReason: "Thoi tiet xau",
      cancelledAt: t5,
      passengerRating: null,
      ratingComment: null,
      ratedAt: null,
      createdAt: t30ago,
    },
  ];

  const posts = [
    {
      id: "prod_post_1",
      authorId: "prod_user_passenger_2",
      authorName: "Quoc Trung",
      authorAvatar: null,
      content: "Chuyen di sang nay rat on, duong thoang va xe sach.",
      topic: "share",
      likes: 24,
      comments: 2,
      likedBy: ["prod_user_passenger_1", "prod_user_driver_2"],
      createdAt: now,
    },
    {
      id: "prod_post_2",
      authorId: "prod_user_driver_1",
      authorName: "Minh Tuan",
      authorAvatar: null,
      content: "Moi nguoi co tuyen nao tu Quan 7 di trung tam vao 7h30 sang khong?",
      topic: "help",
      likes: 8,
      comments: 1,
      likedBy: ["prod_user_passenger_1"],
      createdAt: t10,
    },
    {
      id: "prod_post_3",
      authorId: "prod_user_passenger_3",
      authorName: "Lan Anh",
      authorAvatar: null,
      content: "Meo nho: dat xe som 15 phut de tranh tre gio vao cao diem.",
      topic: "tips",
      likes: 31,
      comments: 4,
      likedBy: ["prod_user_driver_1", "prod_user_passenger_1", "prod_user_passenger_2"],
      createdAt: t15ago,
    },
    {
      id: "prod_post_4",
      authorId: "prod_user_driver_2",
      authorName: "Hai Yen",
      authorAvatar: null,
      content: "Co chuyen trong tu Quan 5 sang san bay luc 18:30. Ai can nhan nhe.",
      topic: "all",
      likes: 12,
      comments: 0,
      likedBy: ["prod_user_passenger_3"],
      createdAt: t30ago,
    },
    {
      id: "prod_post_5",
      authorId: "prod_user_passenger_1",
      authorName: "Thu Huong",
      authorAvatar: null,
      content: "Ai co kinh nghiem ghep chuyen khu Thu Duc vao gio cao diem chia se voi.",
      topic: "help",
      likes: 6,
      comments: 0,
      likedBy: ["prod_user_passenger_2"],
      createdAt: t5,
    },
    {
      id: "prod_post_6",
      authorId: "prod_user_driver_1",
      authorName: "Minh Tuan",
      authorAvatar: null,
      content: "Chia se tuyen co the nhan them 1 ban di trung tam sau 12h trua.",
      topic: "share",
      likes: 15,
      comments: 1,
      likedBy: ["prod_user_passenger_1", "prod_user_passenger_3"],
      createdAt: t20,
    },
  ];

  const comments = [
    {
      path: "community_posts/prod_post_1/comments/prod_comment_1",
      data: {
        id: "prod_comment_1",
        authorId: "prod_user_passenger_1",
        authorName: "Thu Huong",
        content: "Cam on ban da chia se!",
        createdAt: t5,
      },
    },
    {
      path: "community_posts/prod_post_1/comments/prod_comment_2",
      data: {
        id: "prod_comment_2",
        authorId: "prod_user_driver_2",
        authorName: "Hai Yen",
        content: "Tuyen nay minh cung hay di, kha on.",
        createdAt: t10,
      },
    },
    {
      path: "community_posts/prod_post_2/comments/prod_comment_1",
      data: {
        id: "prod_comment_3",
        authorId: "prod_user_passenger_3",
        authorName: "Lan Anh",
        content: "Minh co the ghep chuyen, neu ban di Thao Dien thi tien.",
        createdAt: t20,
      },
    },
    {
      path: "community_posts/prod_post_5/comments/prod_comment_1",
      data: {
        id: "prod_comment_4",
        authorId: "prod_user_driver_2",
        authorName: "Hai Yen",
        content: "Thu Duc gio nay kha dong, ban nen dat som.",
        createdAt: t20,
      },
    },
  ];

  const notifications = [
    {
      id: "prod_notif_1",
      userId: "prod_user_passenger_1",
      type: "booking_new",
      title: "Dat cho thanh cong",
      body: "Ban da dat 1 ghe cho chuyen Quan 7 -> Quan 1.",
      relatedId: "prod_trip_1",
      isRead: false,
      createdAt: now,
    },
    {
      id: "prod_notif_2",
      userId: "prod_user_driver_1",
      type: "booking_new",
      title: "Co booking moi",
      body: "Thu Huong vua dat 1 ghe cho chuyen cua ban.",
      relatedId: "prod_booking_1",
      isRead: false,
      createdAt: t10,
    },
    {
      id: "prod_notif_3",
      userId: "prod_user_passenger_2",
      type: "trip_cancel",
      title: "Chuyen sap khoi hanh",
      body: "Chuyen cua ban se bat dau trong 15 phut nua.",
      relatedId: "prod_trip_2",
      isRead: true,
      createdAt: t20,
    },
    {
      id: "prod_notif_4",
      userId: "prod_user_passenger_3",
      type: "rating",
      title: "Danh gia chuyen di",
      body: "Hay danh gia chuyen di vua hoan thanh de giup cong dong tot hon.",
      relatedId: "prod_booking_3",
      isRead: false,
      createdAt: t20,
    },
    {
      id: "prod_notif_5",
      userId: "prod_user_passenger_1",
      type: "booking_cancel",
      title: "Booking da huy",
      body: "Booking cua ban da duoc huy va hoan tien theo chinh sach.",
      relatedId: "prod_booking_5",
      isRead: true,
      createdAt: t5,
    },
    {
      id: "prod_notif_6",
      userId: "prod_user_driver_2",
      type: "community",
      title: "Co binh luan moi",
      body: "Bai dang cua ban vua co them mot binh luan moi.",
      relatedId: "prod_post_6",
      isRead: false,
      createdAt: t20,
    },
  ];

  const reports = [
    {
      id: "prod_report_1",
      postId: "prod_post_4",
      reporterId: "prod_user_passenger_1",
      reason: "Noi dung lap lai nhieu lan",
      status: "pending",
      createdAt: now,
    },
    {
      id: "prod_report_2",
      postId: "prod_post_2",
      reporterId: "prod_user_driver_2",
      reason: "Bai dang khong lien quan chu de",
      status: "reviewed",
      createdAt: t10,
    },
    {
      id: "prod_report_3",
      postId: "prod_post_5",
      reporterId: "prod_user_passenger_2",
      reason: "Noi dung khong ro rang",
      status: "resolved",
      createdAt: t5,
    },
  ];

  const writes = [
    ...users.map((item) => docWrite(`users/${item.id}`, item)),
    ...vehicles.map((item) => docWrite(`vehicles/${item.id}`, item)),
    ...trips.map((item) => docWrite(`trips/${item.id}`, item)),
    ...bookings.map((item) => docWrite(`bookings/${item.id}`, item)),
    ...posts.map((item) => docWrite(`community_posts/${item.id}`, item)),
    ...comments.map((item) => docWrite(item.path, item.data)),
    ...notifications.map((item) => docWrite(`notifications/${item.id}`, item)),
    ...reports.map((item) => docWrite(`reports/${item.id}`, item)),
  ];

  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/${databaseId}/documents:commit`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${tokens.access_token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ writes }),
    },
  );

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Firestore commit failed (${response.status}): ${text}`);
  }

  console.log(`Seeded ${writes.length} Firestore documents.`);
  console.log(JSON.stringify(JSON.parse(text), null, 2));
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
