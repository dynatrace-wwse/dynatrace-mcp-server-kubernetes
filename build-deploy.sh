#!/bin/bash

setVariables() {

    NAME="dynatrace-mcp-server"
    NAMESPACE="dynatrace-mcp-server"

    VERSION=v0.7.0
    IMAGE="shinojosa/$NAME:$VERSION"

    DEPLOYMENT=$NAME
    CONTAINER=$IMAGE
    YAMLFILE=$VERSION-$(date '+%Y-%m-%d_%H_%M_%S').yaml
    export RELEASE_VERSION=$VERSION
    export IMAGE=$IMAGE

}

crossCompilePushDockerImage() {
    #clean before building
    mvn clean package
    #build the image
    docker buildx build --platform linux/amd64,linux/arm64 --push --tag $IMAGE .
}


createDeployment() {

    envsubst <k8s/deployment.yaml >k8s/gen/deploy-$YAMLFILE

    kubectl apply -f k8s/gen/deploy-$YAMLFILE
    # kubectl set image deployment/$deployment $name=$container -n $ns
    echo "make sure to create the secret maxmind-credentials"
    #kubectl create secret generic maxmind-credentials --from-literal=MAXMIND_ACCOUNT_ID=$MAXMIND_ACCOUNT_ID --from-literal=MAXMIND_LICENSE_KEY=$MAXMIND_LICENSE_KEY -n codespaces-tracker
}


setVariables
crossCompilePushDockerImage
createDeployment
