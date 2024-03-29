
import 'package:flutter/cupertino.dart';

import 'bloc_manager.dart';

part 'notify_event.dart';
part 'notify_state.dart';

class NotifyBloc extends BlocExt<NotifyEvent, NotifyState> {
  NotifyBloc() : super(NotifyInitial()) {
    on<NotifyFiredEvent>((event, emit) {
      emit(NotifyFired(event.title, event.body, event.type));
    });

    on<NotifyResetEvent>((event, emit) {
      emit(NotifyInitial());
    });
  }
}
