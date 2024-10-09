# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# Define build-time arguments for version control
ARG TERRAFORM_VERSION="1.5.5-1"
ARG TERRAGRUNT_VERSION="0.67.16"
ARG KUBECTL_VERSION="v1.30.5"
ARG GIT_USER_EMAIL="user@example.com"
ARG GIT_USER_NAME="user"


# Update the system and install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    git \
    zsh \
    openssh-client && \
    apt-get clean

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform=${TERRAFORM_VERSION}

# Install Terragrunt
RUN curl -Lo /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod +x /usr/local/bin/terragrunt

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install kubectl (ARM64)
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/arm64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Configure git
RUN git config --global user.email ${GIT_USER_EMAIL} && \
    git config --global user.name ${GIT_USER_NAME}

# Verify installations
RUN terraform --version && \
    terragrunt --version && \
    aws --version && \
    kubectl version --client --output=yaml && \
    git --version && \
    ssh -V

# Set the default working directory
WORKDIR /home/ubuntu/terraform

# Set Zsh as the default shell
SHELL ["/bin/zsh", "-c"]

# Default command
CMD ["zsh"]
