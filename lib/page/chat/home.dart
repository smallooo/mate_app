import 'dart:io';
import 'dart:math';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drawing_board/paint_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../bloc/chat_chat_bloc.dart';
import '../../bloc/free_count_bloc.dart';
import '../../helper/ability.dart';
import '../../helper/cache.dart';
import '../../helper/global_store.dart';
import '../../helper/haptic_feedback.dart';
import '../../helper/helper.dart';
import '../../lang/lang.dart';
import '../../repo/api/creative.dart';
import '../../repo/api/model.dart';
import '../../repo/api_server.dart';
import '../../repo/model/chat_history.dart';
import '../../repo/model/misc.dart';
import '../../repo/settings_repo.dart';
import '../component/background_container.dart';
import '../component/chat/empty.dart';
import '../component/chat/file_upload.dart';
import '../component/chat/voice_record.dart';
import '../component/column_block.dart';
import '../component/dialog.dart';
import '../component/enhanced_textfield.dart';
import '../component/global_alert.dart';
import '../component/model_indicator.dart';
import '../component/notify_message.dart';
import '../component/sliver_component.dart';
import '../component/theme/custom_size.dart';
import '../component/theme/custom_theme.dart';

class HomePage extends StatefulWidget {
  final SettingRepository setting;
  final bool showInitialDialog;
  final int? reward;
  const HomePage({
    super.key,
    required this.setting,
    this.showInitialDialog = false,
    this.reward,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  static const int itemsPerPage = 10;

  // Define the current page
  int currentPage = 0;

  // Define a flag to know if there's more data to load
  bool hasMore = true;

  // Define a list to hold the data
  List<CreativeGallery> data = [];

  /// 用于监听键盘事件，实现回车发送消息，Shift+Enter换行
  late final FocusNode _focusNode = FocusNode(
    onKey: (node, event) {
      if (!event.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
        if (event is RawKeyDownEvent) {
          // onSubmit(context, _textController.text.trim());
        }

        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
    
    if (Ability().homeModels.isNotEmpty) {
      // models = Ability().homeModels;
    }
    
    setState(() {});
    
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadMoreData();
  }

  void _loadMoreData() {
    if (!hasMore) return;

    // Simulate a delay
    Future.delayed(Duration(seconds: 2)).then((_) {
      setState(() {
        List<CreativeGallery> newItems = List<CreativeGallery>.generate(
          itemsPerPage,
              (index) => CreativeGallery(
            id: index + currentPage * itemsPerPage,
            previewImage: 'https://img.thebeastshop.com/file/app_image/36fe7f23342b4ecbafdcc37fe415ec42.jpg@90q',
            username: 'User${index + currentPage * itemsPerPage}',
            userId: index + currentPage * itemsPerPage,
            hotValue: (index + currentPage * itemsPerPage) * 10, creativeType: 1, creativeId: '1',
          ),
        );

        data.addAll(newItems);

        // If we've reached the maximum number of items, set hasMore to false
        if (data.length >= 5000) {
          hasMore = false;
        }

        currentPage++;
      });
    });
  }
  

  Map<String, ModelIndicator> buildModelIndicators() {
    Map<String, ModelIndicator> map = {};

    // for (var i = 0; i < models.length; i++) {
    //   var model = models[i];
    //   map[model.id] = ModelIndicator(
    //     model: model,
    //     selected: model.id == currentModel?.model.id,
    //     iconAndColor: iconAndColors[i],
    //     itemCount: models.length,
    //   );
    // }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('相亲角'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '推荐'),
            Tab(text: '男生'),
            Tab(text: '女生'),
            Tab(text: '同城'),
            Tab(text: '同省'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridView(),
          _buildGridView(),
          _buildGridView(),
          _buildGridView(),
          _buildGridView(),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: data.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == data.length) {
          // If we're at the end of the list and there's more data, show a loading indicator
          _loadMoreData();
          return Center(child: CircularProgressIndicator());
        } else {
          // Otherwise, show the data
          return Center(
            child: Column(
              children: [
                Image.network(
                  data[index].preview,
                  width: 100,
                  height: 100,
                ),
                Text(
                  data[index].username! + ' ' + data[index].hotValue.toString(),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
