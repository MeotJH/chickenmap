from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from chickenmap.db.session import get_db
from chickenmap.schemas.chickenmap import (
  BrandMenuRankingOut,
  BrandOut,
  MenuOut,
  RatingBreakdownOut,
  ReviewOut,
  ReviewCreateIn,
  StoreSummaryOut,
  PlaceSearchOut,
)
from chickenmap.services import (
    brand_menu_service,
    store_service,
    review_service,
    place_search_service,
    brand_service,
)


# 치킨맵 도메인 API 라우터다.

router = APIRouter(prefix="/api/chickenmap", tags=["chickenmap"])


@router.get("/rankings", response_model=list[BrandMenuRankingOut])
def list_rankings(db: Session = Depends(get_db)):
    # 브랜드-메뉴 랭킹 리스트를 반환한다.
    rows = brand_menu_service.get_rankings(db)
    return [
        BrandMenuRankingOut(
            id=aggregate.id,
            brandId=aggregate.brand_id,
            menuId=aggregate.menu_id,
            brandName=brand_name,
            menuName=menu_name,
            category=menu.category,
            rating=aggregate.rating,
            reviewCount=aggregate.review_count,
            highlightScoreA=aggregate.highlight_score_a,
            highlightLabelA=aggregate.highlight_label_a,
            highlightScoreB=aggregate.highlight_score_b,
            highlightLabelB=aggregate.highlight_label_b,
            imageUrl=aggregate.image_url,
            brandLogoUrl=aggregate.brand_logo_url,
        )
        for aggregate, brand_name, menu_name, menu in rows
    ]


@router.get("/rankings/{ranking_id}/breakdown", response_model=RatingBreakdownOut)
def get_ranking_breakdown(ranking_id: str, db: Session = Depends(get_db)):
    # 랭킹 상세 점수 분해 정보를 반환한다.
    aggregate = brand_menu_service.get_ranking_breakdown(db, ranking_id)
    if aggregate is None:
        raise HTTPException(status_code=404, detail="Ranking not found")

    return RatingBreakdownOut(
        crispy=aggregate.crispy,
        juicy=aggregate.juicy,
        salty=aggregate.salty,
        oil=aggregate.oil,
        chickenQuality=aggregate.chicken_quality,
        fryQuality=aggregate.fry_quality,
        portion=aggregate.portion,
        overall=aggregate.overall,
    )


@router.get("/rankings/{ranking_id}/reviews", response_model=list[ReviewOut])
def get_ranking_reviews(ranking_id: str, db: Session = Depends(get_db)):
    # 랭킹 상세 리뷰 리스트를 반환한다.
    rows = brand_menu_service.get_ranking_reviews(db, ranking_id)
    return [
        ReviewOut(
            id=review.id,
            storeName=store_name,
            brandName=brand_name,
            menuName=menu_name,
            crispy=review.crispy,
            juicy=review.juicy,
            salty=review.salty,
            oil=review.oil,
            chickenQuality=review.chicken_quality,
            fryQuality=review.fry_quality,
            portion=review.portion,
            overall=review.overall,
            comment=review.comment,
            createdAt=review.created_at,
        )
        for review, store_name, brand_name, menu_name in rows
    ]


@router.get("/stores", response_model=list[StoreSummaryOut])
def list_stores(db: Session = Depends(get_db)):
    # 지점 요약 리스트를 반환한다.
    rows = store_service.get_nearby_stores(db)
    return [
        StoreSummaryOut(
            id=store.id,
            name=store.name,
            brandName=brand_name,
            address=store.address,
            rating=aggregate.rating,
            reviewCount=aggregate.review_count,
            distanceKm=store.distance_km,
            imageUrl=store.image_url,
            lat=store.lat,
            lng=store.lng,
        )
        for store, aggregate, brand_name in rows
    ]


