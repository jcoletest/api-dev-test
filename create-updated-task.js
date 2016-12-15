'use strict'

const fs = require('fs')

const task = require('./task-definition.json')
const updatedTask = task
const repo = 'ecs-apiserver'

const url = `${process.env.AWS_ACCOUNT_ID}.dkr.ecr.${process.env.AWS_DEFAULT_REGION}.amazonaws.com`

const image = `${url}/${repo}:${process.env.CIRCLE_SHA1}`

updatedTask.containerDefinitions[0].image = image

updatedTask.containerDefinitions[0].environment = [
  {
    'name': 'STAGING_RDS_HOST',
    'value': process.env.STAGING_RDS_HOST,
  },
  {
    'name': 'STAGING_RDS_DB',
    'value': process.env.STAGING_RDS_DB,
  },
  {
    'name': 'STAGING_RDS_USER',
    'value': process.env.STAGING_RDS_USER,
  },
  {
    'name': 'STAGING_RDS_PWD',
    'value': process.env.STAGING_RDS_PWD,
  },
  {
    'name': 'NODE_ENV',
    'value': 'staging',
  },
]

updatedTask.containerDefinitions[0].logConfiguration.options = {
  'awslogs-group': process.env.STAGING_API_AWSLOGS_GROUP,
  'awslogs-region': process.env.STAGING_API_AWSLOGS_REGION,
  'awslogs-stream-prefix': process.env.STAGING_API_AWSLOGS_PREFIX,
}

const jsonTask = JSON.stringify(updatedTask)

fs.writeFile('updated-task.json', jsonTask, 'utf8')
