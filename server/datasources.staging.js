'use strict'

module.exports = {
  'apidevmysql': {
    'host': process.env.STAGING_RDS_HOST,
    'port': 3306,
    'database': process.env.STAGING_RDS_DB,
    'user': process.env.STAGING_RDS_USER,
    'password': process.env.STAGING_RDS_PWD,
    'name': process.env.STAGING_RDS_DB,
    'connector': 'mysql',
  },
}
