<?php

define("serverApi",1);

require_once("m.php");

/* @var Server $server */
global $server;

/* @var Server $server */
$server = new Server();


/*
$_POST["request"] = "sendToBaseLabels";
$_POST["name"] = "videoFile.mp4";
$_POST["labels"] = "woman,man";
$_POST["indexFrame"] = "5";
$_POST["time"] = "5.023";
*/


if (empty($_POST)) {
    $getter = json_decode(file_get_contents('php://input'),true);
    $_POST = $getter;
}




//$_POST["request"]  = "searchTag";
//$_POST["label"]    = "laser";
//$_POST["fileName"] = "videoplayback.mp4";




$request = $_GET['request'];

if (!$request) {
    $request = $_POST['request'];
}


if ($request) {
    $result = $request();
    echo json_encode($result);
}


$server->disconnect();





function pushFiles() {
    /* @var Server $server */
    global $server;
    $server->connect();


    unset($_POST["request"]);

    // here need get user ID

    /* @var Server $server */
    global $server;
    $server->connect();
    /* @var UserAPI $userAPI */
    $userAPI = new UserAPI($server);



    $accessToken  = $_POST["accessToken"];
    $refreshToken = $_POST["refreshToken"];

    unset($_POST["accessToken"]);
    unset($_POST["refreshToken"]);


    $result = $userAPI->getUserInfoByToken_local($accessToken);


    if (!$result["result"]) {

        $result = $userAPI->refreshToken_local($refreshToken,null,null);
        if (!$result["result"]) return $result;

        $accessToken = $result["data"]["access_token"];
        $result = $userAPI->getUserInfoByToken_local($accessToken);
        if (!$result["result"]) return $result;
    }

    $userID = $result["userID"];

    foreach($_POST as $key=>$value)
    {

        $fileName = $value["url"];
        $location = $value["location"];

        $isLocalIdentifer = $value["isLocalIdentifer"];
        $typeID = $value["typeID"];


        $result = $server->select("SELECT ID FROM filesNames WHERE nameFile=? AND userID=?",$fileName,$userID);
        if (!$result["result"]) {
            return $result;
        }else {
            $data = $result["data"];
            if (!count($data)) {
                // need insert new file name
                $result = $server->insert("INSERT INTO filesNames (nameFile,userID,location,type,isLocalIdentifer) VALUES(?,?,?,?,?)",$fileName,$userID,$location,$typeID,$isLocalIdentifer);
                if (!$result["result"]) return $result;
                $fileNameID = $result["data"];
            }else {
                $fileNameID = $data[0]["ID"];
            }
        }



        $target_path = "uploads/userID".$userID.'/';

        if (!is_dir($target_path)) {
            if (false === @mkdir($target_path, 0777, true)) {
                return array("result"=>false,"data"=>"cant create dir");
            }
        }

        $target_path = $target_path . basename( $_FILES[$key]['name']);


        if(move_uploaded_file($_FILES[$key]['tmp_name'], $target_path)) {

            $dataTOTxt = [];
            $dataTOTxt["idInBase"] = $fileNameID;
            $dataTOTxt["filePath"] = $fileName;
            $dataTOTxt["userID"]   = $userID;

            file_put_contents($target_path.".txt",json_encode($dataTOTxt));


        }

    }

    return array("result"=>true,"data"=>"success uploaded");



}


function testAuth() {
    // and question )
    /* @var Server $server */
    global $server;
    $server->connect();

    /* @var UserAPI $userAPI */
    $userAPI = new UserAPI($server);



    $accessToken  = $_GET["accessToken"];
    $refreshToken = $_GET["refreshToken"];

    $result = $userAPI->getUserInfoByToken_local($accessToken);


    if (!$result["result"]) {

        $result = $userAPI->refreshToken_local($refreshToken,null,null);
        if (!$result["result"]) return $result;

        $accessToken = $result["data"]["access_token"];
        $result = $userAPI->getUserInfoByToken_local($accessToken);
        if (!$result["result"]) return $result;
    }

    return $result;
}

