""" define nox sessions for running tests and checks """
# pylint: disable=missing-function-docstring

import glob
import os

import nox

PY_VERSION = "3.10"


def get_base_images(file_name):
    """would be cleaner to use yaml.load here, but want to avoid the dependency"""
    out = []
    with open(file_name, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip() == "image:":
                break
        for line in f:
            if line.strip().startswith('- '):
                out.append(line.strip()[2:])
            else:
                break
    return out


BASE_IMAGES = get_base_images('.github/workflows/push_latest.yml')

PYLINT_DEPS = [
    "pylint==2.12.2",
    "nox==2022.1.7",
    "pytest==7.0.0",  # so "import pytest" doesn't get reported
]

FLAKE8_DEPS = [
    "flake8==4.0.1",
    "flake8-bugbear==22.1.11",
    "flake8-builtins==1.5.3",
    "flake8-comprehensions==3.8.0",
]

PYTEST_DEPS = [
    "pytest==7.0.0",
    "pytest-mock==3.7.0",
    "toml==0.10.2",
]

MYPY_DEPS = [
    "mypy==0.931",
    "types-requests",
]

py_files = set(glob.glob("*.py") + glob.glob("test/*.py")) - {"__init__.py"}
cwd = os.getcwd()


@nox.session(python=PY_VERSION)
@nox.parametrize("base_image", BASE_IMAGES)
def tests(session, base_image):
    """Tests generation and use of docker images"""
    session.run(os.path.join(cwd, "test_with_base_image.sh"), f"{base_image}", external=True)


# All sessions defined below here are for testing/linting python code


@nox.session(python=PY_VERSION)
def pylint(session):
    session.install("-r", "requirements.txt", *PYLINT_DEPS)
    session.run("pylint", *py_files)


@nox.session(python=PY_VERSION)
def flake8(session):
    session.install(*FLAKE8_DEPS)
    session.run("flake8", *py_files)


@nox.session(python=PY_VERSION)
def mypy(session):
    session.install("-r", "requirements.txt", *MYPY_DEPS)
    session.run("mypy", *py_files)


@nox.session(python=PY_VERSION)
def black(session):
    session.install("black")
    session.run("black", "--check", "--diff", "--color", *py_files)


@nox.session(python=PY_VERSION)
def blacken(session):
    """this modifies the files to meet black's requirements"""
    session.install("black")
    session.run("black", *py_files)


@nox.session(python=PY_VERSION)
def pytest(session):
    """tests python code, mainly check_version.py"""
    session.install("-r", "requirements.txt", *PYTEST_DEPS)
    session.run("pytest", *session.posargs, "test")
