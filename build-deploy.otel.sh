#!/bin/bash

setVariables() {
    
    # Settings
    ENVIRONMENT="tacocorp"
    NAME="dynatrace-mcp-server"
    NAMESPACE=$ENVIRONMENT"-mcp-server"

    VERSION=otel
    IMAGE="shinojosa/$NAME:$VERSION"

    # MCP Server settings (defined in the .env file)
    source .$ENVIRONMENT.env
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

    export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
    export OTEL_RESOURCE_ATTRIBUTES=$OTEL_RESOURCE_ATTRIBUTES
    export DYNATRACE_API_TOKEN=$DYNATRACE_API_TOKEN

    export DT_PLATFORM_ENVIRONMENT=$DT_PLATFORM_ENVIRONMENT


}

crossCompilePushDockerImage() {
    #build the image
    docker buildx build --platform linux/amd64,linux/arm64 --push --tag $IMAGE .
}


createDeployment() {

    echo "Creating namespace if does not exist"
    kubectl create ns $NAMESPACE

    echo "Creating deployment with variables"
    envsubst <k8s/deployment.yaml >k8s/gen/deploy-$YAMLFILE

    echo "Creating/Updating deployment in namespace $NAMESPACE"
    kubectl apply -f k8s/gen/deploy-$YAMLFILE
    # kubectl set image deployment/$deployment $name=$container -n $ns
    
    echo "Deleting secret if exists in namespace $NAMESPACE"
    kubectl delete secret dt-credentials -n $NAMESPACE
    
    echo "Creating secret for dt-credentials in namespace $NAMESPACE"
    kubectl create secret generic dt-credentials \
    --from-literal=DT_ENVIRONMENT="$DT_ENVIRONMENT" \
    --from-literal=OTEL_EXPORTER_OTLP_HEADERS="$OTEL_EXPORTER_OTLP_HEADERS" \
    --from-literal=DYNATRACE_API_TOKEN="$DYNATRACE_API_TOKEN" \
    --from-literal=DT_PLATFORM_TOKEN="$DT_PLATFORM_TOKEN" \
    -n "$NAMESPACE"
}


setVariables
#crossCompilePushDockerImage
createDeployment