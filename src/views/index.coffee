_ = require('underscore')

Views = _.extend {}, require('./main'), require('./clients'), require('./messages'), require('./messenger')
module.exports = Views
