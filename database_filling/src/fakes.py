from faker import Faker
from faker.providers import internet, misc, date_time, company
import faker_microservice as microservice

fake = Faker('ru_RU')
fake_en = Faker()
for provider in [internet, misc, date_time, company, microservice]:
    fake.add_provider(provider.Provider)
    fake_en.add_provider(provider.Provider)
