# QEMUbuntu

```
sudo apt update && sudo apt upgrade -y 

git clone https://github.com/Mhaque555/QEMUbuntu.git

cd QEMUbuntu/

# Turn off BuildKit/bake for this session only in this shell
export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_BUILDKIT=0

# Now build + run
docker compose up -d --build

# Check the logs
docker compose logs -f
```
# Open New terminal and run to see live download...
```
watch -n 2 ls -lh /tmp/ubuntu.iso
```
