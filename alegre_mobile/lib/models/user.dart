enum LoginType { dummyJson, firebase }

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int? age;
  final String contactNo;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  final LoginType loginType;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.age,
    this.contactNo = '',
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.loginType = LoginType.dummyJson,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      age: json['age'] as int?,
      contactNo: json['contactNo'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      image: json['image'] as String? ?? '',
      accessToken: (json['accessToken'] ?? json['token']) as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      loginType: json['loginType'] == 'firebase'
          ? LoginType.firebase
          : LoginType.dummyJson,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
    'contactNo': contactNo,
    'gender': gender,
    'image': image,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'loginType': loginType.name,
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    int? age,
    String? contactNo,
    String? gender,
    String? image,
    String? accessToken,
    String? refreshToken,
    LoginType? loginType,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      contactNo: contactNo ?? this.contactNo,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      loginType: loginType ?? this.loginType,
    );
  }
}
