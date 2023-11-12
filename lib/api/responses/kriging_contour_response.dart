import 'dart:convert';

class KrigingContourResponse {
  String? image_base64;

  KrigingContourResponse({this.image_base64});

  KrigingContourResponse.fromJson(String jsonResponse) {
    final json = Map<String, dynamic>.from(jsonDecode(jsonResponse));
    image_base64 = json['image_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image_base64'] = this.image_base64;
    return data;
  }
}
