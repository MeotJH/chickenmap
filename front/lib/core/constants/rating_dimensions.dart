const Map<String, List<String>> categoryRatingDimensions = {
  '양념': [
    'sauce_balance',
    'sweet_spicy_balance',
    'sauce_coating',
    'crisp_retention',
    'juicy',
    'chicken_quality',
    'portion',
  ],
  '후라이드': [
    'crispy',
    'juicy',
    'salty',
    'oil',
    'chicken_quality',
    'fry_quality',
    'portion',
  ],
  '구이': [
    'smoky',
    'juicy',
    'seasoning_balance',
    'skin_texture',
    'grill_quality',
    'chicken_quality',
    'portion',
  ],
  '간장': [
    'soy_flavor',
    'sweet_salty_balance',
    'sauce_coating',
    'crisp_retention',
    'juicy',
    'chicken_quality',
    'portion',
  ],
  '마늘': [
    'garlic_flavor',
    'garlic_balance',
    'sauce_coating',
    'crisp_retention',
    'juicy',
    'chicken_quality',
    'portion',
  ],
  '시즈닝': [
    'seasoning_flavor',
    'seasoning_balance',
    'powder_coverage',
    'texture_balance',
    'crisp_retention',
    'chicken_quality',
    'portion',
  ],
  '파닭': [
    'scallion_freshness',
    'scallion_amount',
    'sauce_harmony',
    'crisp_retention',
    'juicy',
    'chicken_quality',
    'portion',
  ],
  '닭강정': [
    'sauce_balance',
    'coating_texture',
    'crisp_retention',
    'bite_size',
    'inner_moisture',
    'chicken_quality',
    'portion',
  ],
};

const String fallbackRatingCategory = '후라이드';

const Map<String, String> ratingDimensionLabels = {
  'sauce_balance': '소스 밸런스',
  'sweet_spicy_balance': '단짠/맵단 밸런스',
  'sauce_coating': '소스 코팅',
  'crisp_retention': '바삭함 유지',
  'juicy': '육즙',
  'chicken_quality': '닭 품질',
  'portion': '양',
  'crispy': '바삭함',
  'salty': '염도',
  'oil': '기름상태',
  'fry_quality': '튀김 완성도',
  'smoky': '훈연향',
  'seasoning_balance': '시즈닝 밸런스',
  'skin_texture': '껍질 식감',
  'grill_quality': '구이 완성도',
  'soy_flavor': '간장 풍미',
  'sweet_salty_balance': '단짠 밸런스',
  'garlic_flavor': '마늘 풍미',
  'garlic_balance': '마늘 밸런스',
  'seasoning_flavor': '시즈닝 풍미',
  'powder_coverage': '파우더 코팅',
  'texture_balance': '식감 밸런스',
  'scallion_freshness': '파 신선도',
  'scallion_amount': '파 양',
  'sauce_harmony': '소스 조화',
  'coating_texture': '코팅 식감',
  'bite_size': '한입 크기',
  'inner_moisture': '속 촉촉함',
};

String normalizeRatingCategory(String? category) {
  final value = (category ?? '').trim();
  if (categoryRatingDimensions.containsKey(value)) return value;
  return fallbackRatingCategory;
}

List<String> dimensionsForCategory(String? category) {
  return categoryRatingDimensions[normalizeRatingCategory(category)]!;
}

String ratingLabel(String key) {
  return ratingDimensionLabels[key] ?? key;
}
