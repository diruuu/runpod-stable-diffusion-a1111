#!/bin/bash

LORA_LIST_PATH="./lists/lora.txt"
LORA_PATH="../stable-diffusion-webui/models/Lora"

TI_LIST_PATH="./lists/ti.txt"
TI_PATH="../stable-diffusion-webui/embeddings"

CHECKPOINT_LIST_PATH="./lists/checkpoint.txt"
CHECKPOINT_PATH="../stable-diffusion-webui/models/Stable-diffusion"

CONTROLNET_LIST_PATH="./lists/controlnet.txt"
CONTROLNET_PATH="../stable-diffusion-webui/extensions/sd-webui-controlnet-main/models"

EXTENSION_LIST_PATH="./lists/extensions.txt"
EXTENSION_PATH="../stable-diffusion-webui/extensions"

download_by_list_file() {
  TI_LINES=$(cat $1)
  IFS=$'\n'
  for TI_LINE in $TI_LINES
  do
      REF_FILE="$2/${TI_LINE##*/}.txt";
      if [ -f "$REF_FILE" ]; then
          echo "File $TI_LINE exists."
      else 
          wget -P $2 --content-disposition $TI_LINE;
          if [ $? -ne 0 ]
            then echo "Download failed"
            else touch $REF_FILE;
          fi
      fi
  done
}

download_extension() {
  TI_LINES=$(cat $1)
  IFS=$'\n'
  for TI_LINE in $TI_LINES
  do
    IFS=$'|'
    read -a strarr <<< "$TI_LINE";
    GIT_URL="https://github.com/${strarr[0]}/${strarr[1]}/archive/refs/heads/${strarr[2]}.zip";
    FOLDER_NAME="${strarr[1]}-${strarr[2]}";
    if [ -d "$2/$FOLDER_NAME" ]; then
        echo "Extension ${strarr[1]} exists."
    else 
        wget -P $2 $GIT_URL -O "$2/${strarr[1]}.zip";
        unzip "$2/${strarr[1]}" -d $2
        rm "$2/${strarr[1]}.zip"
    fi
  done
}

setup_controlnet() {
  REF_FILE="./controlnet_done.txt";
  if [ -f "$REF_FILE" ]; then
      echo "Controlnet has been setup.";
  else 
      cp ../stable-diffusion-webui/extensions/sd-webui-controlnet-main/models/*.yaml ../stable-diffusion-webui/models;
      touch "./controlnet_done.txt";
  fi
}

copy_webui_user() {
  cp ./webui-user.sh ../stable-diffusion-webui
}

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
    echo "SSH Service Started"
fi

apt-get update && apt-get install unzip
copy_webui_user
download_extension $EXTENSION_LIST_PATH $EXTENSION_PATH
setup_controlnet
download_by_list_file $LORA_LIST_PATH $LORA_PATH
download_by_list_file $TI_LIST_PATH $TI_PATH
download_by_list_file $CHECKPOINT_LIST_PATH $CHECKPOINT_PATH
download_by_list_file $CONTROLNET_LIST_PATH $CONTROLNET_PATH
download_by_list_file $CHECKPOINT_LIST_PATH $CHECKPOINT_PATH

echo "Container Started"
export PYTHONUNBUFFERED=1
source ../stable-diffusion-webui/venv/bin/activate

if [[ $JUPYTER_PASSWORD ]]
then
    ln -sf /examples /workspace
    ln -sf /root/welcome.ipynb /workspace

    cd /
    jupyter lab --allow-root --no-browser --port=8888 --ip=* \
        --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
        --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
    echo "Jupyter Lab Started"
fi

sleep infinity
