# plugins from .tool-versions (ccache cmake direnv emsdk git ninja pre-commit python)
# pip requirements.txt (sphinx coverxygen)
# clang doxygen gcc graphviz mull
# run pre-commit install
# hook asdf into shell
# run direnv allow

FROM menny/android_ndk:latest AS limes-dev

SHELL [ "/bin/bash", "-c" ]

RUN apt-get install --yes curl git doxygen graphviz

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3 \
	&& echo ". \"$HOME/.asdf/asdf.sh\"" > ~/.bashrc

# install from .tool-versions
COPY .tool-versions .
RUN /bin/bash $HOME/.asdf/asdf.sh install

# TODO: asdf doesn't seem to update PATH, it can't find python or direnv

RUN python -m pip install coverxygen

# export direnv env vars
COPY env/ .
COPY .envrc .
RUN direnv allow

# Android NDK
# create Android AVD device

# if Mac image, install iOS simulator SDKs and create devices

ENTRYPOINT [ "/bin/bash", "-c" ]
