import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/api_server.dart';
import '../repo/model/misc.dart';

part 'background_image_event.dart';
part 'background_image_state.dart';

class BackgroundImageBloc
    extends Bloc<BackgroundImageEvent, BackgroundImageState> {
  BackgroundImageBloc() : super(BackgroundImageInitial()) {
    on<BackgroundImageLoadEvent>((event, emit) async {
      final images = await APIServer().backgrounds();
      emit(BackgroundImageLoaded(images));
    });
  }
}