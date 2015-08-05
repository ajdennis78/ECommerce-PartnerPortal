require("appdynamics").profile({
    controllerHostName: 'CONTROLLER',
    controllerPort: 'APPD_PORT', // If SSL, be sure to enable the next line  
    ssl: 'SSL',
    accountName: 'ACCOUNT_NAME', // Required for a controller running in multi-tenant mode
    accountAccessKey: 'ACCESS_KEY', // Required for a controller running in multi-tenant mode
    applicationName: 'APP_NAME',
    tierName: 'TIER_NAME',
    nodeName: 'NODE_NAME' // The controller will automatically append the node name with a unique number
});

var express = require('express'),
    path = require('path'),
    http = require('http'),
    wine = require('./routes/wines');

var app = express();

app.configure(function () {
    app.set('port', process.env.PORT || 3000);
    app.use(express.logger('dev'));  /* 'default', 'short', 'tiny', 'dev' */
    app.use(express.bodyParser()),
    app.use(express.static(path.join(__dirname, 'public')));
});

// Add crossapp link to call ECommerce Service
app.get('/crossapp', wine.crossApp);

app.get('/wines', wine.findAll);
app.get('/wines/:id', wine.findById);
app.post('/wines', wine.addWine);
app.put('/wines/:id', wine.updateWine);
app.delete('/wines/:id', wine.deleteWine);

http.createServer(app).listen(app.get('port'), function () {
    console.log("Express server listening on port " + app.get('port'));
});
