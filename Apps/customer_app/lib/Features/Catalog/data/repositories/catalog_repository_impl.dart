import '../../domain/repositories/catalog_repository.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../datasources/catalog_remote_datasource.dart';

/// Catalog Repository Implementation - Data Layer
/// تنفيذ مستودع الكتالوج في طبقة البيانات
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _dataSource;

  CatalogRepositoryImpl({required CatalogRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _dataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    return await _dataSource.getProductsByCategory(categoryId);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return await _dataSource.searchProducts(query);
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    return await _dataSource.getProductById(productId);
  }

  @override
  Future<List<ProductEntity>> getAllProducts({int limit = 50}) async {
    return await _dataSource.getAllProducts(limit: limit);
  }
}

