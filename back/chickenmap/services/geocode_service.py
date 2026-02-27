from chickenmap.repositories import geocode_repository


# 지오코딩 비즈니스 로직 계층이다.


def geocode(address: str):
    # 주소를 좌표로 변환하고 (lat, lng)를 반환한다.
    payload = geocode_repository.geocode_address(address)
    addresses = payload.get("addresses", [])
    if not addresses:
        return None
    first = addresses[0]
    try:
        lat = float(first.get("y", 0.0))
        lng = float(first.get("x", 0.0))
    except (TypeError, ValueError):
        return None
    return lat, lng
