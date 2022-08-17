"""add osm categories; add osm and rky alueet to all points

Revision ID: 7d8ba4b179f5
Revises: 7174bce9e6d1
Create Date: 2022-08-15 17:42:02.490518

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "7d8ba4b179f5"
down_revision = "7174bce9e6d1"
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
