#!/bin/bash

setVariables() {
    
    # Settings
    NAME="dynatrace-mcp-server"
    NAMESPACE="tacocorp-mcp-server"

    VERSION=latest
    IMAGE="shinojosa/$NAME:$VERSION"

    # MCP Server settings (defined in the .env file)
    source .env
    #DT_GRAIL_QUERY_BUDGET_GB=1000
    #DT_MCP_DISABLE_TELEMETRY=false
    
    DEPLOYMENT=$NAME
    CONTAINER=$IMAGE
    YAMLFILE=$VERSION-$(date '+%Y-%m-%d_%H_%M_%S').yaml
    export RELEASE_VERSION=$VERSION
    export IMAGE=$IMAGE
    export DEPLOYMENT=$NAME
    export NAMESPACE=$NAMESPACE
    export APP=$NAME
    export DT_GRAIL_QUERY_BUDGET_GB=$DT_GRAIL_QUERY_BUDGET_GB
    export DT_MCP_DISABLE_TELEMETRY=$DT_MCP_DISABLE_TELEMETRY
    export DT_MCP_TELEMETRY_APPLICATION_ID=$DT_MCP_TELEMETRY_APPLICATION_ID
    export DT_MCP_TELEMETRY_ENDPOINT_URL=$DT_MCP_TELEMETRY_ENDPOINT_URL
    export DT_MCP_TELEMETRY_DEVICE_ID=$DT_MCP_TELEMETRY_DEVICE_ID

}

crossCompilePushDockerImage() {
    #build the image
    docker buildx build --platform linux/amd64,linux/arm64 --push --tag $IMAGE .
}


createDeployment() {

    echo "Creating deployment with variables"
    envsubst <k8s/deployment.yaml >k8s/gen/deploy-$YAMLFILE

    echo "Creating/Updating deployment in namespace $NAMESPACE"
    kubectl apply -f k8s/gen/deploy-$YAMLFILE
    # kubectl set image deployment/$deployment $name=$container -n $ns
    
    echo "Deleting secret if exists in namespace $NAMESPACE"
    kubectl delete secret dt-credentials -n $NAMESPACE
    
    echo "Creating secret for dt-credentials in namespace $NAMESPACE"
    kubectl create secret generic dt-credentials --from-literal=DT_ENVIRONMENT=$DT_ENVIRONMENT --from-literal=DT_PLATFORM_TOKEN=$DT_PLATFORM_TOKEN -n $NAMESPACE
}


setVariables
#crossCompilePushDockerImage
createDeployment