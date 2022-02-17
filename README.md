# tarmo

![](https://github.com/GispoCoding/tarmo/workflows/Build/badge.svg)
![](https://github.com/GispoCoding/tarmo/workflows/CI/badge.svg)
![](https://github.com/GispoCoding/tarmo/workflows/Deploy/badge.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Tarmo - Tampere Mobilemap

## Development

0. Install Docker based on [your platform's instructions](https://docs.docker.com/get-started/#download-and-install-docker).
1. Create a Python virtual environment and activate it.
2. `pip install pip-tools`
3. `pip-sync requirements-dev.txt`
4. `pre-commit install`

### Frontend

Use Node>=v16.
See [instructions](https://www.maanmittauslaitos.fi/rajapinnat/api-avaimen-ohje)
for acquiring an NLS API key (in Finnish).

1. Build and start the development containers with `docker-compose -f docker-compose.dev.yml up -d`
2. Populate the database by running `make test-create-db` and `make test-lipas`
3. Navigate into the `web` directory.
4. Copy `.env.sample` as `.env` and fill your NLS API key.
5. Install dependencies:
   ```shell
   yarn
   ```
6. Run the development server in localhost:3000:
   ```shell
   yarn run start
   ```

### Backend

1. Install also main requirements to the same python virtual environment:
   1. `pip-sync requirements.txt requirements-dev.txt`
   2. `pre-commit install`
2. Build and start the development containers with `docker-compose -f docker-compose.dev.yml up -d`
3. Edit the lambda [functions](./infra/functions) and restart the according container to see the changes.

If test using pytest-docker get stuck, you can remove the dangling containers with:

```shell
docker ps --format '{{.Names}}' |grep pytest | awk '{print $1}' | xargs -I {} docker stop {}
docker ps --format '{{.Names}}' |grep pytest | awk '{print $1}' | xargs -I {} docker rm {}
docker network ls --format {{.Name}} |grep pytest | awk '{print $1}' | xargs -I {} docker network rm {}
```

### Data model and database migrations

1. Make sure your backend requirements are installed: `pip-sync requirements.txt requirements-dev.txt`.
2. Add your changes to the [model sql](./backend/databasemodel/model.sql).
3. Create a new database revision with `make revision name="describe your changes"`. This creates a new random id (`uuid`) for your migration, and two things in the [alembic versions dir](./backend/databasemodel/alembic/versions):
   1. New revision file `uuid_your_message.py`,
   2. New revision sql directory `uuid`.
4. Add the needed difference SQL (generated e.g. manually or with pgdiff) as `upgrade.sql` inside the new `uuid` directory.
5. _Optionally_, if there is a need to be able to revert the changes, you can also add `downgrade.sql` in the same directory.
6. Commit the `uuid_your_message.py` file and `uuid` directory contents to Github.
7. If you want to migrate your local development database to the new revision, run `make test-migrate-db`.
