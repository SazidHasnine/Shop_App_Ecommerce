import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/features/product/data/product_repository.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';


class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;
  final bool autoFetch;

  List<Product> _products = [];
  List<String> _categories = ['All'];
  Product? _selectedProduct;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  ProductProvider({required this.productRepository, this.autoFetch = true}){
    if(autoFetch){

    }
  }

  List<Product> get products => _products;
  List<String> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await productRepository.getProducts(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch(e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  Future<void> fetchCategories() async {
    try {
      final fetched = await productRepository.getCategories();
      if(!fetched.contains('All')) {
        _categories = ['All', ...fetched];
      } else {
        _categories = fetched;
      }
      notifyListeners();
    } catch (_) {
      // no need for fallback handling, already done in repo
    }
  }

  Future<void> fetchProductById(int id)  async {
    if(_selectedProduct?.id != id) {
      // Look up in the existing catalog products for immediate display without flash
      _selectedProduct = products.where((p) => p.id == id).firstOrNull;
    }

    _isLoading = (_selectedProduct == null);
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await productRepository.getProductById(id);
    } catch(e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if(_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts();
  }

  void search(String query) {
    _searchQuery = query;
    fetchProducts();
  }

}