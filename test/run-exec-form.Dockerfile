FROM micromamba:test
RUN micromamba install -y -n base -c conda-forge \
       python=3.9.1  && \
    micromamba clean --all --yes

RUN ["python", "-c", "import os; os.system('touch foobar')"]
