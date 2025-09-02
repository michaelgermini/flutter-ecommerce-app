import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/product_provider.dart';
import '../models/search_filters.dart';
import '../widgets/product_card.dart';
import '../widgets/micro_interactions.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load products into search provider if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      final searchProvider = context.read<SearchProvider>();

      if (searchProvider.allProducts.isEmpty && productProvider.products.isNotEmpty) {
        searchProvider.setProducts(productProvider.products);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Search products, categories, brands...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              searchProvider.search('');
                              searchProvider.hideSuggestions();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (query) {
                    searchProvider.updateSuggestions(query);
                    if (query.isNotEmpty) {
                      searchProvider.search(query);
                    }
                  },
                  onSubmitted: (query) {
                    searchProvider.hideSuggestions();
                    searchProvider.search(query);
                  },
                ),

                const SizedBox(height: 12),

                // Search Actions Row
                Row(
                  children: [
                    // Filter Toggle Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showFiltersBottomSheet(context),
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filters'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Sort Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showSortBottomSheet(context),
                        icon: const Icon(Icons.sort),
                        label: const Text('Sort'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Active Filters Display
                if (searchProvider.currentFilters.hasActiveFilters)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filters active',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            searchProvider.clearFilters();
                            if (_searchController.text.isNotEmpty) {
                              searchProvider.search(_searchController.text);
                            }
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Search Suggestions
          if (searchProvider.showSuggestions && searchProvider.suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchProvider.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = searchProvider.suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search, size: 20),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      searchProvider.hideSuggestions();
                      searchProvider.search(suggestion);
                      _searchFocus.unfocus();
                    },
                  );
                },
              ),
            ),

          // Search Results
          Expanded(
            child: searchProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : searchProvider.errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search Error',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchProvider.errorMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : searchProvider.searchResults.isEmpty && _searchController.text.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different keywords or adjust filters',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : _buildSearchResults(searchProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    final theme = Theme.of(context);

    if (searchProvider.searchResults.isEmpty && _searchController.text.isEmpty) {
      // Show search history when no search has been performed
      return _buildSearchHistory(searchProvider);
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '${searchProvider.searchResults.length} results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (searchProvider.searchResults.isNotEmpty)
                Text(
                  'for "${_searchController.text}"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),

        // Results Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchProvider.searchResults[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHistory(SearchProvider searchProvider) {
    final theme = Theme.of(context);

    if (searchProvider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start searching',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Search for products, categories, or brands',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => searchProvider.clearSearchHistory(),
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchProvider.searchHistory.length,
            itemBuilder: (context, index) {
              final item = searchProvider.searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(item.query),
                subtitle: Text('${item.resultCount} results'),
                trailing: Text(
                  _formatTimeAgo(item.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () {
                  _searchController.text = item.query;
                  searchProvider.search(item.query);
                  _searchFocus.unfocus();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SearchFiltersBottomSheet(),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SortOptionsBottomSheet(),
    );
  }
}

class SearchFiltersBottomSheet extends StatefulWidget {
  const SearchFiltersBottomSheet({super.key});

  @override
  State<SearchFiltersBottomSheet> createState() => _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    final searchProvider = context.read<SearchProvider>();
    _filters = searchProvider.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters = const SearchFilters();
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),

          const Divider(),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  _buildPriceRangeFilter(),

                  const SizedBox(height: 24),

                  // Rating Filter
                  _buildRatingFilter(),

                  const SizedBox(height: 24),

                  // Categories
                  _buildCategoryFilter(),

                  const SizedBox(height: 24),

                  // Brands
                  _buildBrandFilter(),

                  const SizedBox(height: 24),

                  // Availability
                  _buildAvailabilityFilter(),
                ],
              ),
            ),
          ),

          // Apply Button
          SafeArea(
            child: ElevatedButton(
              onPressed: () {
                searchProvider.updateFilters(_filters);
                if (searchProvider.currentFilters.query.isNotEmpty) {
                  searchProvider.search(searchProvider.currentFilters.query, filters: _filters);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  setState(() {
                    _filters = _filters.copyWith(minPrice: price);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  setState(() {
                    _filters = _filters.copyWith(maxPrice: price);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [4.0, 3.0, 2.0, 1.0].map((rating) {
            return FilterChip(
              label: Row(
                children: [
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 4),
                  Text('${rating}+'),
                ],
              ),
              selected: _filters.minRating == rating,
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(minRating: selected ? rating : null);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Electronics', 'Clothing', 'Home', 'Sports', 'Books'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: categories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: _filters.categories.contains(category),
              onSelected: (selected) {
                setState(() {
                  final newCategories = List<String>.from(_filters.categories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  _filters = _filters.copyWith(categories: newCategories);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandFilter() {
    final brands = ['Apple', 'Samsung', 'Nike', 'Adidas', 'Sony'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brands',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: brands.map((brand) {
            return FilterChip(
              label: Text(brand),
              selected: _filters.brands.contains(brand),
              onSelected: (selected) {
                setState(() {
                  final newBrands = List<String>.from(_filters.brands);
                  if (selected) {
                    newBrands.add(brand);
                  } else {
                    newBrands.remove(brand);
                  }
                  _filters = _filters.copyWith(brands: newBrands);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('In Stock Only'),
          value: _filters.inStockOnly,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(inStockOnly: value ?? false);
            });
          },
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('On Sale Only'),
          value: _filters.onSaleOnly,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(onSaleOnly: value ?? false);
            });
          },
          dense: true,
        ),
      ],
    );
  }
}

class SortOptionsBottomSheet extends StatelessWidget {
  const SortOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...SortOption.options.map((option) {
            final isSelected = searchProvider.currentFilters.sortBy == option.value;
            return ListTile(
              leading: Text(
                option.icon,
                style: const TextStyle(fontSize: 20),
              ),
              title: Text(option.label),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: theme.colorScheme.primary,
                    )
                  : null,
              onTap: () {
                searchProvider.updateFilters(
                  searchProvider.currentFilters.copyWith(sortBy: option.value),
                );
                if (searchProvider.currentFilters.query.isNotEmpty) {
                  searchProvider.search(
                    searchProvider.currentFilters.query,
                    filters: searchProvider.currentFilters.copyWith(sortBy: option.value),
                  );
                }
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
