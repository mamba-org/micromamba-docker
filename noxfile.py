""" define nox sessions """
import os

import nox

cwd = os.getcwd()


@nox.session
@nox.parametrize(
        'base_image',
        [
            'debian:bullseye-slim',
        ]
)
def tests(session, base_image):
    session.run(
            os.path.join(cwd, "test_with_base_image.sh"),
            f"{base_image}",
            external=True
    )
