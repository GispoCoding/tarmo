"""move osm id generation to loader code

Revision ID: 106942da4dcc
Revises: ae776f283429
Create Date: 2022-03-29 17:52:28.916521

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "106942da4dcc"
down_revision = "8832d7a1b5fb"
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
