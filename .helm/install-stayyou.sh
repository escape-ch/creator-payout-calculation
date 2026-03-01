#!/bin/bash

set -o allexport
source ../.env
set +o allexport

IMAGE_HASH="v1.0.5" # using database for tiktok accounts

# to get docker password on aws console:
# aws ecr get-login-password --region eu-central-1

AWS_DOCKER_PASSWORD=$(aws ecr get-login-password --region eu-central-1 --profile escape)

# Login to AWS ECR
echo "$AWS_DOCKER_PASSWORD" | docker login --username AWS --password-stdin 431136220667.dkr.ecr.eu-central-1.amazonaws.com

# Build the Docker image
echo "Building Docker image with hash: $IMAGE_HASH"
docker buildx build --platform=linux/amd64 -t 431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation-stayyou:$IMAGE_HASH --push -f ../.Dockerfile.stayyou ../

# to only push if previous step failed
#docker push 431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation-stayyou:$IMAGE_HASH

echo "Successfully built and pushed image: $IMAGE_HASH"

kubectl delete secret regcred --ignore-not-found -n creator-payout-calculation-stayyou
kubectl create secret docker-registry regcred -n creator-payout-calculation-stayyou  \
--docker-server="431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation-stayyou" \
--docker-username=AWS \
--docker-password="$AWS_DOCKER_PASSWORD"

helm upgrade --install --wait --atomic \
  -n creator-payout-calculation-stayyou --create-namespace \
  creator-payout-calculation-stayyou ./payout-chart \
  -f ./values-stayyou.yaml \
  --set image="431136220667.dkr.ecr.eu-central-1.amazonaws.com/escape/creator-payout-calculation-stayyou:$IMAGE_HASH" \
  --set env.DATABASE_URL="$DATABASE_URL_K8S" \
  --set env.POSTHOG_KEY="$POSTHOG_KEY"

