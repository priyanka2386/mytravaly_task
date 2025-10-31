import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/device_info.dart';
import '../models/hotel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://api.mytravaly.com/public/v1/";


  /// method to get Visitor token
  Future<String> _getVisitorToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('visitorToken');

    if (token != null && token.isNotEmpty) {
      print("✅ Using stored visitorToken: $token");
      return token;
    } else {
      print("🆕 Registering new device...");
      token = await registerDevice();
      await prefs.setString('visitorToken', token);
      return token;
    }
  }

  ///API to get Visitor token
  Future<String> registerDevice() async {
    final url = Uri.parse(baseUrl);
    final deviceData = await DeviceInfoHelper.getDeviceInfo();
    var body = {
      "action": "deviceRegister",
      "deviceRegister": deviceData,
    };

    print("🔹 Sending request to: $url");
    print("📦 Body: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "authtoken": "71523fdd8d26f585315b4233e39d9263",
      },
      body: jsonEncode(body),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📜 Response body: ${response.body}");

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected response format");
    }
    final Map<String, dynamic> dataMap = decoded;

    // Check success (your API returns boolean true)
    if (response.statusCode == 201 && dataMap["status"] == true) {
      final String? visitorToken = (dataMap["data"]?["visitorToken"]) as String?;

      if (visitorToken != null && visitorToken.isNotEmpty) {
        // store token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('visitorToken', visitorToken);

        print("✅ Visitor token obtained and saved: $visitorToken");
        return visitorToken;
      } else {
        throw Exception("Visitor token not found in response data");
      }
    } else {
      final message = dataMap["message"] ?? "Unknown error";
      throw Exception("Device register failed: ${response.statusCode} - $message");
    }
  }


  ///API to fetch hotel list
  Future<List<HotelModel>> getSearchResult({
      page,
      selectedSearchType, List<String>? searchQuery
  }) async {
    DateTime checkIn = DateTime.now();
    DateTime checkOut = DateTime.now().add(const Duration(days: 3));
    final url = Uri.parse("${baseUrl}");

    final headers = {
      "authtoken": "71523fdd8d26f585315b4233e39d9263",
      "visitortoken": await _getVisitorToken(),
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "action": "getSearchResultListOfHotels",
      "getSearchResultListOfHotels": {
        "searchCriteria": {
          "checkIn": checkIn.toIso8601String().split('T').first, // Current Date
          "checkOut": checkOut.toIso8601String().split('T').first, // Date after 3 days
          "rooms": 1,
          "adults": 2,
          "children": 0,
          "searchType": selectedSearchType,
          "searchQuery": searchQuery,
          "accommodation": [
            "all","hotel"],
          "arrayOfExcludedSearchType": [],
          "highPrice": "3000000",
          "lowPrice": "0",
          "limit": 5,
          "preloaderList": [],
          "currency": "INR",
          "rid": 0
        }
      }
    });

    final response = await http.post(url, headers: headers, body: body);
    print("📥 Response Status Code: ${response.statusCode}");
    print("📜 Full Response Body:\n${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> list = jsonResponse["data"]["arrayOfHotelList"];
      return list.map((e) => HotelModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch data");
    }
  }
}
