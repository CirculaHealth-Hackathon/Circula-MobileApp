class PostsResponse {
  int? id;
  String? text;
  String? email;
  User? user;
  String? createdAt;
  String? updatedAt;

  PostsResponse(
      {this.id,
      this.text,
      this.email,
      this.user,
      this.createdAt,
      this.updatedAt});

  PostsResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    email = json['email'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['email'] = this.email;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class User {
  int? id;
  int? age;
  String? bloodType;
  String? email;
  String? password;
  String? fullName;
  bool? gpsAllowed;
  bool? hasChosenDonateBlood;
  bool? hasRegistered;
  String? homeLocation;
  String? legalDocumentUrl;
  String? photoUrl;
  String? provider;
  String? username;
  String? whatsAppNumber;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.age,
      this.bloodType,
      this.email,
      this.password,
      this.fullName,
      this.gpsAllowed,
      this.hasChosenDonateBlood,
      this.hasRegistered,
      this.homeLocation,
      this.legalDocumentUrl,
      this.photoUrl,
      this.provider,
      this.username,
      this.whatsAppNumber,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    age = json['age'];
    bloodType = json['bloodType'];
    email = json['email'];
    password = json['password'];
    fullName = json['fullName'];
    gpsAllowed = json['gpsAllowed'];
    hasChosenDonateBlood = json['hasChosenDonateBlood'];
    hasRegistered = json['hasRegistered'];
    homeLocation = json['homeLocation'];
    legalDocumentUrl = json['legalDocumentUrl'];
    photoUrl = json['photoUrl'];
    provider = json['provider'];
    username = json['username'];
    whatsAppNumber = json['whatsAppNumber'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['age'] = this.age;
    data['bloodType'] = this.bloodType;
    data['email'] = this.email;
    data['password'] = this.password;
    data['fullName'] = this.fullName;
    data['gpsAllowed'] = this.gpsAllowed;
    data['hasChosenDonateBlood'] = this.hasChosenDonateBlood;
    data['hasRegistered'] = this.hasRegistered;
    data['homeLocation'] = this.homeLocation;
    data['legalDocumentUrl'] = this.legalDocumentUrl;
    data['photoUrl'] = this.photoUrl;
    data['provider'] = this.provider;
    data['username'] = this.username;
    data['whatsAppNumber'] = this.whatsAppNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