function test() {
    //

    // and question )
    /* @var Server $server */
    global $server;
    $server->connect();

    $tag1 = "plant";
    $tag2 = "food";
    $tag3 = "flower";


    $result = $server->select('SELECT INDEXGROUP
FROM groupLabels
WHERE tag = ? OR tag = ? OR tag=?
GROUP BY INDEXGROUP
HAVING count(*) = 3;',$tag1,$tag2,$tag3);




    /**/
    return $result;
}



function registerUser() {
    /* @var Server $server */
    global $server;
    $server->connect();
    /* @var UserAPI $userAPI */
    $userAPI = new UserAPI($server);



    $userName = $_GET["login"];
    $password = $_GET["pass"];
    $result = $userAPI->setUser_local($userName,$password);
    return $result;
}

function auth() {
    /* @var Server $server */
    global $server;
    $server->connect();
    /* @var UserAPI $userAPI */
    $userAPI = new UserAPI($server);




    $result = $userAPI->auth($_GET);
    return $result;
}






function searchTag() {
    /* @var Server $server */
    global $server;

    $server->connect();

    /* @var UserAPI $userAPI */
    $userAPI = new UserAPI($server);



    $accessToken  = $_GET["accessToken"];
    $refreshToken = $_GET["refreshToken"];
    $result = $userAPI->getUserInfoByToken_local($accessToken);


    if (!$result["result"]) {

        $result = $userAPI->refreshToken_local($refreshToken,null,null);
        if (!$result["result"]) return $result;

        $accessToken = $result["data"]["access_token"];
        $result = $userAPI->getUserInfoByToken_local($accessToken);
        if (!$result["result"]) return $result;
    }

    $userID = $result["userID"];

    $labels = $_GET["labels"];
    $rule   = $_GET["rule"];


    $fileNameID = -1;



    if (strcmp($rule,"None") === 0) {
        $result = $server->select("SELECT INDEXGROUP FROM groupLabels WHERE tag=?",$labels);
    }else if (strcmp($rule,"OR") === 0) {
        $labelsArray = explode(",",$labels);
        $where = [];
        for ($i = 0; $i < count($labelsArray);$i++) {
            $where[] = "tag=?";
        }
        $result = $server->select("SELECT INDEXGROUP FROM groupLabels WHERE ".implode(" OR ",$where),$labelsArray);
    }else if (strcmp($rule,"AND") === 0) {

        $labelsArray = explode(",",$labels);
        $where = [];
        for ($i = 0; $i < count($labelsArray);$i++) {
            $where[] = "tag=?";
        }

        $result = $server->select('SELECT INDEXGROUP
                                     FROM groupLabels
                                     WHERE '.implode(" OR ",$where).'
                                     GROUP BY INDEXGROUP
                                     HAVING count(*) = '.count($labelsArray).';',$labelsArray);




    }


    if (!$result["result"]) {
        return $result;
    }else {
        $data = $result["data"];
        if (count($data)) {
            $wheres = "";
            $idsArray = array();

            for ($i = 0; $i < count($data);$i++) {
                $wheres.= " IDGROUP=? ";
                if ($i!=count($data)-1) {
                    $wheres.=" OR ";
                }
                $idsArray[] = $data[$i]["INDEXGROUP"];
            }

            $result = $server->select("SELECT INDEXFRAME,time,indexFile,fn.nameFile as nameFile,fn.location as location,fn.type as type,fn.isLocalIdentifer as isLocalIdentifer
                                             FROM frameData as fd
                                             JOIN filesNames as fn
                                              ON (fn.ID = fd.indexFile)
                                            WHERE fd.userID=? AND (".$wheres.")",$userID,$idsArray);




            if (!$result["result"]) return $result;



            $data = $result["data"];

            $collection = array();
            $saver = array();
            for ($i = 0; $i< count($data); $i++) {
                $obj = $data[$i];

                $location   = $obj["location"];
                $_nm        = $obj["nameFile"];
                $indexFrame = $obj["INDEXFRAME"];
                $time       = $obj["time"];
                $type       = $obj["type"];
                $isLocalIdentifer = $obj["isLocalIdentifer"];



                if (!isset($collection[$_nm])){
                    $collection[$_nm] = array();



                    $saver[$_nm] = array();
                    $saver[$_nm]["currentCollectionIndex"] = 0;
                    $saver[$_nm]["lastTime"] = $time;
                    $saver[$_nm]["lastIndexFrame"] = -1111;
                }




                if ($indexFrame == $saver[$_nm]["lastIndexFrame"]+1 || $type == 1) {


                    $saver[$_nm]["openedCollection"] = 1;
                    if (!isset($collection[$_nm][$saver[$_nm]["currentCollectionIndex"]])){
                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]] = array();
                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["numFrames"] = 1;

                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["typeMedia"] = $type;
                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["isLocalIdentifer"] = $isLocalIdentifer;
                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["location"] = $location;

                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["framesStart"] = $saver[$_nm]["lastIndexFrame"];
                        $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["timeStart"]   = $saver[$_nm]["lastTime"];
                    }

                    $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["numFrames"]++;
                    $collection[$_nm][$saver[$_nm]["currentCollectionIndex"]]["timeEnd"] = $time;
                }else {
                    if ($saver[$_nm]["openedCollection"] == 1) {
                        $saver[$_nm]["currentCollectionIndex"]++;
                    }
                    $saver[$_nm]["openedCollection"] = 0;
                }


                $saver[$_nm]["lastTime"] = $time;
                $saver[$_nm]["lastIndexFrame"] = $indexFrame;

            }


            $resultCollection = array();



            foreach($collection as $key => $value){


                for ($j = 0; $j < count($value);$j++) {
                    $obj = $value[$j];



                    if ($obj["numFrames"] > 2 || intval($obj["typeMedia"]) == 1) {
                        $obj["nameFile"] = $key;
                        $resultCollection[] = $obj;
                    };
                }

            }





            if (count($resultCollection)) {
                return array("result"=>true,"data"=>$resultCollection);
            }else {
                return array("result"=>true,"data"=>"nothing found");
            }

        }else {
            return array("result"=>true,"data"=>"nothing found");

        }
    }

}





function sendToBaseLabels($labels,$indexFrame,$time,$userID,$fileNameID) {
    /* @var Server $server */
    global $server;

    $server->connect();



    $result = $server->select("SELECT ID FROM uniqueGroups WHERE tags=?",$labels);
    if (!$result["result"]) {
        return $result;
    }else {
        $data = $result["data"];
        if (!count($data)) {
            $result = $server->insert("INSERT INTO uniqueGroups (tags) VALUES(?)",$labels);
            if (!$result["result"]) return $result;
            $groupIDLabels = $result["data"];

            $arrayLabels = explode(",",$labels);

            for ($i = 0; $i < count($arrayLabels);$i++) {
                $label = $arrayLabels[$i];

                $result = $server->insert("INSERT INTO groupLabels (INDEXGROUP,tag,score) VALUES(?,?,?)",$groupIDLabels,$label,$i);
                if (!$result["result"]) return $result;
            }
        }else {
            $groupIDLabels = $data[0]["ID"];
        }
    }

    $message = "";
    $result = $server->select("SELECT ID FROM frameData WHERE IDGROUP=? AND INDEXFRAME=? AND indexFile=? AND userID=?",$groupIDLabels,$indexFrame,$fileNameID,$userID);
    if (!$result["result"]) {
        return $result;
    }else {
        $data = $result["data"];
        if (!count($data)) {
            $result = $server->insert("INSERT INTO frameData (IDGROUP,INDEXFRAME,indexFile,time,userID) VALUES(?,?,?,?,?)",$groupIDLabels,$indexFrame,$fileNameID,$time,$userID);
            if (!$result["result"]) return $result;
            $message = "success";
        }else {
            $frameID = $data[0]["ID"];
            $message = "success exist ID:".$frameID;
        }
    }

    $server->disconnect();

    return array("result"=>true,"data"=>$message);
}









