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

1. Navigate into web directory
2. Copy .env.sample as .env and fill your NLS Api key.
3. Install dependencies:
   ```shell
   yarn
   ```
4. Run the development server in localhost:3000:
   ```shell
   yarn run start
   ```
