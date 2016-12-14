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
  # docker run ---entrypoint cat $IMAGE /tmp/yarn.lock > /tmp/yarn.lock

  # if ! diff -q yarn.lock /tmp/yarn.lock > /dev/null  2>&1; then
  #   echo "Moving new yarn.lock"
  #   cp /tmp/yarn.lock yarn.lock
  # fi

  eval $(aws ecr get-login --region $AWS_DEFAULT_REGION)

  docker push $IMAGE
}

function update_api_service () {

  echo "updating api service"

  # add image with new SHA
  cat ./task-definition.json | $JQ ".containerDefinitions[0].image=\"$IMAGE\"" > ./updated-task.json

  # add environment variables
  cat ./updated-task.json | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_HOST\", \"value\": \"$STAGING_RDS_HOST\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_DB\", \"value\": \"$STAGING_RDS_DB\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_USER\", \"value\": \"$STAGING_RDS_USER\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_PWD\", \"value\": \"$STAGING_RDS_PWD\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"NODE_ENV\", \"value\": \"staging\"}]" \
    | $JQ ".containerDefinitions[0].logConfiguration.options[\"awslogs-group\"] = \"$STAGING_API_AWSLOGS_GROUP\"" \
    | $JQ ".containerDefinitions[0].logConfiguration.options[\"awslogs-region\"] = \"$STAGING_API_AWSLOGS_REGION\"" \
    | $JQ ".containerDefinitions[0].logConfiguration.options[\"awslogs-stream-prefix\"] = \"$STAGING_API_AWSLOGS_PREFIX\"" > ./updated-task.json

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
