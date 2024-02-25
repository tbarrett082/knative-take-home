#!/bin/sh

get_latest_version() {
    GIT_URL="https://github.com/tbarrett082/knative-take-home"
    LATEST_TAG=$(git ls-remote --tags $GIT_URL | awk -F '/' '{print $NF}' | grep 'build' | sed 's/^build-//' | sort -V | tail -n 1)
    REGISTRY_URL="ghcr.io/tbarrett082/knative-take-home/spring-test"
}

tag_next_version() {
  get_latest_version
  local next_version
  
  if [ -z "$LATEST_TAG" ]; then
      next_version="build-1"
  else
      next_version="build-$((LATEST_TAG + 1))"
  fi
  
  git tag "$next_version"
  git push --tags
  echo "Setting Docker tag to $next_version"
  DOCKER_TAG=$next_version
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
    IMAGE="$REGISTRY_URL:build-$LATEST_TAG"
  fi
  export IMAGE=$IMAGE
  envsubst < knative/service.yaml > /tmp/service.yaml
  cat /tmp/service.yaml
  kubectl apply -f /tmp/service.yaml
#  unset IMAGE && rm /tmp/service.yaml
  kn service list
}


build_and_push
knative_deploy
