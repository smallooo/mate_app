import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/api/creative.dart';
import '../repo/api/page.dart';
import '../repo/api_server.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(GalleryInitial()) {
    on<GalleryLoadEvent>((event, emit) async {
      emit(GalleryInitial());

      final res = await APIServer().creativeGallery(
        cache: !event.forceRefresh,
        page: event.page,
        perPage: 20,
      );

      emit(GalleryLoaded(data: res));
    });

    on<GalleryItemLoadEvent>((event, emit) async {
      emit(GalleryInitial());

      final res = await APIServer().creativeGalleryItem(
        cache: !event.forceRefresh,
        id: event.id,
      );

      emit(GalleryItemLoaded(
        item: res.item,
        isInternalUser: res.isInternalUser,
      ));
    });
  }
}
