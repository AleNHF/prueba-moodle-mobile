class User {
  final int id;
  final String username;
  final String firstname;
  final String lastname;
  final String fullname;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      fullname: json['fullname'],
      email: json['email'],
    );
  }
}
