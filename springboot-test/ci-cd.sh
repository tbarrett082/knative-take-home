#!/bin/sh

get_latest_version() {
    GIT_URL="https://github.com/tbarrett082/knative-take-home"
    LATEST_VERSION=$(git ls-remote --tags $GIT_URL | awk -F '/' '{print $NF}' | grep 'build' | sed 's/^build-//' | sort -V | tail -n 1)
    LATEST_TAG="build-$LATEST_VERSION"
    REGISTRY_URL="ghcr.io/tbarrett082/knative-take-home/spring-test"
}

tag_next_version() {
  get_latest_version
  local next_version
  
  if [ -z "$LATEST_TAG" ]; then
      next_version="build-1"
  else
      next_version="build-$((LATEST_VERSION + 1))"
      LATEST_VERSION=$((LATEST_VERSION + 1))
  fi
  
  git tag "$next_version"
  git push --tags
  echo "Setting Docker tag to $next_version"
  DOCKER_TAG=$next_version
  LATEST_TAG=$next_version
}


build_and_push() {
  mvn clean install
  tag_next_version
  IMAGE="$REGISTRY_URL:$DOCKER_TAG"
  echo $IMAGE
  
  docker build -t $IMAGE .
  docker push "$IMAGE"
}

knative_deploy() {
  if [[ -z "$IMAGE" ]]; then
    get_latest_version
    IMAGE="$REGISTRY_URL:$LATEST_TAG"
  fi
  export IMAGE=$IMAGE
  echo "Deploying $IMAGE using knative"
  envsubst < knative/service.yaml > /tmp/service.yaml
  cat /tmp/service.yaml
  kubectl apply -f /tmp/service.yaml
#  unset IMAGE && rm /tmp/service.yaml
  kn service list
}

helm_deploy() {
  get_latest_version
  echo "Deploying $LATEST_TAG using helm"
  export TAG=$LATEST_TAG && envsubst < k8s/helm-deployment.yaml > /tmp/helm-deployment.yaml
  helm upgrade --install -n production spring-test-deploy -f /tmp/helm-deployment.yaml helm/helm-deployment-0.1.0.tgz
}

# User Prompt
echo "What would you like to do?"
echo "1. Just build; runs maven and deploys the docker image"
echo "2. Build and deploy, using knative"
echo "3. Build and deploy with Helm"
echo "4. Deploy the latest version with Knative"
echo "5. Deploy the latest version with Helm"
read -p "Enter your choice (1/2/3/4/5): " choice

case $choice in
    1)
        build_and_push
        ;;
    2)
        build_and_push
        knative_deploy
        ;;
    3)
        build_and_push
        helm_deploy
        ;;
    4)
        knative_deploy
        ;;
    5)
        helm_deploy
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac