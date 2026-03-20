"""remove recycling

Revision ID: 6f5b710cf21f
Revises: 1db9f62f20fd
Create Date: 2026-03-20 19:45:06.165713

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "6f5b710cf21f"
down_revision = "1db9f62f20fd"
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
