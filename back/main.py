from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from chickenmap.api.router import router as chickenmap_router
from chickenmap.db.init_db import init_db
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Qwen Text2Image API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET","OPTIONS","PATCH","DELETE","PUT"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    # 앱 시작 시 치킨맵 SQLite와 목업 데이터를 초기화한다.
    init_db()


# /api prefix 아래에 실제 라우트 등록
app.include_router(router=chickenmap_router)

# if __name__ == "__main__" and os.getenv("ENV") != "lambda":
#     import uvicorn
#     uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)
