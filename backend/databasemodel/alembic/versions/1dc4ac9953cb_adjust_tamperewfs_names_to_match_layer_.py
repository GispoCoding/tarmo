"""adjust tamperewfs names to match layer names, add metadata

Revision ID: 1dc4ac9953cb
Revises: ca6838d8e8a5
Create Date: 2022-03-09 14:16:23.725596

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "1dc4ac9953cb"
down_revision = "ca6838d8e8a5"
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
