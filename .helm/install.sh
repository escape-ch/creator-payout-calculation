#!/bin/bash

set -o allexport
source ../.env
set +o allexport

IMAGE_HASH="v1.0.4" # using database for tiktok accounts

# to get docker password on aws console:
# aws ecr get-login-password --region eu-central-1

AWS_DOCKER_PASSWORD=$(aws ecr get-login-password --region eu-central-1 --profile escape)

# Login to AWS ECR
echo "$AWS_DOCKER_PASSWORD" | docker login --username AWS --password-stdin 431136220667.dkr.ecr.eu-central-1.amazonaws.com

# Build the Docker image
echo "Building Docker image with hash: $IMAGE_HASH"
docker buildx build --platform=linux/amd64 -t 431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation:$IMAGE_HASH --push -f ../.Dockerfile ../

# to only push if previous step failed
#docker push 431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation:$IMAGE_HASH

echo "Successfully built and pushed image: $IMAGE_HASH"

kubectl delete secret regcred --ignore-not-found -n creator-payout-calculation
kubectl create secret docker-registry regcred -n creator-payout-calculation  \
--docker-server="431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation" \
--docker-username=AWS \
--docker-password="$AWS_DOCKER_PASSWORD"

helm upgrade --install --wait --atomic \
  -n creator-payout-calculation --create-namespace \
  creator-payout-calculation ./payout-chart \
  -f ./values.yaml \
  --set image="431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation:$IMAGE_HASH" \
  --set env.DATABASE_URL="$DATABASE_URL_K8S"

