from sqlalchemy import create_engine, text

engine = create_engine("mysql+mysqlconnector://root:2005@localhost/retail_db")

with engine.connect() as conn:
    result = conn.execute(text("SELECT VERSION();"))
    print(result.fetchone())