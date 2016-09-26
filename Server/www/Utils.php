<?php

class Utils {
    public static function generateUserSessionID() {
        return ".".$_SERVER["REMOTE_ADDR"];
    }
}