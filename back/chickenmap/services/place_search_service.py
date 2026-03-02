import html
import re

from chickenmap.repositories import place_search_repository


# 네이버 지역 검색 비즈니스 로직 계층이다.


_TAG_RE = re.compile(r"<[^>]+>")
_ALLOWED_CATEGORIES = {
    "음식점>치킨,닭강정",
    "한식>닭요리",
    "양식>햄버거",
    "술집>맥주,호프",
    "술집>요리주점",
}


def _clean_title(raw: str) -> str:
    # HTML 태그를 제거하고 엔티티를 해제한다.
    return html.unescape(_TAG_RE.sub("", raw)).strip()


def _is_allowed_category(category: str) -> bool:
    # 지정한 카테고리만 통과시킨다.
    return (category or "").strip() in _ALLOWED_CATEGORIES


def search_places(query: str, display: int = 5) -> list[dict]:
    # 검색 결과를 앱 스키마에 맞게 정제한다.
    payload = place_search_repository.search_places(query=query, display=display)
    items = payload.get("items", [])

    results = []
    for item in items:
        name = _clean_title(item.get("title", ""))
        category = item.get("category", "")
        if not _is_allowed_category(category):
            continue
        results.append(
            {
                "name": name,
                "address": item.get("address", ""),
                "roadAddress": item.get("roadAddress", ""),
                "category": category,
                "phone": item.get("telephone", ""),
                "link": item.get("link", ""),
                "mapx": int(item.get("mapx", 0) or 0),
                "mapy": int(item.get("mapy", 0) or 0),
            }
        )
    return results
