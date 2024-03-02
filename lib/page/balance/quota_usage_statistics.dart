import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../repo/api_server.dart';
import '../../repo/model/misc.dart';
import '../../repo/settings_repo.dart';
import '../component/background_container.dart';
import '../component/loading.dart';
import '../component/message_box.dart';
import '../component/theme/custom_size.dart';
import '../component/theme/custom_theme.dart';

class QuotaUsageStatisticsScreen extends StatefulWidget {
  final SettingRepository setting;
  const QuotaUsageStatisticsScreen({super.key, required this.setting});

  @override
  State<QuotaUsageStatisticsScreen> createState() =>
      _QuotaUsageStatisticsScreenState();
}

class _QuotaUsageStatisticsScreenState
    extends State<QuotaUsageStatisticsScreen> {
  List<QuotaUsageInDay> usages = [];
  bool loaded = false;

  @override
  void initState() {
    APIServer().quotaUsedStatistics().then((value) {
      setState(() {
        usages = value;
        loaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '使用明细',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const MessageBox(
                message: '使用明细将在次日更新，显示近 30 天的使用量。',
                type: MessageBoxType.info,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildQuotaUsagePage(context, customColors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaUsagePage(
      BuildContext context,
      CustomColors customColors,
      ) {
    if (!loaded) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    final usageGt0 = usages.where((e) => e.used > 0 || e.used == -1).toList();
    if (usageGt0.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              '暂无使用记录',
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var item in usageGt0)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customColors.paymentItemBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      context
                          .push('/quota-usage-daily-details?date=${item.date}');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.used == -1)
                          const Text('未出账')
                        else
                          Text('${item.used > 0 ? "-" : ""}${item.used}'),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
