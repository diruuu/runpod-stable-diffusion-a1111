# runpod-stable-diffusion-a1111
Easy and simple way to load custom Stable Diffusion checkpoint models, extension, embedding, LoRA, and ControlNET files on custom runpod template. This basically will run a bash script when running the runpod docker image which download and setup all those files to the container. Follow steps below:
1. Clone this repo
2. Open `lists` folder. There will be a bunch of `.txt` files for you to edit. Put the URL of your models in there separated by line breaks
3. `extensions.txt` has slighty different format. Use this format: `<Github Username>|<Repo name>|<branch>`. For example `Mikubill|sd-webui-controlnet|main`. Then separate each extension by line breaks.
4. Put the bash script below on the `Docker command` options on your custom runpod template. Don't forget to change the repo URL (`https://github.com/diruuu/runpod-stable-diffusion-a1111`) with your own cloned repo.

```bash
bash -c 'apt-get update && apt-get install unzip && cd /workspace && ([ -d "./runpod-stable-diffusion-a1111" ] && echo "Directory runpod-stable-diffusion-a1111 exists." || git clone https://github.com/diruuu/runpod-stable-diffusion-a1111) && cd ./runpod-stable-diffusion-a1111 && ./start-user.sh'
```
