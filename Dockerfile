FROM runpod/stable-diffusion:web-automatic-3.0.0
WORKDIR /
COPY start-user.sh /
COPY webui-user.sh /
EXPOSE 8888
CMD ['start-user.sh']