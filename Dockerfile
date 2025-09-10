FROM ubuntu:22.04

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=e2r2fx
ARG NODE_MAJOR=18

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/${USERNAME}
ENV PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install base packages and Node.js (NodeSource)
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl git sudo gnupg build-essential python3 python3-pip python3-venv openssh-client unzip watchman\
  && echo 'e2r2fx ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/e2r2fx \
  && chmod 0440 /etc/sudoers.d/e2r2fx \
  && curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# Create user/group (no-op if already exists) and make project path
RUN groupadd -g ${GROUP_ID} -f ${USERNAME} \
  && id -u ${USERNAME} >/dev/null 2>&1 || useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USERNAME} || true \
  && mkdir -p /home/${USERNAME}/projects/zen-desktop \
  && mkdir -p /home/${USERNAME}/.npm /home/${USERNAME}/.cache/pip /home/${USERNAME}/.local \
  && chown -R ${USER_ID}:${GROUP_ID} /home/${USERNAME}

WORKDIR /home/${USERNAME}/projects/zen-desktop

# Install rustup/toolchain into the non-root user's home
# Run the rustup installer as the target user so it installs into /home/${USERNAME}/.cargo
RUN su - ${USERNAME} -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" \
 && /bin/bash -lc "HOME=/home/${USERNAME} /home/${USERNAME}/.cargo/bin/rustup default stable" \
 && /bin/bash -lc "HOME=/home/${USERNAME} /home/${USERNAME}/.cargo/bin/rustup component add rustfmt clippy" \
 && chown -R ${USER_ID}:${GROUP_ID} /home/${USERNAME}/.cargo /home/${USERNAME}/.rustup

# Default command is a sleep to keep container alive; compose overrides with tail -f /dev/null
CMD ["bash"]
