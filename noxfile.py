""" define nox sessions for running tests and checks """
# pylint: disable=missing-function-docstring

import glob
from pathlib import Path

import nox

PY_VERSION = "3.10"


def get_base_images(file_name):
    """would be cleaner to use yaml.load here, but want to avoid the dependency"""
    out = []
    with open(file_name, "r", encoding="utf-8") as yaml_fh:
        for line in yaml_fh:
            if line.strip() == "image:":
                break
        for line in yaml_fh:
            if line.strip().startswith("- "):
                out.append(line.strip()[2:])
            else:
                break
    return out


def get_default_base_image(file_name):
    with open(file_name, "r", encoding="utf-8") as yaml_fh:
        for line in yaml_fh:
            bare_line = line.strip().replace('"', "'")
            if bare_line.startswith("DEFAULT_BASE_IMAGE:"):
                return bare_line.split("'")[1]
    raise ValueError("Did not find DEFAULT_BASE_IMAGE")


REPO_DIR = Path(__file__).resolve().parent
PUSH_WORKFLOW = REPO_DIR / ".github/workflows/push_latest.yml"
BASE_IMAGES = get_base_images(PUSH_WORKFLOW)
DEFAULT_BASE_IMAGE = get_default_base_image(PUSH_WORKFLOW)
assert DEFAULT_BASE_IMAGE in BASE_IMAGES

nox.options.sessions = [
    f"image_tests(base_image='{DEFAULT_BASE_IMAGE}')",
    "shellcheck",
    "pylint",
    "flake8",
    "mypy",
    "black",
    "pytest",
]

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
shell_scripts = set(glob.glob("*.sh") + glob.glob("test/*.bats"))


@nox.session(python=PY_VERSION)
@nox.parametrize("base_image", BASE_IMAGES)
def image_tests(session, base_image):
    """Tests generation and use of docker images"""
    session.run(REPO_DIR / "test_with_base_image.sh", f"{base_image}", external=True)


@nox.session(python=PY_VERSION)
def default_base_image_tests(session):
    """Tests generation and use of docker images using default base image"""
    image_tests(session, DEFAULT_BASE_IMAGE)


@nox.session(python=PY_VERSION)
def shellcheck(session):
    """lint all shell scripts with shellcheck"""
    inputs = ["-x"] + list(shell_scripts)
    try:
        session.run("shellcheck", *inputs, external=True)
    except FileNotFoundError:
        session.run(
            "docker",
            "run",
            "--rm",
            "-v",
            f"{REPO_DIR}:/mnt",
            "koalaman/shellcheck:stable",
            *inputs,
            external=True,
        )


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
