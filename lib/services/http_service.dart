import 'dart:io';

import 'package:MunshiG/services/user_service.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';

class HttpService {
  Future<void> backupData(File file) async {
    AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
    String deviceId = deviceInfo.androidId;
    final userData = await UserService().getAccounts();
    MultipartFile multipartFile = await MultipartFile.fromFile(file.path);
    FormData formData = FormData.fromMap({
      'name': userData.name,
      'gender': userData.gender,
      'mobileNumber': userData.phonenumber,
      'deviceId': deviceId,
      'file': multipartFile
    });

    await _postFormData('api/user/process-data', formData);
  }

  Future<dynamic> _postFormData(String url, FormData formData) async {
    Dio dio = Dio();
    dio.options = BaseOptions(baseUrl: 'http://munsiji.qubexedu.com/',);
 
    Response response;
    try {
      response = await dio.post(
        'http://munsiji.qubexedu.com/' + url,
        data: formData,

      );
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE)
        throw (e.response.data);
      else
        throw ('No Internet Connection or Server Offline');
    } catch (e) {
      throw (e);
    }
    if (response.statusCode != 200)
      throw (response.data);
    else
      return;
  }
}
