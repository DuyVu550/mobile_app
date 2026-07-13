import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;

  CartRepositoryImpl(this._dataSource);

  @override
  Stream<List<CartItemModel>> watchCart(String userId) => _dataSource.watchCart(userId);

  @override
  Future<void> addToCart(String userId, String productId, int quantity) =>
      _dataSource.addToCart(userId, productId, quantity);

  @override
  Future<void> updateQuantity(String userId, String productId, int quantity) =>
      _dataSource.updateQuantity(userId, productId, quantity);

  @override
  Future<void> removeFromCart(String userId, String productId) =>
      _dataSource.removeFromCart(userId, productId);

  @override
  Future<void> clearCart(String userId) => _dataSource.clearCart(userId);
}
