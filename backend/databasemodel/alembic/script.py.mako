"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
import os

from alembic import op
${imports if imports else ""}
here = os.path.dirname(os.path.realpath(__file__))

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}

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
