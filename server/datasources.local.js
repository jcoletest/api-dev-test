'use strict'

module.exports = {
  'mysqlDb': {
    'host': 'apidevmysql', // whatever your service is called in docker-compose
    'port': 3306,
    'database': 'apidevtestdb',
    'password': 'apidevtestpwd',
    'name': 'apidevmysql',
    'user': 'apidevtestuser',
    'connector': 'mysql',
  },
}
