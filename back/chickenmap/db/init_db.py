from datetime import datetime, timedelta
import uuid
from sqlalchemy import select
from sqlalchemy.orm import Session

from chickenmap.db.session import Base, engine
from chickenmap.models.entities import (
    Brand,
    Menu,
    Store,
    BrandMenuAggregate,
    StoreAggregate,
    Review,
)


# DB 초기화 및 목업 시드를 수행하는 모듈이다.


def init_db():
    # 테이블 생성 및 초기 데이터를 삽입한다.
    Base.metadata.create_all(bind=engine)
    with Session(engine) as db:
        seed_if_empty(db)


def seed_if_empty(db: Session):
    # 기준 데이터(브랜드/메뉴)는 없는 항목만 추가한다.
    # 샘플 지점/집계/리뷰는 기존 데이터가 없을 때만 삽입한다.

    brands = [
        Brand(
            id="brand-bbq",
            name="BBQ",
            logo_url="https://lh3.googleusercontent.com/aida-public/AB6AXuBm0bsKt3eeVGTfif4RUC_jbzMu3Q1sSDJQR_6HGfBPCmr0tm7C2x5pnZofeHeH8-BLGs5vpsvj9AbK4ly09yPDhCHAb5_bN4gvIYrbSFoKOxZSxjnB2-8DbNy_Xa6NK0FyMLwrE11wnQR1MwUePJvyIYvAYs08QfkiFCDJB4TJxB8DtL9ipETT73Nz81Xq7HlfIRsVZTb0kC-ZKxqr__93UfbFOnaXS9RBOdtssynznB4EqP7-b59OpCHyLoPBfoL-VMv3GqvZ3s4g",
        ),
        Brand(
            id="brand-bhc",
            name="BHC",
            logo_url="https://lh3.googleusercontent.com/aida-public/AB6AXuB--TzmdRa1Qk4TLud9vdw3ttfoNDA9jvmqrRpZXMl-M0mBqUfhmK6oBUSJpnCTtUPXv7WZ2BdqhbKOiygM8XLK3yrh-Z4uSEs_32zrUiY5HiEJkV3gjrqnP4YC7PW-27BnB04EDputzwhqqZNU-DySujvbVtNEWIYiCStiqqrHAiA8PPGCO7oVlXcoWouI8GZKZxAwcKO-MkM2mtWE30IlddqmQPZ4lsrodTZns7v2g7DhxtYJtJXkb9mqdseRu_8bgJtm1GGsShUr",
        ),
        Brand(
            id="brand-kyochon",
            name="교촌",
            logo_url="https://lh3.googleusercontent.com/aida-public/AB6AXuBUSMKs4gekdXjZzAzJqvZ9uyDG474nIQ2TK--TwGGWuig7P8a9nCjsX7BIDQaDkwrxlBjjxqpWMqGI8Dy83umlmAjIfAJMGc-TqN0Qx_st--DtzKGlukUYJKInbIpBOHLyAIZ79Ag8LFUbuEjeVP3aD51E8R0_VPDfRBDZpJ6lNUwWacrcpFAzjlQ-g-wUv_v3XbOwj7R7wGcTNyexV0Wmeri6Bjq_xzX1GffPjNc7EcSe2nfS9POGiA8lXkNQH3O78Cpj_u9Qrucq",
        ),
        Brand(id="brand-goobne", name="굽네치킨", logo_url=""),
        Brand(id="brand-nene", name="네네치킨", logo_url=""),
        Brand(id="brand-cheogatjib", name="처갓집양념치킨", logo_url=""),
        Brand(id="brand-puradak", name="푸라닭", logo_url=""),
        Brand(id="brand-60gye", name="60계치킨", logo_url=""),
        Brand(id="brand-norang", name="노랑통닭", logo_url=""),
        Brand(id="brand-jadam", name="자담치킨", logo_url=""),
        Brand(id="brand-pericana", name="페리카나", logo_url=""),
        Brand(id="brand-toreore", name="또래오래", logo_url=""),
        Brand(id="brand-hosigi", name="호식이두마리치킨", logo_url=""),
        Brand(id="brand-mexicana", name="멕시카나", logo_url=""),
        Brand(id="brand-kkanbu", name="깐부치킨", logo_url=""),
        Brand(id="brand-kfc", name="KFC", logo_url=""),
        Brand(id="brand-gamtangyesucbulcikin", name="감탄계숯불치킨", logo_url=""),
        Brand(id="brand-gastwiginhuraideu", name="갓튀긴후라이드", logo_url=""),
        Brand(id="brand-gudorotongdalg", name="구도로통닭", logo_url=""),
        Brand(id="brand-gugminmaneulcikin", name="국민마늘치킨", logo_url=""),
        Brand(id="brand-geumdongidumaricikin", name="금동이두마리치킨", logo_url=""),
        Brand(id="brand-gimsasgastongdalg", name="김삿갓통닭", logo_url=""),
        Brand(id="brand-gimsunrye-sunsalcikingangjeong", name="김순례 순살치킨강정", logo_url=""),
        Brand(id="brand-gimjonggusigmascikin-jeongibabekyu-yesnaltongdalg", name="김종구식맛치킨· 전기바베큐 옛날통닭", logo_url=""),
        Brand(id="brand-gimjongyongnurungjitongdalg", name="김종용누룽지통닭", logo_url=""),
        Brand(id="brand-ggeoguricikin", name="꺼구리치킨", logo_url=""),
        Brand(id="brand-ggubeuraggosucbuldumaricikin", name="꾸브라꼬숯불두마리치킨", logo_url=""),
        Brand(id="brand-naega-joseonyi-cikinigo-maegjuda", name="내가 조선의 치킨이고 맥주다", logo_url=""),
        Brand(id="brand-nugunaholddagbanhandalg", name="누구나홀딱반한닭", logo_url=""),
        Brand(id="brand-dasarang", name="다사랑", logo_url=""),
        Brand(id="brand-dalgjangsuhuraideuhe", name="닭장수후라이드和", logo_url=""),
        Brand(id="brand-didicikin", name="디디치킨", logo_url=""),
        Brand(id="brand-ddangddangcikin", name="땅땅치킨", logo_url=""),
        Brand(id="brand-ddobongitongdalg", name="또봉이통닭", logo_url=""),
        Brand(id="brand-mapacikin", name="마파치킨", logo_url=""),
        Brand(id="brand-mannyeondalggangjeong", name="만년닭강정", logo_url=""),
        Brand(id="brand-mamseuteoci", name="맘스터치", logo_url=""),
        Brand(id="brand-masdalgggo", name="맛닭꼬", logo_url=""),
        Brand(id="brand-megsikancikin", name="멕시칸치킨", logo_url=""),
        Brand(id="brand-mubwassnacondalg", name="무봤나촌닭", logo_url=""),
        Brand(id="brand-bareuncikin", name="바른치킨", logo_url=""),
        Brand(id="brand-babihu", name="바비후", logo_url=""),
        Brand(id="brand-bueocikin", name="부어치킨", logo_url=""),
        Brand(id="brand-buladeo-sucbulbabekyu", name="불아더 숯불바베큐", logo_url=""),
        Brand(id="brand-sujjimdalg", name="수찜닭", logo_url=""),
        Brand(id="brand-sunsalmangonggyeog", name="순살만공격", logo_url=""),
        Brand(id="brand-sunsucikin", name="순수치킨", logo_url=""),
        Brand(id="brand-ssangdungisucbuldumaricikin", name="쌍둥이숯불두마리치킨", logo_url=""),
        Brand(id="brand-ausdalg", name="아웃닭", logo_url=""),
        Brand(id="brand-ajukeo", name="아주커", logo_url=""),
        Brand(id="brand-egeupapa", name="에그파파", logo_url=""),
        Brand(id="brand-yeongdotongdalg", name="영도통닭", logo_url=""),
        Brand(id="brand-obeunmaru", name="오븐마루", logo_url=""),
        Brand(id="brand-obeunebbajindalg", name="오븐에빠진닭", logo_url=""),
        Brand(id="brand-wangangjeong", name="완강정", logo_url=""),
        Brand(id="brand-weldeomcikin", name="웰덤치킨", logo_url=""),
        Brand(id="brand-inadalggangjeong", name="이나닭강정", logo_url=""),
        Brand(id="brand-insaengcikin", name="인생치킨", logo_url=""),
        Brand(id="brand-jiraldalgbal", name="지랄닭발", logo_url=""),
        Brand(id="brand-jikoba", name="지코바", logo_url=""),
        Brand(id="brand-jingangjeong", name="진강정", logo_url=""),
        Brand(id="brand-jjangdalgcikin", name="짱닭치킨", logo_url=""),
        Brand(id="brand-jjiunginesucbuldumaricikin", name="찌웅이네숯불두마리치킨", logo_url=""),
        Brand(id="brand-ceogasjibpeulreoseukeijuncikin", name="처갓집플러스케이준치킨", logo_url=""),
        Brand(id="brand-ceongnyeoncikin", name="청년치킨", logo_url=""),
        Brand(id="brand-cireucireu", name="치르치르", logo_url=""),
        Brand(id="brand-cimaegking", name="치맥킹", logo_url=""),
        Brand(id="brand-cikinbaengi", name="치킨뱅이", logo_url=""),
        Brand(id="brand-cikinseonsaeng", name="치킨선생", logo_url=""),
        Brand(id="brand-cikinpameoseu", name="치킨파머스", logo_url=""),
        Brand(id="brand-cilcilkenteoki", name="칠칠켄터키", logo_url=""),
        Brand(id="brand-keunson1cikin2pija", name="큰손1치킨2피자", logo_url=""),
        Brand(id="brand-tugaijeu-two-guys", name="투가이즈(TWO GUYS)", logo_url=""),
        Brand(id="brand-peurangkinsucbulyangnyeomguicikin", name="프랑킨숯불양념구이치킨", logo_url=""),
        Brand(id="brand-heodaegu-daegutongdalg", name="허대구 대구통닭", logo_url=""),
        Brand(id="brand-hocikin", name="호치킨", logo_url=""),
        Brand(id="brand-hwaragbabekyucikin", name="화락바베큐치킨", logo_url=""),
        Brand(id="brand-hulralra", name="훌랄라", logo_url=""),

    ]

    default_menu_image = (
        "https://lh3.googleusercontent.com/aida-public/AB6AXuCtHrpl_kdq1gxVSLR2xSgNEmvlM4PR0EMePlGa98ORm0cYIuXKHgr5ah2fnTQw9vGrx3WUjZWbYgqF-9htTsb_TkYd6V5h8F_HEe3Ef6IdcEe4VMk09rZOesy4DUjG3KEfopa0LrjFh2KgJgV27w4zC996dMPodcIszG49jIIXE-tvc6BKRfLZDHARlrl9ayQno11dAdFFdqeGByFQHiPlw2Zy2XZucbsN0w9mDQ_rWSMMJUXmGoHj4paV1636i0m4i21dq7kSraPY"
    )

    menus = [
        Menu(
            id="menu-bbq-fried",
            brand_id="brand-bbq",
            name="황금올리브 후라이드",
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuCtHrpl_kdq1gxVSLR2xSgNEmvlM4PR0EMePlGa98ORm0cYIuXKHgr5ah2fnTQw9vGrx3WUjZWbYgqF-9htTsb_TkYd6V5h8F_HEe3Ef6IdcEe4VMk09rZOesy4DUjG3KEfopa0LrjFh2KgJgV27w4zC996dMPodcIszG49jIIXE-tvc6BKRfLZDHARlrl9ayQno11dAdFFdqeGByFQHiPlw2Zy2XZucbsN0w9mDQ_rWSMMJUXmGoHj4paV1636i0m4i21dq7kSraPY",
            category="후라이드",
        ),
        Menu(
            id="menu-bhc-bburinkle",
            brand_id="brand-bhc",
            name="뿌링클",
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuCtS7WTy2RwhOpC0qrl1BeoOUrMj9rgj5H39CzVFDi8ldRRx7Gc26KTYB6WlEEZk3YIS96CHYZdRMAlbhU772u-maFdVSYkPx-fpPrfV0p0Mes0P4kZxqWUc57XhQWqbRHStJsH_jIiwdISti6wCm4PEha1qi3yK5ZsaTsua8wYsb7g1N8N13DFKv-ToeSwljfwyvq1sl5M6jNf9qDu6BSevE-QzGImEoHItshw6N22ROC5tO5xJqpnz_Ax99gYGyj2X6eBFYR8BgaQ",
            category="양념",
        ),
        Menu(
            id="menu-kyochon-honey",
            brand_id="brand-kyochon",
            name="허니콤보",
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuDEPxO9awoBLaA-mkeylM1DNgb8uzGHvEG4WSp8oPjNji9BLGPkwQt6s50f2wEP8bZCQ72jMQXAnUjx5sUTwbZHjMOeGvZJH62PKbMqy-CcWoJL7cWa_iUPxWxkYtOEstWgOlJIYdVNQ2ZmHdnsUaUKN7h10m3nwskKNHLODohET5TtivzS7jy9wXjktAIED7bqRn5OOEu3mQ9hfskS8t6v1OSXzXqAbufeOyhCGZiU9kPoFBpbd0ARibN4HLaKwpU1kyUx2OaSqUuT",
            category="양념",
        ),
        Menu(
            id="menu-bbq-jamaica",
            brand_id="brand-bbq",
            name="자메이카 통다리",
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuCtHrpl_kdq1gxVSLR2xSgNEmvlM4PR0EMePlGa98ORm0cYIuXKHgr5ah2fnTQw9vGrx3WUjZWbYgqF-9htTsb_TkYd6V5h8F_HEe3Ef6IdcEe4VMk09rZOesy4DUjG3KEfopa0LrjFh2KgJgV27w4zC996dMPodcIszG49jIIXE-tvc6BKRfLZDHARlrl9ayQno11dAdFFdqeGByFQHiPlw2Zy2XZucbsN0w9mDQ_rWSMMJUXmGoHj4paV1636i0m4i21dq7kSraPY",
            category="구이",
        ),
        Menu(
            id="menu-kyochon-redcombo",
            brand_id="brand-kyochon",
            name="레드콤보",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-kyochon-original",
            brand_id="brand-kyochon",
            name="교촌오리지날",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-goobne-gochubasa",
            brand_id="brand-goobne",
            name="고추바사삭",
            image_url=default_menu_image,
            category="구이",
        ),
        Menu(
            id="menu-goobne-volcano",
            brand_id="brand-goobne",
            name="볼케이노",
            image_url=default_menu_image,
            category="구이",
        ),
        Menu(
            id="menu-goobne-original",
            brand_id="brand-goobne",
            name="오리지널",
            image_url=default_menu_image,
            category="구이",
        ),
        Menu(
            id="menu-nene-snowwing",
            brand_id="brand-nene",
            name="스노윙치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-nene-shockinghot",
            brand_id="brand-nene",
            name="쇼킹핫치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-nene-fried",
            brand_id="brand-nene",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-cheogatjib-supreme",
            brand_id="brand-cheogatjib",
            name="슈프림양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-cheogatjib-fried",
            brand_id="brand-cheogatjib",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-cheogatjib-seasoned",
            brand_id="brand-cheogatjib",
            name="양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-puradak-blackalio",
            brand_id="brand-puradak",
            name="블랙알리오",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-puradak-gotchumayo",
            brand_id="brand-puradak",
            name="고추마요치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-puradak-blackalio-boneless",
            brand_id="brand-puradak",
            name="순살블랙알리오",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-60gye-gochu",
            brand_id="brand-60gye",
            name="고추치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-60gye-tiger",
            brand_id="brand-60gye",
            name="호랑이치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-60gye-crunch",
            brand_id="brand-60gye",
            name="크크크치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-norang-fried",
            brand_id="brand-norang",
            name="노랑후라이드",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-norang-garlic",
            brand_id="brand-norang",
            name="알싸한마늘치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-norang-kkanpung",
            brand_id="brand-norang",
            name="깐풍치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-jadam-mapsyullang",
            brand_id="brand-jadam",
            name="맵슐랭치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-jadam-fried",
            brand_id="brand-jadam",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-jadam-seasoned",
            brand_id="brand-jadam",
            name="양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-pericana-seasoned",
            brand_id="brand-pericana",
            name="페리카나양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-pericana-fried",
            brand_id="brand-pericana",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-pericana-halfhalf",
            brand_id="brand-pericana",
            name="반반치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-toreore-garlic-hot-half",
            brand_id="brand-toreore",
            name="갈릭반핫양념반",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-toreore-o-gok",
            brand_id="brand-toreore",
            name="오곡후라이드",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-toreore-hot-seasoned",
            brand_id="brand-toreore",
            name="핫양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-hosigi-fried",
            brand_id="brand-hosigi",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-hosigi-seasoned",
            brand_id="brand-hosigi",
            name="양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-hosigi-soy",
            brand_id="brand-hosigi",
            name="간장치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-mexicana-fried",
            brand_id="brand-mexicana",
            name="후라이드치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-mexicana-seasoned",
            brand_id="brand-mexicana",
            name="양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-mexicana-spicy-seasoned",
            brand_id="brand-mexicana",
            name="매운양념치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-kkanbu-crispy",
            brand_id="brand-kkanbu",
            name="크리스피치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
        Menu(
            id="menu-kkanbu-garlic-soy",
            brand_id="brand-kkanbu",
            name="마늘간장치킨",
            image_url=default_menu_image,
            category="양념",
        ),
        Menu(
            id="menu-kkanbu-boneless",
            brand_id="brand-kkanbu",
            name="순살치킨",
            image_url=default_menu_image,
            category="후라이드",
        ),
    ]

    stores = [
        Store(
            id="store-1",
            brand_id="brand-bbq",
            name="BBQ 신내동점",
            address="서울 중랑구 신내로 12",
            distance_km=0.8,
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuA5cmmZoBqb8t3ZO7yn4tDph7Afg4aSTZqWCKgESnccgHJhx669Lnk9VuZBkhdZhGHM8h3QY--WdR9sSvO_Nk_o_SJTXx4o-3NZ-87FXmUmm2Hz5H2za-WdMFy8zc0sd5Brw6TNJ6g-tYzVvJ23qY4SPkDNlLO0A3J0CcCke6XgFk13uwdtzMiceUHTtgX2u2UOj6evZAG6hE_3PlvvRzyygYT9T2-XUeXuWnrRtIV3hQRb_7uSLpr74PU_-cOtzLgDmv4AHqYm3iNo",
            lat=37.6132,
            lng=127.0945,
        ),
        Store(
            id="store-2",
            brand_id="brand-kyochon",
            name="교촌 중화점",
            address="서울 중랑구 중화로 101",
            distance_km=1.2,
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuB1gg2lNpk4P7ztq-ka6X63NEEtvJmYnisFYu9Chi7uGAEtBHrhicZNgQME0s7RcWguaLLOjfYPWlEESrNqNyiSsVyDOtOwak6rYPgQdrWBcCxP45gk7tfsihBQbVTVDrnaCGzHcXzNoMDV1maltUSgsNZWwoOXfUDQAAH3kG7rISf0U6CFaDqm0QoXQJyKSnom-Fl-XuFdM5eQ94Cwil3eKr3FP6p1yGeckGWzASHTCpIqH8hZrYGskobqoFkW5-QIe_9esjn4i1AP",
            lat=37.5978,
            lng=127.0785,
        ),
        Store(
            id="store-3",
            brand_id="brand-bhc",
            name="BHC 망우점",
            address="서울 중랑구 망우로 45",
            distance_km=1.9,
            image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuAow-nYLE0k-RrRFeq2b1rj8dHJ3kHorivP0rCLZMDNgGVfJn62iJzDncCQrngIOc8SuS1392d_Gx1PUEs2FwnnHzN94pG_EbS-uJSjN5UaiE8floBee14ubSYSBOUhRL0xcvavuDIgSz0rL2OKnB5wE4rHLxuyRwtN10LQL9OESLRr5SPGG9Z7H5_juqHUoXmAYawK_ZU8w4I7QGt7c-3WWuataX0Z8aRQHBygVlbEuS7pbROAJzy3jUU6NwjeiCLwXVyw3iV2FMXm",
            lat=37.5992,
            lng=127.0924,
        ),
    ]

    ranking_breakdown = dict(
        crispy=4.7,
        juicy=4.6,
        salty=4.2,
        oil=4.4,
        chicken_quality=4.8,
        fry_quality=4.7,
        portion=4.3,
        overall=4.8,
    )

    store_breakdown = dict(
        crispy=4.4,
        juicy=4.3,
        salty=4.1,
        oil=4.2,
        chicken_quality=4.5,
        fry_quality=4.4,
        portion=4.0,
        overall=4.5,
    )

    brand_menu_aggregates = [
        BrandMenuAggregate(
            id=str(uuid.uuid4()),
            brand_id="brand-bbq",
            menu_id="menu-bbq-fried",
            rating=4.9,
            review_count=2482,
            highlight_score_a=4.9,
            highlight_label_a="바삭함",
            highlight_score_b=4.7,
            highlight_label_b="육즙",
            image_url=menus[0].image_url,
            brand_logo_url=brands[0].logo_url,
            **ranking_breakdown,
        ),
        BrandMenuAggregate(
            id=str(uuid.uuid4()),
            brand_id="brand-bhc",
            menu_id="menu-bhc-bburinkle",
            rating=4.8,
            review_count=1905,
            highlight_score_a=4.8,
            highlight_label_a="매직파우더",
            highlight_score_b=4.9,
            highlight_label_b="풍미",
            image_url=menus[1].image_url,
            brand_logo_url=brands[1].logo_url,
            **ranking_breakdown,
        ),
        BrandMenuAggregate(
            id=str(uuid.uuid4()),
            brand_id="brand-kyochon",
            menu_id="menu-kyochon-honey",
            rating=4.7,
            review_count=3120,
            highlight_score_a=4.6,
            highlight_label_a="바삭함",
            highlight_score_b=4.8,
            highlight_label_b="단맛",
            image_url=menus[2].image_url,
            brand_logo_url=brands[2].logo_url,
            **ranking_breakdown,
        ),
    ]

    store_aggregates = [
        StoreAggregate(
            id="store-1",
            store_id="store-1",
            rating=4.5,
            review_count=1240,
            **store_breakdown,
        ),
        StoreAggregate(
            id="store-2",
            store_id="store-2",
            rating=4.2,
            review_count=840,
            **store_breakdown,
        ),
        StoreAggregate(
            id="store-3",
            store_id="store-3",
            rating=3.9,
            review_count=560,
            **store_breakdown,
        ),
    ]

    now = datetime.now()
    reviews = [
        Review(
            id="review-1",
            store_id="store-1",
            brand_id="brand-bbq",
            menu_id="menu-bbq-fried",
            crispy=4.7,
            juicy=4.6,
            salty=4.2,
            oil=4.4,
            chicken_quality=4.8,
            fry_quality=4.7,
            portion=4.3,
            overall=4.6,
            comment="바삭함이 오래가고 기름 냄새가 덜했어요.",
            created_at=now - timedelta(days=2),
        ),
        Review(
            id="review-2",
            store_id="store-1",
            brand_id="brand-bbq",
            menu_id="menu-bbq-jamaica",
            crispy=4.1,
            juicy=4.0,
            salty=3.9,
            oil=4.0,
            chicken_quality=4.2,
            fry_quality=4.1,
            portion=4.0,
            overall=4.2,
            comment="양은 좋았는데 살짝 짭짤했어요.",
            created_at=now - timedelta(days=5),
        ),
    ]

    existing_brand_ids = set(db.scalars(select(Brand.id)).all())
    existing_menu_ids = set(db.scalars(select(Menu.id)).all())
    existing_store = db.execute(select(Store.id)).first()
    existing_brand_aggregate = db.execute(select(BrandMenuAggregate.id)).first()
    existing_store_aggregate = db.execute(select(StoreAggregate.id)).first()
    existing_review = db.execute(select(Review.id)).first()

    db.add_all([brand for brand in brands if brand.id not in existing_brand_ids])
    db.add_all([menu for menu in menus if menu.id not in existing_menu_ids])

    if not existing_store:
        db.add_all(stores)
    if not existing_brand_aggregate:
        db.add_all(brand_menu_aggregates)
    if not existing_store_aggregate:
        db.add_all(store_aggregates)
    if not existing_review:
        db.add_all(reviews)
    db.commit()
