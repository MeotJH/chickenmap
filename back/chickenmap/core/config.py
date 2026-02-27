from pathlib import Path
import os


# 앱 설정을 모아두는 모듈이다.

BACK_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BACK_DIR / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)


def _default_sqlite_url() -> str:
    # 로컬 SQLite 파일 경로를 SQLAlchemy URL로 변환한다.
    db_path = (DATA_DIR / "chickenmap.db").resolve().as_posix()
    return f"sqlite:///{db_path}"


DB_URL = os.getenv("CHICKENMAP_DB_URL", _default_sqlite_url())
