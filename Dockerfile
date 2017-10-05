FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade

# Install the following utilities (required by aosp build)
RUN apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev
RUN apt-get install -y gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev ia32-libs
RUN apt-get install -y x11proto-core-dev libx11-dev lib32readline-gplv2-dev lib32z-dev
RUN apt-get install -y libxml-simple-perl libc6-dev libgl1-mesa-dev mingw32 tofrodos
RUN apt-get install -y python-markdown libxml2-utils xsltproc

# Add "repo" tool (used by many Yocto-based projects)
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Install Jfrog cli utility to deploy artifacts
RUN cd /usr/bin; curl -fL https://getcli.jfrog.io | sh
RUN chmod 755 /usr/bin/jfrog

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Default sh to bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Disable Host Key verification.
RUN mkdir -p /home/build/.ssh
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/build/.ssh/config
RUN chown -R build:build /home/build/.ssh

USER build
WORKDIR /home/build
CMD "/bin/bash"
