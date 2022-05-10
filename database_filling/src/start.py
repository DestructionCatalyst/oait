from os import getenv
import pymysql.cursors
from random import randint, choice
import requests
from datetime import datetime, timedelta

from fakes import fake, fake_en
from objects import Developer, Review, User, CaseTool


def test_connection(cursor):
    sql = "SELECT 1"
    cursor.execute(sql)
    result = cursor.fetchall()
    assert result == [{"1": 1}]


def table_empty(cursor, table_name):
    sql = "SELECT count(*) AS n FROM %s" % table_name
    cursor.execute(sql)
    result = cursor.fetchall()
    return result[0]['n'] == 0


def countries_list():
    countries_response = requests.get("https://namaztimes.kz/ru/api/country")
    countries_response.raise_for_status()
    countries_json = countries_response.json()
    return sorted([
        country.strip()
        for country in countries_json.values()
    ])

def generate_objects(obj_type, count):
    objects = []
    for i in range(count):
        objects.append(obj_type())
    return [obj.to_tuple() for obj in objects]


if __name__ == "__main__":
    print(Developer().to_tuple())
    print(User().to_tuple())
    print(CaseTool().to_tuple())
    print(Review(0, 0, 3).to_tuple())
    


    # Connect to the database
    connection = pymysql.connect(host=getenv('MYSQL_HOST'),
                                 user=getenv('MYSQL_USER'),
                                 password=getenv('MYSQL_PASSWORD'),
                                 database=getenv('MYSQL_DB'),
                                 charset='utf8mb4',
                                 cursorclass=pymysql.cursors.DictCursor)

    with connection:
        with connection.cursor() as cursor:
            test_connection(cursor)
            if table_empty(cursor, "Role"):
                sql = "INSERT INTO Role (name) VALUES (%s)"
                cursor.executemany(
                    sql, ['Пользователь', 'Разработчик', 'Администратор'])
            if table_empty(cursor, "Platform"):
                sql = "INSERT INTO Platform (name) VALUES (%s)"
                cursor.executemany(
                    sql, ['Windows', 'Mac OS', 'Linux', 'Web', 'Android', 'iOS'])
            if table_empty(cursor, "Country"):
                sql = "INSERT INTO Country (name) VALUES (%s)"
                cursor.executemany(sql, countries_list())
            if table_empty(cursor, "Type"):
                sql = "INSERT INTO Type (name, description) VALUES (%s, %s)"
                types = ['Средство анализа', 'Средство проектирования', 
                        'Средство разработки', 'Средство реинжиниринга', 
                        'Средство планирования и управления',
                        'Средство тестирования', 'Средство документирования']
                cursor.executemany(sql,
                    [(case_type, fake.text()) for case_type in types]
                )
            if table_empty(cursor, "Developer"):
                sql = "INSERT INTO Developer (name, webpage, country_id) VALUES (%s, %s, %s)"
                cursor.executemany(sql, generate_objects(Developer, 100)) 
            if table_empty(cursor, "MyUser"):
                sql = "INSERT INTO MyUser (email, username, password, last_login_date, " + \
                    "role_id, developer_id) VALUES (%s, %s, %s, %s, %s, %s)"
                cursor.executemany(sql, generate_objects(User, 2000)) 
            if table_empty(cursor, "CASE_tool"):
                sql = "INSERT INTO CASE_tool (name, description, type_id, developer_id, " + \
                    "release_date, last_update_date, price, purchase_url, source_code_url) " +\
                        "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
                cursor.executemany(sql, generate_objects(CaseTool, 250))
            if table_empty(cursor, "CASE_tools_platforms"):
                sql = "INSERT INTO CASE_tools_platforms (case_tool_id, platform_id) " +\
                        "VALUES (%s, %s)"
                links = set()
                for case_tool_id in range(1, 251):
                    if randint(0, 1):
                        # Single platform
                        links.add((case_tool_id, randint(1, 6)))
                    else:
                        # Cross-platfrom
                        for i in range(randint(1, 5)):
                            links.add((case_tool_id, randint(1, 6)))
                cursor.executemany(sql, list(links)) 
            if table_empty(cursor, "Feature"):
                sql = "INSERT INTO Feature (name, description) VALUES (%s, %s)"
                cursor.executemany(sql,
                    [(fake_en.slug(), fake.text()) for i in range(25)]
                )
            if table_empty(cursor, "CASE_tools_features"):
                sql = "INSERT INTO CASE_tools_features (case_tool_id, feature_id) VALUES (%s, %s)"
                links = set()
                for case_tool_id in range(1, 251):
                    for i in range(randint(1, 5)):
                        links.add((case_tool_id, randint(1, 6)))
                cursor.executemany(sql, list(links))
            if table_empty(cursor, "Review"):
                sql = "INSERT INTO Review (case_tool_id, user_id, publication_date, " + \
                    "review_text, rating) VALUES (%s, %s, %s, %s, %s)"
                reviews = []
                for case_tool_id in range(1, 251):
                    avg_rating = randint(2, 4)
                    for i in range(randint(0, 30)):
                        reviews.append(
                            Review(case_tool_id, randint(1, 2000), avg_rating).to_tuple())
                # Spammers
                for user_id in [randint(1, 2000) for i in range(10)]:
                    avg_rating = choice([1, 5])
                    for i in range(randint(20, 30)): 
                        reviews.append(
                            Review(randint(1, 250), user_id, avg_rating, recent=True).to_tuple())
                cursor.executemany(sql, reviews) 
                
        connection.commit()
