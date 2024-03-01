
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../helper/constant.dart';
import '../helper/http.dart';
import '../repo/api/user.dart';
import '../repo/api_server.dart';
import '../repo/settings_repo.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final SettingRepository settings;

  AccountBloc(this.settings) : super(AccountInitial()) {
    // 加载用户信息
    on<AccountLoadEvent>((event, emit) async {
      emit(AccountLoading());

      final token = settings.get(settingAPIServerToken);
      if (token != null && token != '') {
        try {
          final user = await APIServer().userInfo(cache: event.cache);
          if (user != null) {
            emit(AccountLoaded(user));
          } else {
            emit(AccountNeedSignIn());
          }
        } catch (e) {
          emit(AccountLoaded(null, error: e));
        }
      } else {
        emit(AccountNeedSignIn());
      }
    });

    on<AccountSignOutEvent>((event, emit) async {
      await settings.set(settingAPIServerToken, '');
      await settings.set(settingUserInfo, '');

      HttpClient.cacheManager.clearAll();
      emit(AccountNeedSignIn());
    });

    on<AccountUpdateEvent>((event, emit) async {
      try {
        if (event.realname != null) {
          await APIServer().updateUserRealname(realname: event.realname!);
        }

        if (event.avatarURL != null) {
          await APIServer().updateUserAvatar(avatarURL: event.avatarURL!);
        }

        emit(AccountLoaded(await APIServer().userInfo(cache: false)));
      } catch (e) {
        emit(AccountLoaded(await APIServer().userInfo(cache: false), error: e));
      }
    });
  }
}