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

  Future<void> fetchProducts {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();


  }

}