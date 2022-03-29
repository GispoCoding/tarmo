"""add default values to existing rows

Revision ID: ae776f283429
Revises: 8832d7a1b5fb
Create Date: 2022-03-29 16:36:37.968146

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "ae776f283429"
down_revision = "106942da4dcc"
branch_labels = None
depends_on = None

revision_dir = f"{here}/{revision}"


# idea from https://github.com/tbobm/alembic-sequeled
def process_migration(script_name: str):
    filename = f"{revision_dir}/{script_name}.sql"

    query = "\n".join(open(filename))
    if len(query) > 0:
        op.execute(query)


def upgrade():
    process_migration("upgrade")


def downgrade():
    process_migration("downgrade")
