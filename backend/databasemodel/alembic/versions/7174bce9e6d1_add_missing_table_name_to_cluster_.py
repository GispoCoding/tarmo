"""add missing table name to cluster partition

Revision ID: 7174bce9e6d1
Revises: 3df1bb2d0c9b
Create Date: 2022-08-11 12:16:26.890675

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "7174bce9e6d1"
down_revision = "3df1bb2d0c9b"
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
