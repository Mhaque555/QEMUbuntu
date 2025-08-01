# QEMUbuntu

```
sudo apt update && sudo apt upgrade -y 

git clone https://github.com/Mhaque555/QEMUbuntu.git

cd QEMUbuntu/

# এই শেলে শুধু এই সেশনটার জন্য BuildKit/bake অফ করুন
export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_BUILDKIT=0

# Now build + run
docker compose up -d --build

# Check the logs
docker compose logs -f
```
# Open New terminal and run to see love download...
```
watch -n 2 ls -lh /tmp/ubuntu.iso
```
