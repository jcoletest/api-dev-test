const path = require('path')

const server = require(path.resolve(__dirname, '../server/server.js'))
const mysql = server.dataSources.apidevmysql

const lbTables = ['User', 'AccessToken', 'ACL', 'RoleMapping', 'Role']
mysql.automigrate(lbTables, function (err) {
  if (err) throw err
  console.log('Tables [' + lbTables + '] created in ' + mysql.adapter.name)
  mysql.disconnect()
  process.exit(0)
})
