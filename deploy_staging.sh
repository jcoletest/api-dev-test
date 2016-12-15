set -e
JQ="jq --raw-output --exit-status"
CLUSTER="apidevcluster"
BUILD="$CIRCLE_SHA1"
REGISTERYREPO="ecs-apiserver"
SERVICE="apiserver"
TASK_DEFINITION="apiserver"

IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REGISTERYREPO:$CIRCLE_SHA1"

function push_to_registry () {

  echo "pushing to registry"

  # Build down new version of image
  docker build --rm=false -t $IMAGE .

  eval $(aws ecr get-login --region $AWS_DEFAULT_REGION)

  docker push $IMAGE
}

function update_api_service () {

  echo "updating api service"

  # create updated task
  node ./create-updated-task.js

  aws ecs register-task-definition \
    --cli-input-json file://updated-task.json

  aws ecs update-service --cluster $CLUSTER --service $SERVICE \
    --task-definition $TASK_DEFINITION

  # remove temp file
  rm -rf ./updated-task.json
}

function update_ecs () {
  push_to_registry
  update_api_service
}

update_ecs
