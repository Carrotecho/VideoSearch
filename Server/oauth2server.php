<?php
/**
 * Created by JetBrains PhpStorm.
 * User: easyproger
 * Date: 26.03.15
 * Time: 20:00
 * To change this template use File | Settings | File Templates.
 */

require_once('OAuth2/Autoloader.php');
require_once("p/config.php");



$dbname   = config::$dboauth2name;
$dbhost   = config::$dboauth2host;
$username = config::$dboauth2user;
$password = config::$dboauth2password;


$dsn = 'mysql:dbname='.$dbname.';host='.$dbhost;

// error reporting (this is a demo, after all!)
ini_set('display_errors',1);error_reporting(E_ALL);

// Autoloading (composer is preferred, but for this example let's just do this)

OAuth2\Autoloader::register();



// $dsn is the Data Source Name for your database, for exmaple "mysql:dbname=my_oauth2_db;host=localhost"
$storage = new OAuth2\Storage\Pdo(array('dsn' => $dsn, 'username' => $username, 'password' => $password));

// Pass a storage object or array of storage objects to the OAuth2 server class
$serverOAuth2 = new OAuth2\Server($storage);


$serverOAuth2->addGrantType(new OAuth2\GrantType\UserCredentials($storage));
$serverOAuth2->addGrantType(new OAuth2\GrantType\ClientCredentials($storage));
$serverOAuth2->addGrantType(new OAuth2\GrantType\AuthorizationCode($storage));
$serverOAuth2->addGrantType(new OAuth2\GrantType\RefreshToken($storage, array(
    'refresh_token_lifetime'         => 2419200
)));
