import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mate_app/page/component/chat/message_state_manager.dart';
import 'package:mate_app/repo/api_server.dart';
import 'package:mate_app/repo/cache_repo.dart';
import 'package:mate_app/repo/chat_message_repo.dart';
import 'package:mate_app/repo/creative_island_repo.dart';
import 'package:mate_app/repo/data/cache_data.dart';
import 'package:mate_app/repo/data/chat_history.dart';
import 'package:mate_app/repo/data/chat_message_data.dart';
import 'package:mate_app/repo/data/creative_island_data.dart';
import 'package:mate_app/repo/data/room_data.dart';
import 'package:mate_app/repo/data/setting_data.dart';
import 'package:mate_app/repo/settings_repo.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mate_app/helper/http.dart' as httpx;

import 'data/migrate.dart';
import 'helper/constant.dart';
import 'helper/logger.dart';
import 'helper/model.dart';
import 'helper/path.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helper/platform.dart';
import 'package:path/path.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  httpx.HttpClient.init();

  // 初始化路径，获取到系统相关的文档、缓存目录
  await PathHelper().init();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'rendering library' ||
        details.library == 'image resource service') {
      return;
    }

    Logger.instance.e(
      details.summary,
      error: details.exception,
      stackTrace: details.stack,
    );
    print(details.stack);
  };

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    if (PlatformTool.isWindows() ||
        PlatformTool.isLinux() ||
        PlatformTool.isMacOS()) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      var path = absolute(join(PathHelper().getHomePath, 'databases'));
      databaseFactory.setDatabasesPath(path);
    }
  }

  // 数据库连接
  final db = await databaseFactory.openDatabase(
    'system.db',
    options: OpenDatabaseOptions(
      version: databaseVersion,
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          await migrate(db, oldVersion, newVersion);
        } catch (e) {
          Logger.instance.e('数据库升级失败', error: e);
        }
      },
      onCreate: initDatabase,
      onOpen: (db) {
        Logger.instance.i('数据库存储路径：${db.path}');
      },
    ),
  );

  // 加载配置
  final settingProvider = SettingDataProvider(db);
  await settingProvider.loadSettings();

  // 创建数据仓库
  final settingRepo = SettingRepository(settingProvider);
  //final openAIRepo = OpenAIRepository(settingProvider);
  //final deepAIRepo = DeepAIRepository(settingProvider);
  //final stabilityAIRepo = StabilityAIRepository(settingProvider);
  final cacheRepo = CacheRepository(CacheDataProvider(db));

  final chatMsgRepo = ChatMessageRepository(
    RoomDataProvider(db),
    ChatMessageDataProvider(db),
    ChatHistoryProvider(db),
  );

  final creativeIslandRepo =
  CreativeIslandRepository(CreativeIslandDataProvider(db));

  // 聊天状态加载器
  final stateManager = MessageStateManager(cacheRepo);

  // // 初始化聊天实现解析器
  // ModelResolver.instance.init(
  //   openAIRepo: openAIRepo,
  //   deepAIRepo: deepAIRepo,
  //   stabilityAIRepo: stabilityAIRepo,
  // );

  APIServer().init(settingRepo);
  ModelAggregate.init(settingRepo);
  // Cache().init(settingRepo, cacheRepo);
  //
  // // 从服务器获取客户端支持的能力清单
  // try {
  //   final capabilities = await APIServer().capabilities(cache: false);
  //   Ability().init(settingRepo, capabilities);
  // } catch (e) {
  //   Logger.instance.e('获取客户端能力清单失败', error: e);
  //   Ability().init(
  //     settingRepo,
  //     Capabilities(
  //       applePayEnabled: true,
  //       otherPayEnabled: true,
  //       translateEnabled: true,
  //       mailEnabled: true,
  //       openaiEnabled: true,
  //       homeModels: [],
  //       homeRoute: '/chat-chat',
  //       showHomeModelDescription: true,
  //       supportWebsocket: false,
  //     ),
  //   );
  // }
  //
  // // 初始化聊天室 Bloc 管理器
  // final m = ChatBlocManager();
  // m.init((roomId, {chatHistoryId}) {
  //   return ChatMessageBloc(
  //     roomId,
  //     chatHistoryId: chatHistoryId,
  //     chatMsgRepo: chatMsgRepo,
  //     settingRepo: settingRepo,
  //   );
  // });
  //
  
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    ); 
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
