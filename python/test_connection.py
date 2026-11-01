
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

load_dotenv()

required_vars = ["DB_USER", "DB_PASSWORD", "DB_HOST", "DB_NAME"]
missing = [var for var in required_vars if not os.getenv(var)]

if missing:
    raise ValueError(
        f"Missing environment variables in .env: {', '.join(missing)}"
    )

db_url = URL.create(
    drivername="mysql+mysqlconnector",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME")
)

engine = create_engine(db_url)

try:
    with engine.connect() as conn:
        result = conn.execute(text("SELECT VERSION();"))
        print("MySQL connection successful!")
        print("MySQL version:", result.fetchone()[0])

except Exception as e:
    print("MySQL connection failed:", e)

finally:
    engine.dispose()
