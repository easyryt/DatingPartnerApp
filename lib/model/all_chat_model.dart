class AllChatModel {
  bool? status;
  List<Data>? data;

  AllChatModel({this.status, this.data});

  AllChatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  User? user;
  LastMessage? lastMessage;
  int? unreadCount;

  Data({this.sId, this.user, this.lastMessage, this.unreadCount});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    lastMessage = json['lastMessage'] != null
        ? LastMessage.fromJson(json['lastMessage'])
        : null;
    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    data['unreadCount'] = unreadCount;
    return data;
  }
}

class User {
  String? sId;
  String? avatarName;

  User({this.sId, this.avatarName});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    avatarName = json['avatarName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['avatarName'] = avatarName;
    return data;
  }
}

class LastMessage {
  String? sId;
  String? conversationId;
  String? senderId;
  String? receiverId;
  String? content;
  String? status;
  String? senderType;
  String? createdAt;
  String? updatedAt;
  int? iV;

  LastMessage(
      {this.sId,
      this.conversationId,
      this.senderId,
      this.receiverId,
      this.content,
      this.status,
      this.senderType,
      this.createdAt,
      this.updatedAt,
      this.iV});

  LastMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    conversationId = json['conversationId'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    content = json['content'];
    status = json['status'];
    senderType = json['senderType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['conversationId'] = conversationId;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['content'] = content;
    data['status'] = status;
    data['senderType'] = senderType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
