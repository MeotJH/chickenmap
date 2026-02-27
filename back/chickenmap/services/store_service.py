from sqlalchemy.orm import Session

from chickenmap.repositories import store_repository


# 지점 비즈니스 로직 계층이다.


def get_nearby_stores(db: Session):
    # 지도/리스트 화면용 지점 요약을 반환한다.
    return store_repository.fetch_nearby_stores(db)


def get_store_detail(db: Session, store_id: str):
    # 지점 상세 정보를 반환한다.
    return store_repository.fetch_store_detail(db, store_id)


def get_store_breakdown(db: Session, store_id: str):
    # 지점 점수 분해 정보를 반환한다.
    return store_repository.fetch_store_breakdown(db, store_id)


def get_store_reviews(db: Session, store_id: str):
    # 지점 리뷰 리스트를 반환한다.
    return store_repository.fetch_store_reviews(db, store_id)
