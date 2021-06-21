import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as fss;

final api = ApiHelper();

class ApiHelper {

  static const int connectTimeout = 5000;
  static const int receiveTimeout = 5000;

  final storage = new fss.FlutterSecureStorage();
  BaseOptions baseOptions = BaseOptions(receiveTimeout: receiveTimeout, connectTimeout: connectTimeout);
  dynamic get(String url, { Map<String, dynamic> params, bool auth: true} ) async {
    Dio dio = new Dio(baseOptions);
    // String query = getQueryString(params);
    // if(query != ''){
    //   url += '?' + query;
    // }

    // await storage.write(key: 'mendJwt', value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsImlhdCI6MTYwMTU0NTMxOCwiZXhwIjoxNjA0MTM3MzE4fQ'
    //     '.vy-EAg8hR92KWleJ4HmqeI0U0CfFr4N49cTed7FpSn8');

    Options options = Options();

    if(auth){
      String token = await storage.read(key: 'mendJwt');
      options.headers = {'Authorization' : 'Bearer ' + token};
    }

    try{
      Response response = await dio.get(url, queryParameters: params, options: options);
      return {'code': 1000, 'data': response.data};
    } on DioError catch(e){
      print('Errr=' + e.message);
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return {'code': 1001, 'message': 'Timed out'};
      } else if(e.type == DioErrorType.RESPONSE) {
        return {'code': 1002, 'message': 'incorrect request. ResponseCode: ${e.response.statusCode}'};
      }else {
        return {'code': 1003, 'message': 'Something wrong.'};
      }
    }
  }

  dynamic post(String url, { Map<String, dynamic> params, bool auth: true} ) async {
    Dio dio = new Dio(baseOptions);
    Options options = Options();
    if(auth){
      options.headers = {'Authorization' : 'Bearer ' + await storage.read(key: 'mendJwt')};
    }
    try{
      Response response = await dio.post(url, options: options, data: params);
      return {'code': 1000, 'data': response.data};
    } on DioError catch(e){
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return {'code': 1001, 'message': 'Timed out'};
      } else if(e.type == DioErrorType.RESPONSE) {
        return {'code': 1002, 'message': e.response.data['message'] ?? '${e.message}'};
      }else {
        return {'code': 1003, 'message': 'Something wrong. '};
      }
    }
  }

  dynamic formPost(String url, {FormData formData, bool auth: true}) async {
    Dio dio = new Dio(baseOptions);
    Options options = Options();
    if(auth){
      options.headers = {'Authorization' : 'Bearer ' + await storage.read(key: 'mendJwt'), 'mimeType': 'multipart/form-data'};
    }
    try{
      Response response = await dio.post(url, options: options, data: formData);
      return {'code': 1000, 'data': response.data};
    } on DioError catch(e){
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return {'code': 1001, 'message': 'Timed out'};
      } else if(e.type == DioErrorType.RESPONSE) {
        return {'code': 1002, 'message': e.response.data['message'] ?? '${e.message}'};
      }else {
        return {'code': 1003, 'message': 'Something wrong. '};
      }
    }
  }

  dynamic delete(String url, { Map<String, dynamic> params, bool auth: true}) async {
    Dio dio = new Dio(baseOptions);
    Options options = Options();
    if(auth){
      options.headers = {'Authorization' : 'Bearer ' + await storage.read(key: 'mendJwt')};
    }
    try{
      Response response = await dio.delete(url, options: options, data: params);
      return {'code': 1000, 'data': response.data};
    } on DioError catch(e){
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return {'code': 1001, 'message': 'Timed out'};
      } else if(e.type == DioErrorType.RESPONSE) {
        return {'code': 1002, 'message': e.response.data['message'] ?? '${e.message}'};
      }else {
        return {'code': 1003, 'message': 'Something wrong. '};
      }
    }
  }

  dynamic put(String url, { Map<String, dynamic> params, bool auth: true}) async {
    Dio dio = new Dio(baseOptions);
    Options options = Options();
    if(auth){
      options.headers = {'Authorization' : 'Bearer ' + await storage.read(key: 'mendJwt')};
    }
    try{
      Response response = await dio.put(url, options: options, data: params);
      return {'code': 1000, 'data': response.data};
    } on DioError catch(e){
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return {'code': 1001, 'message': 'Timed out'};
      } else if(e.type == DioErrorType.RESPONSE) {
        return {'code': 1002, 'message': e.response.data['message'] ?? '${e.message}', 'statusCode': e.response.statusCode};
      }else {
        return {'code': 1003, 'message': 'Something wrong. '};
      }
    }
  }

  /// jsonMap to queryString
  String getQueryString(Map params) {
    if(params == null){
      return '';
    }
    List list = [];
    String query = '';
    params.forEach((key, value) {
      if (value is String || value is int || value is double || value is bool) {
        list.add('$key=$value');
      }
    });

    return list.join('&');
  }
}

//for Testing
void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  print('main executed');

  Map<String, dynamic> params = {
    // '_limit' : 3,
    // '_sort': 'created_at:asc'
    // 'id': 214
    'identifier': '88774777',
    'password': '12345678'
    // 'event_id' : 214
  };
  // dynamic res = await api.get('http://192.168.77.137:1337/eventstaffs/', params: params);
  dynamic res = await api.post('http://192.168.77.137:1337/auth/local', params: params, auth: false);
  // dynamic res = await api.delete('http://192.168.77.137:1337/eventstaffs/3', params: params);
  // dynamic res = await api.put('http://192.168.77.137:1337/eventstaffs/1', params: params);

  // print('res = ' + res['list'][0]['name']);
  print('res = ' + res['code'].toString());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestWidget(),
      routes: {
      },
    );
  }
}

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Hello World!!', textAlign: TextAlign.center,)
    );
  }
}