import html
import re

from chickenmap.repositories import place_search_repository


# 네이버 지역 검색 비즈니스 로직 계층이다.


_TAG_RE = re.compile(r"<[^>]+>")


def _clean_title(raw: str) -> str:
    # HTML 태그를 제거하고 엔티티를 해제한다.
    return html.unescape(_TAG_RE.sub("", raw)).strip()


def search_places(query: str, display: int = 5) -> list[dict]:
    # 검색 결과를 앱 스키마에 맞게 정제한다.
    payload = place_search_repository.search_places(query=query, display=display)
    items = payload.get("items", [])

    results = []
    for item in items:
        results.append(
            {
                "name": _clean_title(item.get("title", "")),
                "address": item.get("address", ""),
                "roadAddress": item.get("roadAddress", ""),
                "category": item.get("category", ""),
                "phone": item.get("telephone", ""),
                "link": item.get("link", ""),
                "mapx": int(item.get("mapx", 0) or 0),
                "mapy": int(item.get("mapy", 0) or 0),
            }
        )
    return results
