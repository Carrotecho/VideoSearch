<?php
/**
 * Created by JetBrains PhpStorm.
 * User: easyproger
 * Date: 28.01.15
 * Time: 23:01
 * To change this template use File | Settings | File Templates.
 */

class config {

    public static $dbusers_info    = "Users";
    public static $dbusers    = "oauth_users";
    public static $dbclients  = "oauth_clients";
    public static $dbtokens   = "oauth_access_tokens";
    public static $dbrefresh  = "oauth_refresh_tokens";

    public static $dbhost     = "localhost";
    public static $dbuser     = "root";
    public static $dbpassword = "airflaers";
    public static $dbname     = "videoSearch";
    public static $prefix     = "";

    public static $dboauth2password = "airflaers";
    public static $dboauth2user     = "root";
    public static $dboauth2name     = "videoSearch";
    public static $dboauth2host     = "localhost";

    public static $magicRemove = "0xBBAADDAABB";
    public static $timeZoneDef = "Moscow";

    public static $error_email = 'iartic@me.com';
    public static $error_table = 'errors';
    public static $error_file  = '../logs/error.log';
}



