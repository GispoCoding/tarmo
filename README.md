# tarmo

![](https://github.com/GispoCoding/tarmo/workflows/Build/badge.svg)
![](https://github.com/GispoCoding/tarmo/workflows/CI/badge.svg)
![](https://github.com/GispoCoding/tarmo/workflows/Deploy/badge.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Tarmo - Tampere Mobilemap

## Development

1. Create a Python virtual environment and activate it.
2. `pip install pip-tools`
3. `pip-sync requirements-dev.txt`
4. `pre-commit install`

### Frontend

Use Node>=v16.

1. Build and start the development containers with `docker-compose -f docker-compose.dev.yml up -d`
2. Navigate into web directory
3. Copy .env.sample as .env and fill your NLS Api key.
4. Install dependencies:
   ```shell
   yarn
   ```
5. Run the development server in localhost:3000:
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
