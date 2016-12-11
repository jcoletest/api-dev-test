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
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_HOST\", \"value\": \"$STAGING_RDS_DB\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_HOST\", \"value\": \"$STAGING_RDS_USER\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"STAGING_RDS_HOST\", \"value\": \"$STAGING_RDS_PWD\"}]" \
    | $JQ ".containerDefinitions[0].environment |= .+ [{\"name\": \"NODE_ENV\", \"value\": \"staging\"}]" > ./updated-task.json

  aws ecs register-task-definition \
    --cli-input-json file://updated-task.json

  aws ecs update-service --cluster $CLUSTER --service $SERVICE \
    --task-definition $TASK_DEFINITION

  # remove temp file
  rm -rf ./updated-task.json
}

function all_but_migrate () {
  push_to_registry
  update_api_service
}

function help_menu () {
cat << EOF
Usage: ${0} (-h | -p | -i | -r | -d | -a)

OPTIONS:
   -h|--help             Show this message
   -p|--push-to-registry Push the api application to your private registry
   -w|--update-api       Update the api application
   -r|--update-worker    Update the background worker
   -d|--run-db-migrate   Run a database migration
   -a|--all-but-migrate  Do everything except migrate the database

EXAMPLES:
   Push the api application to your private registry:
        $ ./deploy.sh -p

   Update the api application:
        $ ./deploy.sh -i

   Update the background worker:
        $ ./deploy.sh -r

   Run a database migration:
        $ ./deploy.sh -d

   Do everything except run a database migration:
        $ ./deploy.sh -a

EOF
}

# Deal with command line flags.
while [[ $# > 0 ]]
do
case "${1}" in
  -p|--push-to-registry)
  push_to_registry
  shift
  ;;
  -i|--update-api)
  update_api_service
  shift
  ;;
  -r|--update-worker)
  update_worker_service
  shift
  ;;
  -d|--run-db-migrate)
  run_database_migration
  shift
  ;;
  -a|--all-but-migrate)
  all_but_migrate
  shift
  ;;
  -h|--help)
  help_menu
  shift
  ;;
  *)
  echo "${1} is not a valid flag, try running: ${0} --help"
  ;;
esac
shift
done
