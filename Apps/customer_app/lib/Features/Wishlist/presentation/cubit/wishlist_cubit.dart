import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Home/domain/entities/product_entity.dart';

class WishlistState {
  final List<ProductEntity> items;

  const WishlistState({this.items = const []});

  bool contains(ProductEntity product) =>
      items.any((p) => p.id == product.id);

  bool containsId(String productId) =>
      items.any((p) => p.id == productId);
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void toggle(ProductEntity product) {
    final items = List<ProductEntity>.from(state.items);
    final index = items.indexWhere((p) => p.id == product.id);

    if (index == -1) {
      items.add(product);
    } else {
      items.removeAt(index);
    }

    emit(WishlistState(items: items));
  }

  void remove(String productId) {
    final items =
        state.items.where((p) => p.id != productId).toList();
    emit(WishlistState(items: items));
  }

  void clear() {
    emit(const WishlistState(items: []));
  }
}


