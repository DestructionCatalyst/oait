from audioop import avg
from random import randint, choice
import requests
from datetime import datetime, timedelta

from fakes import fake, fake_en


class Developer:
    def __init__(self):
        country_rng = randint(0, 2)
        if country_rng == 0:
            # Russia 159
            self.name = fake.company()
            self.website = fake.url()
            self.country_id = 159
        elif country_rng == 1:
            # USA 162
            self.name = fake_en.company()
            self.website = fake_en.uri()
            self.country_id = 162
        else:
            # The rest
            self.name = fake_en.company()
            self.website = fake_en.uri()
            self.country_id = randint(1, 236)

    def to_tuple(self):
        return (
            self.name,
            self.website,
            self.country_id
        )


class User:
    def __init__(self):
        self.email = fake.ascii_free_email()
        self.username = fake.user_name()
        self.password = fake.sha256(raw_output=False)
        self.last_login_date = fake.date_time_between(
            datetime.now() - timedelta(days=365 * 3),
            datetime.now()
        )
        role_rng = randint(0, 2000)
        if role_rng < 1900:
            # User
            self.role_id = 1
            self.developer = None
        elif role_rng < 1990:
            # Developer
            self.role_id = 2
            self.developer = randint(1, 100)
        else:
            # Admin
            self.role_id = 3
            self.developer = None

    def to_tuple(self):
        return (
            self.email,
            self.username,
            self.password,
            self.last_login_date,
            self.role_id,
            self.developer
        )


class CaseTool:
    def __init__(self):
        self.name = fake.microservice()
        self.description = fake.text()
        self.type_id = randint(1, 7)
        self.developer_id = randint(1, 100)
        self.release_date = fake.date_time_between(
            datetime.now() - timedelta(days=365 * 20),
            datetime.now()
        )
        self.last_update_date = fake.date_time_between(
            self.release_date,
            datetime.now()
        )
        if randint(0, 1):
            self.price = 0
            if randint(0, 5) == 5:
                self.source_code_url = None
            else:
                self.source_code_url = choice(
                ["https://github.com/",
                "https://gitlab.com/",
                "https://bitbucket.org/"]
            ) + fake_en.user_name() + "/" + self.name
        else:
            self.price = randint(500, 100000)
            self.source_code_url = None
        self.purchase_url = fake_en.uri()
        
    def to_tuple(self):
        return (
            self.name,
            self.description,
            self.type_id,
            self.developer_id,
            self.release_date,
            self.last_update_date,
            self.price,
            self.purchase_url,
            self.source_code_url
        )


class Review:
    def __init__(self, case_tool_id, user_id, avg_rating, recent=False) -> None:
        self.case_tool_id = case_tool_id
        self.user_id = user_id
        if recent:
            self.publication_date = fake.date_time_between(
                datetime.now() - timedelta(days=3),
                datetime.now()
            )
        else:   
            self.publication_date = fake.date_time_between(
                datetime.now() - timedelta(days=365 * 2),
                datetime.now()
            )
        self.review_text = fake.text()
        self.rating = choice([1, 2, 3, 4, 5, avg_rating, avg_rating])	

    def to_tuple(self):
        return (
            self.case_tool_id,
            self.user_id,
            self.publication_date,
            self.review_text,
            self.rating
        )
