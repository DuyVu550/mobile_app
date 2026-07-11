import 'package:fpdart/fpdart.dart';
import '../entities/toy.dart';
import '../entities/brand.dart';

abstract interface class ToyRepository {
  /// Stream danh sách sản phẩm realtime. Phát Left(message) khi có lỗi.
  Stream<Either<String, List<Toy>>> watchToys();

  /// Lấy chi tiết 1 sản phẩm theo id.
  Future<Either<String, Toy>> getToyById(String id);

  /// Stream danh sách thương hiệu đồ chơi realtime.
  Stream<Either<String, List<Brand>>> watchBrands();
}

