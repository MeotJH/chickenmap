from datetime import datetime
import uuid
import re
from difflib import SequenceMatcher
from sqlalchemy.orm import Session

from chickenmap.models.entities import Brand, Menu, Store, Review, BrandMenuAggregate, StoreAggregate
from chickenmap.repositories import review_repository
from chickenmap.services import geocode_service


# 리뷰 비즈니스 로직 계층이다.


def get_my_reviews(db: Session):
    # 내 리뷰 리스트를 반환한다.
    return review_repository.fetch_my_reviews(db)


def get_review(db: Session, review_id: str):
    # 리뷰 상세를 반환한다.
    return review_repository.fetch_review(db, review_id)


def create_review(db: Session, payload):
    # 리뷰를 생성하고 저장한다.
    brand = db.get(Brand, payload.brandId)
    if brand is None:
        raise ValueError("Brand not found")

    normalized_input_menu = _normalize_menu_name(payload.menuName)
    menu = _find_best_matching_menu(db, brand.id, payload.menuName)
    if menu is None:
        menu = Menu(
            id=f"menu-{uuid.uuid4().hex}",
            brand_id=brand.id,
            name=payload.menuName.strip(),
            image_url="",
            category=_classify_menu_category(normalized_input_menu),
        )
        db.add(menu)

    store = (
        db.query(Store)
        .filter(Store.brand_id == brand.id)
        .filter(Store.name == payload.storeName)
        .first()
    )
    if store is None:
        coords = geocode_service.geocode(payload.address)
        store = Store(
            id=f"store-{uuid.uuid4().hex}",
            brand_id=brand.id,
            name=payload.storeName,
            address=payload.address,
            distance_km=0.0,
            image_url="",
            lat=coords[0] if coords else 0.0,
            lng=coords[1] if coords else 0.0,
        )
        db.add(store)
    elif store.lat == 0.0 and store.lng == 0.0 and payload.address:
        coords = geocode_service.geocode(payload.address)
        if coords:
            store.lat, store.lng = coords

    review = Review(
        id=f"review-{uuid.uuid4().hex}",
        store_id=store.id,
        brand_id=brand.id,
        menu_id=menu.id,
        crispy=payload.crispy,
        juicy=payload.juicy,
        salty=payload.salty,
        oil=payload.oil,
        chicken_quality=payload.chickenQuality,
        fry_quality=payload.fryQuality,
        portion=payload.portion,
        overall=payload.overall,
        comment=payload.comment,
        created_at=datetime.now(),
    )
    db.add(review)
    _update_brand_menu_aggregate(db, brand_id=brand.id, menu=menu, payload=payload)
    _update_store_aggregate(db, store=store, payload=payload)

    db.commit()
    db.refresh(review)
    return review, store.name, brand.name, menu.name


def _update_brand_menu_aggregate(db: Session, brand_id: str, menu: Menu, payload):
    # 브랜드-메뉴 집계를 누적 업데이트한다.
    aggregate = (
        db.query(BrandMenuAggregate)
        .filter(BrandMenuAggregate.brand_id == brand_id)
        .filter(BrandMenuAggregate.menu_id == menu.id)
        .first()
    )
    if aggregate is None:
        highlights = _pick_top_highlights(
            crispy=payload.crispy,
            juicy=payload.juicy,
            salty=payload.salty,
            oil=payload.oil,
            chicken_quality=payload.chickenQuality,
            fry_quality=payload.fryQuality,
            portion=payload.portion,
        )
        aggregate = BrandMenuAggregate(
            id=f"rank-{uuid.uuid4().hex}",
            brand_id=brand_id,
            menu_id=menu.id,
            rating=payload.overall,
            review_count=1,
            highlight_score_a=highlights[0][1],
            highlight_label_a=highlights[0][0],
            highlight_score_b=highlights[1][1],
            highlight_label_b=highlights[1][0],
            image_url=menu.image_url,
            brand_logo_url="",
            crispy=payload.crispy,
            juicy=payload.juicy,
            salty=payload.salty,
            oil=payload.oil,
            chicken_quality=payload.chickenQuality,
            fry_quality=payload.fryQuality,
            portion=payload.portion,
            overall=payload.overall,
        )
        db.add(aggregate)
        return

    count = aggregate.review_count
    new_count = count + 1
    aggregate.crispy = (aggregate.crispy * count + payload.crispy) / new_count
    aggregate.juicy = (aggregate.juicy * count + payload.juicy) / new_count
    aggregate.salty = (aggregate.salty * count + payload.salty) / new_count
    aggregate.oil = (aggregate.oil * count + payload.oil) / new_count
    aggregate.chicken_quality = (aggregate.chicken_quality * count + payload.chickenQuality) / new_count
    aggregate.fry_quality = (aggregate.fry_quality * count + payload.fryQuality) / new_count
    aggregate.portion = (aggregate.portion * count + payload.portion) / new_count
    aggregate.overall = (aggregate.overall * count + payload.overall) / new_count
    aggregate.rating = aggregate.overall
    aggregate.review_count = new_count

    highlights = _pick_top_highlights(
        crispy=aggregate.crispy,
        juicy=aggregate.juicy,
        salty=aggregate.salty,
        oil=aggregate.oil,
        chicken_quality=aggregate.chicken_quality,
        fry_quality=aggregate.fry_quality,
        portion=aggregate.portion,
    )
    aggregate.highlight_label_a = highlights[0][0]
    aggregate.highlight_score_a = highlights[0][1]
    aggregate.highlight_label_b = highlights[1][0]
    aggregate.highlight_score_b = highlights[1][1]


