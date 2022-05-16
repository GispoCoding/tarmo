"""fix rkykohteet primary key name when migrating

Revision ID: fc36bf6bd3ff
Revises: 04aeb1302604
Create Date: 2022-05-16 16:22:25.153917

"""
import os

from alembic import op

here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = "fc36bf6bd3ff"
down_revision = "04aeb1302604"
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
