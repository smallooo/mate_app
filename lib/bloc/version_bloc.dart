
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repo/api_server.dart';
import '../repo/model/misc.dart';

part 'version_event.dart';
part 'version_state.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  VersionBloc() : super(VersionInitial()) {
    on<VersionCheckEvent>((event, emit) async {
      emit(VersionInitial());

      final version = await APIServer().versionCheck();
      emit(VersionCheckLoaded(version));
    });
  }
}
