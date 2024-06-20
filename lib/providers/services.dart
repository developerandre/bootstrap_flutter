import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'model.dart';
import 'package:dio/dio.dart';

const String appName = "";
const String appNameDescription = "...";
const String isarDBName = 'xxx';

class Services {
  static Services? _instance;
  static String? token;
  static late Dio _dio;
  TextEditingController searchCtrl = TextEditingController();
  final String fcmKey = '';
  final String paygate = '';

  Map countryData = {};

  static const String baseUrl = "http://127.0.0.1:4404"; // Desktop

  static const platform = MethodChannel('own.channel/bootstrap');
  static UserAccount? user;
  static String appDirectory = '';
  static List<String> jours = [
    '',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche'
  ];
  static List<String> months = [
    '',
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    'Juin',
    'Juillet',
    'Aôut',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre'
  ];

  Services._();

  static Services get instance {
    if (_instance == null) {
      _instance = Services._();
      _dio = Dio(BaseOptions(baseUrl: baseUrl));
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (options, handler) async {
        // Do something before request is sent
        return handler.next(options); //continue
        // If you want to resolve the request with some custom data，
        // you can resolve a `Response` object eg: `handler.resolve(response)`.
        // If you want to reject the request with a error message,
        // you can reject a `DioException` object eg: `handler.reject(dioError)`
      }, onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // If you want to reject the request with a error message,
        // you can reject a `DioException` object eg: `handler.reject(dioError)`
      }, onError: (DioException e, handler) async {
        return handler.next(e); //continue
        // If you want to resolve the request with some custom data，
        // you can resolve a `Response` object eg: `handler.resolve(response)`.
      }));
    }
    return _instance!;
  }

  reload() {}

  AppRequestOptions createRequestOption(
      [Map<String, dynamic>? req, Map<String, dynamic>? hds]) {
    AppRequestOptions options = AppRequestOptions();

    Map<String, dynamic> params = {};

    req = req ?? {};

    req['size'] = req['size'];
    if (req['page'] != null) params.addAll({'page': req['page']});
    if (req['size'] != null) params.addAll({'size': req['size']});
    if (req['sort'] != null) {
      params.addAll({'sort': req['sort']});
    }
    if (req['query'] != null) params.addAll({'query': req['query']});

    Map queries = req;
    List keys = queries.keys.toList();
    for (int i = 0, len = keys.length; i < len; i++) {
      if (!['page', 'size', 'sort', 'query'].contains(keys[i])) {
        if (queries[keys[i]] != null && queries[keys[i]] != '') {
          params.addAll({keys[i]: queries[keys[i]]});
        }
      }
    }

    options.queryParameters = params;
    Map<String, dynamic> headers = {};
    headers.addAll({'accept': '*/*'});
    headers.addAll({
      'Access-Control-Allow-Headers':
          'X-Total-Count, Link,Uuid,udid-X-Token,udid-X-Token-CHL'
    });
    headers.addAll({'Access-Control-Allow-Origin': '*'});
    token ??= Hive.box('settings').get('token');
    if (token != null) {
      token = token!.replaceAll(RegExp(r"[']"), '');
      token = token!.replaceAll(RegExp(r'^["]'), '');
      headers.addAll({'Authorization': 'Bearer ${token!}'});
    }
    if (hds != null) headers.addAll(hds);
    options.options.headers = headers;
    return options;
  }

  Future<ResponseWrapper> getEntity(String path,
      {Map<String, dynamic>? req, CancelToken? cancelToken}) {
    AppRequestOptions options = createRequestOption(req);
    return _dio
        .get(path,
            queryParameters: options.queryParameters,
            options: options.options,
            cancelToken: cancelToken)
        .then((res) => ResponseWrapper(res.headers, res.data, res.statusCode));
  }

  Future<ResponseWrapper> addEntity(String path, model,
      {Map<String, dynamic>? req, CancelToken? cancelToken}) {
    AppRequestOptions options = createRequestOption(req);
    return _dio
        .post(path,
            data: model,
            queryParameters: options.queryParameters,
            options: options.options,
            cancelToken: cancelToken)
        .then((res) => ResponseWrapper(res.headers, res.data, res.statusCode));
  }

  Future<ResponseWrapper> editEntity(String path, model,
      {Map<String, dynamic>? req, CancelToken? cancelToken}) async {
    AppRequestOptions options = createRequestOption(req);
    return _dio
        .put(path,
            data: model,
            queryParameters: options.queryParameters,
            options: options.options,
            cancelToken: cancelToken)
        .then((res) => ResponseWrapper(res.headers, res.data, res.statusCode));
  }

  Future<ResponseWrapper> deleteEntity(String path,
      {Map<String, dynamic>? req, CancelToken? cancelToken}) {
    AppRequestOptions options = createRequestOption(req);
    return _dio
        .delete(path,
            queryParameters: options.queryParameters,
            options: options.options,
            cancelToken: cancelToken)
        .then((res) => ResponseWrapper(res.headers, res.data, res.statusCode));
  }

  Future<ResponseWrapper<Map<String, dynamic>>> updateUser(Map model) {
    AppRequestOptions options = createRequestOption();
    return _dio
        .put('/api/user',
            queryParameters: options.queryParameters,
            data: model,
            options: options.options)
        .then((res) async {
      await Hive.box('settings').put('user', res.data['user']);
      user = UserAccount.addFromMap(res.data['user']);
      return ResponseWrapper(res.headers, res.data, res.statusCode);
    });
  }

  Future<ResponseWrapper<Map<String, dynamic>>> register(Map model) async {
    AppRequestOptions options = createRequestOption();

    return _dio
        .post('/api/auth/register',
            queryParameters: options.queryParameters,
            data: model,
            options: options.options)
        .then((res) async {
      token = res.headers.value('xsrf-token');
      if (token != null) Hive.box('settings').put('token', token!);
      user = UserAccount.addFromMap({'user': res.data['user']});
      await Hive.box('settings').put('user', res.data['user']);

      return ResponseWrapper(res.headers, res.data, res.statusCode);
    });
  }

  Future<ResponseWrapper<Map<String, dynamic>>> login(Map model) async {
    AppRequestOptions options = createRequestOption();

    return _dio
        .post('/api/auth',
            queryParameters: options.queryParameters,
            data: model,
            options: options.options)
        .then((res) async {
      token = res.headers.value('xsrf-token');
      if (token != null) Hive.box('settings').put('token', token!);
      //print("login ${res.data}");
      user = UserAccount.addFromMap({'user': res.data['user']});
      await Hive.box('settings').put('user', res.data['user']);

      return ResponseWrapper(res.headers, res.data, res.statusCode);
    });
  }

  Future<ResponseWrapper<Map<String, dynamic>>> getAccount() async {
    AppRequestOptions options = createRequestOption();

    return _dio
        .post('/api/auth/account',
            queryParameters: options.queryParameters,
            data: {},
            options: options.options)
        .then((res) async {
      token = res.headers.value('xsrf-token');
      if (token != null) Hive.box('settings').put('token', token!);
      user = UserAccount.addFromMap({'user': res.data['user']});
      await Hive.box('settings').put('user', res.data['user']);
      return ResponseWrapper(res.headers, res.data, res.statusCode);
    });
  }

  String generateShortUniqueCode({int maxLength = 6}) {
    int now = DateTime.now().millisecondsSinceEpoch;
    int random = Random().nextInt(pow(36, 6).toInt());
    String code = (now * pow(36, maxLength).toInt() + random).toRadixString(36);
    code = code.substring(max(0, code.length - maxLength));
    random = Random().nextInt(code.length);
    code = code.replaceFirst(code[random], code[random].toUpperCase());
    random = Random().nextInt(code.length);
    code = code.replaceFirst(code[random], code[random].toUpperCase());
    return code;
  }
}
