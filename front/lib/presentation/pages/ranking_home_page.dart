import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:front/presentation/providers/ranking_providers.dart';
import 'package:front/presentation/widgets/ranking_card.dart';
import 'package:front/presentation/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

// 브랜드-메뉴 랭킹 홈 화면이다.
class RankingHomePage extends ConsumerStatefulWidget {
  const RankingHomePage({super.key});

  @override
  ConsumerState<RankingHomePage> createState() => _RankingHomePageState();
}

class _RankingHomePageState extends ConsumerState<RankingHomePage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BrandMenuRanking> _filterRankings(List<BrandMenuRanking> items) {
    final query = _query.trim().toLowerCase();
    var filtered = items;
    if (_selectedCategory != '전체') {
      final category = _selectedCategory.toLowerCase();
      filtered = filtered
          .where((item) => item.category.toLowerCase() == category)
          .toList();
    }
    if (query.isEmpty) return filtered;
    return filtered.where((item) {
      final haystack = '${item.brandName} ${item.menuName}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  // 랭킹 리스트와 상단 UI를 구성한다.
  Widget build(BuildContext context) {
    final rankings = ref.watch(rankingListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _RankingHeader(
              controller: _searchController,
              selectedCategory: _selectedCategory,
              onSearchChanged: (value) => setState(() => _query = value),
              onCategorySelected: (value) =>
                  setState(() => _selectedCategory = value),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding,
                ),
                child: rankings.when(
                  data: (items) {
                    final rankIndexById = <String, int>{
                      for (var i = 0; i < items.length; i++) items[i].id: i,
                    };
                    final filtered = _filterRankings(items);
                    if (filtered.isEmpty) {
                      return const Center(child: Text('검색 결과가 없어요.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final rankIndex =
                            rankIndexById[filtered[index].id] ?? index;
                        return RankingCard(
                          ranking: filtered[index],
                          rankIndex: rankIndex,
                          onTap: () => context.push(
                            '/ranking/${filtered[index].id}',
                            extra: filtered[index],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: filtered.length,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      const Center(child: Text('랭킹 정보를 불러오지 못했어요.')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 랭킹 홈 상단 영역을 구성한다.
class _RankingHeader extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  const _RankingHeader({
    required this.controller,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  @override
  // 검색과 필터, 타이틀 영역을 구성한다.
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: AppStrings.searchHintRanking,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: '전체',
                  selected: selectedCategory == '전체',
                  onSelected: onCategorySelected,
                ),
                _FilterChip(
                  label: '후라이드',
                  selected: selectedCategory == '후라이드',
                  onSelected: onCategorySelected,
                ),
                _FilterChip(
                  label: '양념',
                  selected: selectedCategory == '양념',
                  onSelected: onCategorySelected,
                ),
                _FilterChip(
                  label: '구이',
                  selected: selectedCategory == '구이',
                  onSelected: onCategorySelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Chicken Rankings',
            trailing: 'Updated Today',
          ),
        ],
      ),
    );
  }
}

// 랭킹 상단 필터 칩을 표현한다.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    this.selected = false,
    required this.onSelected,
  });

  @override
  // 선택 가능한 필터 칩을 렌더링한다.
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onSelected(label),
        showCheckmark: false,
        checkmarkColor: Colors.transparent,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.cardBorder,
        ),
        label: SizedBox(
          width: 56,
          height: 24,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
