class ChatMessagesResponse {
  int? id;
  String? senderEmail;
  String? receiverEmail;
  String? message;
  String? createdAt;

  ChatMessagesResponse(
      {this.id,
      this.senderEmail,
      this.receiverEmail,
      this.message,
      this.createdAt});

  ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderEmail = json['senderEmail'];
    receiverEmail = json['receiverEmail'];
    message = json['message'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['senderEmail'] = this.senderEmail;
    data['receiverEmail'] = this.receiverEmail;
    data['message'] = this.message;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