@router.get("/stores/{store_id}", response_model=StoreSummaryOut)
def get_store_detail(store_id: str, db: Session = Depends(get_db)):
    # 지점 상세 정보를 반환한다.
    row = store_service.get_store_detail(db, store_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Store not found")
    store, aggregate, brand_name = row
    return StoreSummaryOut(
        id=store.id,
        name=store.name,
        brandName=brand_name,
        address=store.address,
        rating=aggregate.rating,
        reviewCount=aggregate.review_count,
        distanceKm=store.distance_km,
        imageUrl=store.image_url,
        lat=store.lat,
        lng=store.lng,
    )


@router.get("/stores/{store_id}/breakdown", response_model=RatingBreakdownOut)
def get_store_breakdown(store_id: str, db: Session = Depends(get_db)):
    # 지점 점수 분해 정보를 반환한다.
    aggregate = store_service.get_store_breakdown(db, store_id)
    if aggregate is None:
        raise HTTPException(status_code=404, detail="Store not found")

    return RatingBreakdownOut(
        crispy=aggregate.crispy,
        juicy=aggregate.juicy,
        salty=aggregate.salty,
        oil=aggregate.oil,
        chickenQuality=aggregate.chicken_quality,
        fryQuality=aggregate.fry_quality,
        portion=aggregate.portion,
        overall=aggregate.overall,
    )


@router.get("/stores/{store_id}/reviews", response_model=list[ReviewOut])
def get_store_reviews(store_id: str, db: Session = Depends(get_db)):
    # 지점 리뷰 리스트를 반환한다.
    rows = store_service.get_store_reviews(db, store_id)
    return [
        ReviewOut(
            id=review.id,
            storeName=store_name,
            brandName=brand_name,
            menuName=menu_name,
            crispy=review.crispy,
            juicy=review.juicy,
            salty=review.salty,
            oil=review.oil,
            chickenQuality=review.chicken_quality,
            fryQuality=review.fry_quality,
            portion=review.portion,
            overall=review.overall,
            comment=review.comment,
            createdAt=review.created_at,
        )
        for review, store_name, brand_name, menu_name in rows
    ]


@router.get("/reviews/me", response_model=list[ReviewOut])
def get_my_reviews(db: Session = Depends(get_db)):
    # 내 리뷰 리스트를 반환한다.
    rows = review_service.get_my_reviews(db)
    return [
        ReviewOut(
            id=review.id,
            storeName=store_name,
            brandName=brand_name,
            menuName=menu_name,
            crispy=review.crispy,
            juicy=review.juicy,
            salty=review.salty,
            oil=review.oil,
            chickenQuality=review.chicken_quality,
            fryQuality=review.fry_quality,
            portion=review.portion,
            overall=review.overall,
            comment=review.comment,
            createdAt=review.created_at,
        )
        for review, store_name, brand_name, menu_name in rows
    ]


@router.get("/reviews/{review_id}", response_model=ReviewOut)
def get_review(review_id: str, db: Session = Depends(get_db)):
    # 리뷰 상세 정보를 반환한다.
    row = review_service.get_review(db, review_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Review not found")
    review, store_name, brand_name, menu_name = row
    return ReviewOut(
        id=review.id,
        storeName=store_name,
        brandName=brand_name,
        menuName=menu_name,
        crispy=review.crispy,
        juicy=review.juicy,
        salty=review.salty,
        oil=review.oil,
        chickenQuality=review.chicken_quality,
        fryQuality=review.fry_quality,
        portion=review.portion,
        overall=review.overall,
        comment=review.comment,
        createdAt=review.created_at,
    )


@router.post("/reviews", response_model=ReviewOut)
def create_review(payload: ReviewCreateIn, db: Session = Depends(get_db)):
    # 리뷰를 생성하고 반환한다.
    try:
        review, store_name, brand_name, menu_name = review_service.create_review(db, payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return ReviewOut(
        id=review.id,
        storeName=store_name,
        brandName=brand_name,
        menuName=menu_name,
        crispy=review.crispy,
        juicy=review.juicy,
        salty=review.salty,
        oil=review.oil,
        chickenQuality=review.chicken_quality,
        fryQuality=review.fry_quality,
        portion=review.portion,
        overall=review.overall,
        comment=review.comment,
        createdAt=review.created_at,
    )


@router.get("/places/search", response_model=list[PlaceSearchOut])
def search_places(query: str, display: int = 5):
    # 네이버 지역 검색 API를 통해 치킨집을 조회한다.
    return place_search_service.search_places(query=query, display=display)


@router.get("/brands", response_model=list[BrandOut])
def list_brands(db: Session = Depends(get_db)):
    # 브랜드 목록을 반환한다.
    brands = brand_service.get_brands(db)
    return [
        BrandOut(id=brand.id, name=brand.name, logoUrl=brand.logo_url)
        for brand in brands
    ]


@router.get("/brands/{brand_id}/menus", response_model=list[MenuOut])
def list_brand_menus(brand_id: str, query: str | None = None, db: Session = Depends(get_db)):
    # 브랜드별 메뉴 목록을 반환한다.
    menus = brand_menu_service.get_menus_by_brand(db, brand_id, query)
    return [
        MenuOut(
            id=menu.id,
            brandId=menu.brand_id,
            name=menu.name,
            imageUrl=menu.image_url,
            category=menu.category,
        )
        for menu in menus
    ]