def _update_store_aggregate(db: Session, store: Store, payload):
    # 지점 집계를 누적 업데이트한다.
    aggregate = (
        db.query(StoreAggregate)
        .filter(StoreAggregate.store_id == store.id)
        .first()
    )
    if aggregate is None:
        aggregate = StoreAggregate(
            id=store.id,
            store_id=store.id,
            rating=payload.overall,
            review_count=1,
            crispy=payload.crispy,
            juicy=payload.juicy,
            salty=payload.salty,
            oil=payload.oil,
            chicken_quality=payload.chickenQuality,
            fry_quality=payload.fryQuality,
            portion=payload.portion,
            overall=payload.overall,
        )
        db.add(aggregate)
        return

    count = aggregate.review_count
    new_count = count + 1
    aggregate.crispy = (aggregate.crispy * count + payload.crispy) / new_count
    aggregate.juicy = (aggregate.juicy * count + payload.juicy) / new_count
    aggregate.salty = (aggregate.salty * count + payload.salty) / new_count
    aggregate.oil = (aggregate.oil * count + payload.oil) / new_count
    aggregate.chicken_quality = (aggregate.chicken_quality * count + payload.chickenQuality) / new_count
    aggregate.fry_quality = (aggregate.fry_quality * count + payload.fryQuality) / new_count
    aggregate.portion = (aggregate.portion * count + payload.portion) / new_count
    aggregate.overall = (aggregate.overall * count + payload.overall) / new_count
    aggregate.rating = aggregate.overall
    aggregate.review_count = new_count


def _pick_top_highlights(
    crispy: float,
    juicy: float,
    salty: float,
    oil: float,
    chicken_quality: float,
    fry_quality: float,
    portion: float,
):
    # 가장 높은 점수 2개를 하이라이트로 고른다.
    metrics = [
        ("바삭함", crispy),
        ("육즙", juicy),
        ("염도", salty),
        ("기름상태", oil),
        ("닭품질", chicken_quality),
        ("튀김완성도", fry_quality),
        ("양", portion),
    ]
    metrics.sort(key=lambda item: item[1], reverse=True)
    return metrics[:2]


def _normalize_menu_name(name: str) -> str:
    # 비교용 정규화: 공백/특수문자 제거, 소문자 통일
    normalized = name.strip().lower()
    normalized = re.sub(r"\s+", "", normalized)
    normalized = re.sub(r"[^0-9a-z가-힣]", "", normalized)
    return normalized


def _find_best_matching_menu(db: Session, brand_id: str, raw_name: str) -> Menu | None:
    # 같은 브랜드 내에서 기존 메뉴명을 우선 매칭한다.
    menus = db.query(Menu).filter(Menu.brand_id == brand_id).all()
    if not menus:
        return None

    stripped = raw_name.strip()
    for existing in menus:
        if existing.name.strip() == stripped:
            return existing

    normalized_target = _normalize_menu_name(stripped)
    if not normalized_target:
        return None

    # 1) 정규화 문자열 완전일치(띄어쓰기/특수문자 차이 흡수)
    for existing in menus:
        if _normalize_menu_name(existing.name) == normalized_target:
            return existing

    # 2) 오타 보정(브랜드 내 가장 유사한 메뉴를 임계치 이상일 때 채택)
    best_menu: Menu | None = None
    best_score = 0.0
    for existing in menus:
        score = SequenceMatcher(
            a=normalized_target,
            b=_normalize_menu_name(existing.name),
        ).ratio()
        if score > best_score:
            best_score = score
            best_menu = existing

    if best_menu is not None and best_score >= 0.80:
        return best_menu
    return None


def _classify_menu_category(normalized_name: str) -> str:
    # 새 메뉴 생성 시 기본 카테고리를 이름 기반으로 분류한다.
    if "후라이드" in normalized_name:
        return "후라이드"
    if "양념" in normalized_name:
        return "양념"
    if "간장" in normalized_name or "소이" in normalized_name:
        return "양념"
    if "숯불" in normalized_name or "바베큐" in normalized_name or "구이" in normalized_name:
        return "구이"
    return "기타"
