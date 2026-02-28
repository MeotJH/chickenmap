import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/app/write_chicken_review_button.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/constants/rating_dimensions.dart';
import 'package:front/presentation/widgets/rating_slider.dart';
import 'package:front/domain/entities/brand.dart';
import 'package:front/domain/entities/menu.dart';
import 'package:front/presentation/providers/app_providers.dart';
import 'package:front/presentation/providers/review_providers.dart';
import 'package:front/presentation/providers/ranking_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:front/data/remote/review_api.dart';

// 리뷰 작성 화면이다.
class ReviewWritePage extends ConsumerStatefulWidget {
  final String? storeName;
  final String? address;
  final String? menuName;
  final String? brandId;

  const ReviewWritePage({
    super.key,
    this.storeName,
    this.address,
    this.menuName,
    this.brandId,
  });

  @override
  // 리뷰 작성 화면의 상태를 생성한다.
  ConsumerState<ReviewWritePage> createState() => _ReviewWritePageState();
}

class _ReviewWritePageState extends ConsumerState<ReviewWritePage> {
  List<String> _activeDimensions = dimensionsForCategory(null);
  Map<String, double> _scores = {
    for (final key in dimensionsForCategory(null)) key: 3.0,
  };
  double overall = 3.0;
  List<Brand> _brands = [];
  Brand? _selectedBrand;
  List<Menu> _menus = [];
  Menu? _selectedMenu;
  final _menuSearchController = TextEditingController();
  bool _loadingMenus = false;
  String? _menuError;
  Brand? _lastConfirmedBrand;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    overall = _calculateOverall();
    _loadBrands();
  }

  @override
  void dispose() {
    _menuSearchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final repository = ref.read(menuRepositoryProvider);
      final brands = await repository.fetchBrands();
      final matched = widget.brandId == null || widget.brandId!.isEmpty
          ? (_matchBrand(brands, widget.storeName ?? '') ??
                _findBrandById(brands, 'brand-local'))
          : _findBrandById(brands, widget.brandId!) ?? brands.first;
      setState(() {
        _brands = brands;
        _selectedBrand = matched;
        _lastConfirmedBrand = matched;
      });
      if (matched != null) {
        await _loadMenus(matched.id);
      }
    } catch (_) {
      setState(() {
        _menuError = '메뉴 목록을 불러오지 못했어요.';
      });
    }
  }

  Brand? _matchBrand(List<Brand> brands, String storeName) {
    final normalized = storeName.replaceAll(' ', '').toLowerCase();
    for (final brand in brands) {
      final token = brand.name.replaceAll(' ', '').toLowerCase();
      if (token.isNotEmpty && normalized.contains(token)) {
        return brand;
      }
    }
    return null;
  }

  Brand? _findBrandById(List<Brand> brands, String brandId) {
    for (final brand in brands) {
      if (brand.id == brandId) return brand;
    }
    return null;
  }

  Future<void> _loadMenus(String brandId) async {
    setState(() {
      _loadingMenus = true;
      _menuError = null;
    });
    try {
      final repository = ref.read(menuRepositoryProvider);
      final menus = await repository.fetchMenus(brandId);
      Menu? selectedMenu;
      final incomingMenuName = widget.menuName?.trim();
      if (incomingMenuName != null && incomingMenuName.isNotEmpty) {
        for (final menu in menus) {
          if (menu.name == incomingMenuName) {
            selectedMenu = menu;
            break;
          }
        }
      }
      setState(() {
        _menus = menus;
        _selectedMenu = selectedMenu;
        _menuSearchController.text = selectedMenu?.name ?? '';
        _syncActiveDimensions(selectedMenu?.category);
      });
    } catch (_) {
      setState(() {
        _menuError = '메뉴 목록을 불러오지 못했어요.';
      });
    } finally {
      setState(() {
        _loadingMenus = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_selectedBrand == null) {
      setState(() {
        _submitError = '브랜드를 선택해주세요.';
      });
      return;
    }
    final selectedMenu = _selectedMenu;
    if (selectedMenu == null) {
      setState(() {
        _submitError = '메뉴를 선택해주세요.';
      });
      return;
    }
    final storeName = widget.storeName ?? '';
    if (storeName.isEmpty) {
      setState(() {
        _submitError = '치킨집을 선택해주세요.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      final repository = ref.read(reviewRepositoryProvider);
      final review = await repository.createReview(
        ReviewCreateRequest(
          storeName: storeName,
          address: widget.address ?? '',
          brandId: _selectedBrand!.id,
          menuName: selectedMenu.name,
          scores: _scores,
          overall: overall,
          comment: _commentController.text.trim(),
        ),
      );
      ref.invalidate(myReviewsProvider);
      ref.invalidate(rankingListProvider);
      if (!mounted) return;
      context.push('/review/${review.id}', extra: review);
    } catch (_) {
      setState(() {
        _submitError = '리뷰 제출에 실패했어요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  double _calculateOverall() {
    if (_scores.isEmpty) return 0;
    final total = _scores.values.reduce((a, b) => a + b);
    return total / _scores.length;
  }

  void _updateScore(String key, double value) {
    setState(() {
      _scores[key] = value;
      overall = _calculateOverall();
    });
  }

  void _syncActiveDimensions(String? category) {
    final next = dimensionsForCategory(category);
    _activeDimensions = next;
    _scores = {
      for (final key in next)
        key: _scores.containsKey(key) ? _scores[key]! : 3.0,
    };
    overall = _calculateOverall();
  }

  Future<bool> _confirmBrandChange(Brand nextBrand) async {
    final current = _lastConfirmedBrand;
    if (current == null || current.id == nextBrand.id) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('브랜드 변경'),
        content: Text(
          '${current.name}에서 ${nextBrand.name}로 변경할까요?\n메뉴 선택이 초기화될 수 있어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('변경'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  // 리뷰 작성 UI를 렌더링한다.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/ranking');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      color: AppColors.backgroundLight,
                    ),
                    child: const Icon(Icons.store, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storeName ?? '치킨집을 선택하세요',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.address != null &&
                            widget.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.address!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Brand>(
                          initialValue: _selectedBrand,
                          items: _brands
                              .map(
                                (brand) => DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand.name),
                                ),
                              )
                              .toList(),
                          onChanged:
                              widget.brandId != null &&
                                  widget.brandId!.isNotEmpty
                              ? null
                              : (brand) async {
                                  if (brand == null) return;
                                  if (!await _confirmBrandChange(brand)) {
                                    return;
                                  }
                                  setState(() {
                                    _selectedBrand = brand;
                                    _lastConfirmedBrand = brand;
                                    _selectedMenu = null;
                                    _menuSearchController.clear();
                                    _syncActiveDimensions(null);
                                  });
                                  _loadMenus(brand.id);
                                },
                          decoration: InputDecoration(
                            hintText: '브랜드 선택',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Autocomplete<Menu>(
                          optionsBuilder: (textEditingValue) {
                            final query = textEditingValue.text
                                .trim()
                                .toLowerCase();
                            if (query.isEmpty) return _menus;
                            return _menus.where(
                              (menu) => menu.name.toLowerCase().contains(query),
                            );
                          },
                          displayStringForOption: (menu) => menu.name,
                          onSelected: (menu) {
                            setState(() {
                              _selectedMenu = menu;
                              _syncActiveDimensions(menu.category);
                            });
                            _menuSearchController.text = menu.name;
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onSubmitted) {
                                if (controller.text !=
                                    _menuSearchController.text) {
                                  controller.value =
                                      _menuSearchController.value;
                                }
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: _loadingMenus
                                        ? '메뉴 불러오는 중...'
                                        : '메뉴 검색 후 선택',
                                    helperText: '목록에서 선택한 메뉴만 제출할 수 있어요.',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.cardBorder,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _menuSearchController.value =
                                        controller.value;
                                    final selected = _selectedMenu;
                                    if (selected != null &&
                                        selected.name != value) {
                                      setState(() {
                                        _selectedMenu = null;
                                        _syncActiveDimensions(null);
                                      });
                                    }
                                  },
                                  onSubmitted: (_) => onSubmitted(),
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            final list = options.toList(growable: false);
                            if (list.isEmpty) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 64,
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text('검색 결과가 없어요.'),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 64,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final menu = list[index];
                                      return ListTile(
                                        title: Text(menu.name),
                                        onTap: () => onSelected(menu),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_menuError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _menuError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    '경험을 평가해주세요',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._activeDimensions.expand(
                    (key) => [
                      RatingSlider(
                        label: ratingLabel(key),
                        value: _scores[key] ?? 3.0,
                        onChanged: (v) => _updateScore(key, v),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RatingSlider(
                    label: '총점',
                    value: overall,
                    isOverall: true,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '후기를 남겨주세요',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // OutlinedButton.icon(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.add_a_photo),
                  //   label: const Text('사진 추가'),
                  // ),
                  if (_submitError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _submitError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WriteChickenReviewButton(
                onPressed: _isSubmitting ? () {} : _submitReview,
                text: _isSubmitting ? '제출 중...' : '리뷰 제출',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
