from sqlalchemy import select
from sqlalchemy.orm import Session

from chickenmap.models.entities import Review, Store, Brand, Menu


# 리뷰 관련 데이터 접근 계층이다.


def fetch_my_reviews(db: Session):
    # 내 리뷰 리스트를 위한 쿼리다. (현재는 전체 리뷰를 반환한다.)
    stmt = (
        select(Review, Store.name, Brand.name, Menu.name)
        .join(Store, Store.id == Review.store_id)
        .join(Brand, Brand.id == Review.brand_id)
        .join(Menu, Menu.id == Review.menu_id)
        .order_by(Review.created_at.desc())
    )
    return db.execute(stmt).all()


def fetch_review(db: Session, review_id: str):
    # 리뷰 상세를 조회한다.
    stmt = (
        select(Review, Store.name, Brand.name, Menu.name)
        .join(Store, Store.id == Review.store_id)
        .join(Brand, Brand.id == Review.brand_id)
        .join(Menu, Menu.id == Review.menu_id)
        .where(Review.id == review_id)
    )
    return db.execute(stmt).first()
