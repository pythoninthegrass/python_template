#!/usr/bin/env python3

# SOURCE: https://towardsdatascience.com/generating-random-data-into-a-database-using-python-fd2f7d54024e

import os
import psycopg2 as pg
import pandas as pd
from faker import Faker
from collections import defaultdict
from sqlalchemy import create_engine

db_name = os.getenv("DATABASE_NAME")
db_host = os.getenv("DATABASE_URL")
db_user = os.getenv("DATABASE_USER")
db_pass = os.getenv("DATABASE_PASSWORD")
db_port = os.getenv("DATABASE_PORT")

conn = pg.connect(database=db_name, host=db_host, user=db_user, password=db_pass, port=db_port)

# generate fake data
fake = Faker()
fake_data = defaultdict(list)

for _ in range(1000):
    fake_data["first_name"].append(fake.first_name())
    fake_data["last_name"].append(fake.last_name())
    fake_data["occupation"].append(fake.job())
    fake_data["dob"].append(fake.date_of_birth())
    fake_data["country"].append(fake.country())

# create dataframe
df_fake_data = pd.DataFrame(fake_data)

# create testdb database
engine = create_engine(f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}", echo=False)

# insert data into testdb database
df_fake_data.to_sql("testdb", engine, if_exists="replace", index=False)

# read data from testdb database
df_fake_data = pd.read_sql("SELECT * FROM testdb", engine)


def main():
    print(df_fake_data.head())


if __name__ == "__main__":
    main()
