"""Initial database model

Revision ID: 53986072f514
Revises:
Create Date: 2022-02-08 18:30:17.637824

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "53986072f514"
down_revision = None
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
