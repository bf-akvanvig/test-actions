FROM debian:buster-slim
LABEL org.opencontainers.image.source https://github.com/bf-akvanvig/test-actions

ARG libvirtProviderDownload="https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz"
ARG version=0.6.2
ARG terraformDownload="https://releases.hashicorp.com/terraform/0.14.0/terraform_0.14.0_linux_amd64.zip"

WORKDIR /terraform

RUN apt-get update

# Installing terraform
ADD ${terraformDownload} /tmp/terraform.zip
RUN apt-get install unzip -y \
&& unzip -d /usr/local/bin /tmp/terraform.zip

# Installing libvirt, ssh & mkisofs
# mkisofs not available, genisoimage as replacement
#   https://github.com/dmacvicar/terraform-provider-libvirt/issues/465
RUN apt-get install qemu-kvm libvirt-daemon-system ssh genisoimage -y \
&& ln -s /usr/bin/genisoimage /usr/bin/mkisofs

# Fetching libvirt provider for terraform and unpacking to correct location
ADD ${libvirtProviderDownload} /tmp/terraform-provider-libvirt_v${version}.tar.gz
RUN tar xvf /tmp/terraform-provider-libvirt_v${version}.tar.gz \
&& mkdir -p ./plugins/registry.terraform.io/dmacvicar/libvirt/${version}/linux_amd64 \
&& mv terraform-provider-libvirt plugins/registry.terraform.io/dmacvicar/libvirt/$version/linux_amd64/

# Removing install files
RUN rm -rf /tmp/*

# Add ssh config
RUN mkdir ~/.ssh \
&& touch ~/.ssh/id_rsa \
&& chmod 600 ~/.ssh/id_rsa \
&& sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/' /etc/ssh/ssh_config \
&& sed -i 's=#   IdentityFile ~/.ssh/id_rsa=   IdentityFile /terraform/key/id_rsa=' /etc/ssh/ssh_config

# Adding provider to .terraformrc
ENV TF_CLI_CONFIG_FILE="/terraform/.terraformrc"
RUN echo "provider_installation {filesystem_mirror {path = \"$PWD/plugins/\",include = [\"registry.terraform.io/dmacvicar/libvirt\"]},direct {exclude = [\"registry.terraform.io/dmacvicar/libvirt\"]}}" > /terraform/.terraformrc

# Start container
CMD terraform version
