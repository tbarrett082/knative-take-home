#!/bin/sh

get_next_version_and_tag() {
    GIT_URL="https://github.com/tbarrett082/knative-take-home"
    local latest_tag=$(git ls-remote --tags $GIT_URL | awk -F '/' '{print $NF}' | grep 'BUILD' | sed 's/^BUILD-//' | sort -V | tail -n 1)
    local next_version

    if [ -z "$latest_tag" ]; then
        next_version="BUILD-1"
    else
        next_version="BUILD-$((latest_tag + 1))"
    fi

    git tag "$next_version"
    git push --tags
    echo "Setting Docker tag to $next_version"
    DOCKER_TAG=$next_version
}


build_and_push() {
  mvn clean install
  get_next_version_and_tag
  REGISTRY_URL="ghcr.io/tbarrett082/knative-take-home"
  local image_name="$REGISTRY_URL/spring-test:$DOCKER_TAG"
  echo $image_name
  
  docker build -t $image_name .
  docker push "$image_name"
}


build_and_push
