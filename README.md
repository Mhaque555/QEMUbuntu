# QEMUbuntu

```
sudo apt update && sudo apt upgrade -y 

git clone https://github.com/Mhaque555/QEMUbuntu.git

cd QEMUbuntu/

# এই শেলে শুধু এই সেশনটার জন্য BuildKit/bake অফ করুন
export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_BUILDKIT=0

# এখন বিল্ড + রান
docker compose up -d --build

# লগ দেখে নিন
docker compose logs -f
```
