FROM debian:9

RUN apt-get update -q && \
  apt-get install -yq wget unzip && \
  wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
  unzip terraform_0.11.11_linux_amd64.zip && \
  wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz  && \
  tar xzvf helm-v2.12.2-linux-amd64.tar.gz && \
  chmod +x linux-amd64/helm && \
  echo $PATH | awk -F : '{print $1}' | xargs mv linux-amd64/helm && \
  wget https://storage.googleapis.com/kubernetes-release/release/v1.11.5/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl && \
  apt-get purge -yq wget unzip && \
  apt-get autoclean && \
  apt-get clean && \
  chmod +x terraform && \
  echo $PATH | awk -F : '{print $1}' | xargs mv terraform && \
  rm -rf linux-amd64/ helm-v2.12.2-linux-amd64.tar.gz terraform_0.11.11_linux_amd64.zip
