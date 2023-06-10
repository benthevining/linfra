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

ENTRYPOINT [ "/bin/bash", "-c" ]
