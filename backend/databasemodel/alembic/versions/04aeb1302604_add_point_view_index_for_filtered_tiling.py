"""add point view index for filtered tiling

Revision ID: 04aeb1302604
Revises: 0e85feca844d
Create Date: 2022-05-16 14:09:36.058301

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "04aeb1302604"
down_revision = "0e85feca844d"
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
