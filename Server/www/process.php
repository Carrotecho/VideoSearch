<?php
/**
 * Created by PhpStorm.
 * User: easyproger
 * Date: 08.08.16
 * Time: 16:31
 */

require_once("videoSearch.php");
require_once("JSON_.php");

/* @var Services_JSON $JSON */
$JSON = new Services_JSON();




set_time_limit(0);

function scanDirectories($rootDir,$fileFind=null, $allData=array()) {
    // set filenames invisible if you want
    $invisibleFileNames = array(".", "..", ".htaccess", ".htpasswd",".DS_Store");
    // run through content of root directory
    $dirContent = scandir($rootDir);
    foreach($dirContent as $key => $content) {
        // filter all files not accessible
        $path = $rootDir.'/'.$content;
        if(!in_array($content, $invisibleFileNames)) {
            // if content is file & readable, add to array
            if(is_file($path) && is_readable($path)) {
                // save file name with path

                if (count($allData) > 100) return $allData;

                if ($fileFind) {
                    $pathInfo = pathinfo($path);
                    $pathExt = strtolower($pathInfo["extension"]);
                    for ($i = 0; $i < count($fileFind);$i++){
                        if (strcmp($pathExt,$fileFind[$i]) === 0) {
                            $allData[] = $path;
                        }
                    }
                }else {


                    $allData[] = $path;
                }

                // if content is a directory and readable, add path and name
            }elseif(is_dir($path) && is_readable($path)) {
                // recursive callback to open new directory
                $allData = scanDirectories($path,$fileFind, $allData);
            }
        }
    }
    return $allData;
}

function processVideo($videofile) {

    $pathInfo = pathinfo($videofile);



    $dirName  = $pathInfo["dirname"];
    $fileName = $pathInfo["basename"];


    $videofile = "http://".$_SERVER[HTTP_HOST]."/".$videofile;
    $command = 'ffmpeg -i '.$videofile.' -r 5/1 '.$dirName.'/'.$fileName.'_%03d.jpg';


    ob_start();
    passthru($command);
    $duration = ob_get_contents();
    ob_end_clean();
}


$videos = scanDirectories("uploads",array("mp4","mov"));

if (count($videos)) {

    processVideo($videos[0]);
    unlink($videos[0]);
/*
    for ($i = 0; $i < count($videos); $i++) {
        processVideo($videos[$i]);
        unlink($videos[$i]);
    }
*/
};


$imagesToSend = scanDirectories("uploads",array("jpg","png"));


// send here to google api !

$type = "LABEL_DETECTION";
$base64 = "";
$api_key = "AIzaSyDjtqbhoOF9OmcDsAdZEye-til0nyh5BQI";
$cvurl = 'https://vision.googleapis.com/v1/images:annotate?key=' . $api_key;

$count = count($imagesToSend);


if (!$count) {
    $txtToRemove = scanDirectories("uploads",array("txt"));
    for ($i = 0; $i < count($txtToRemove);$i++) {
        unlink($txtToRemove[$i]);
    }
}


for ($i = 0; $i < ceil($count/15);$i++) {

   // sleep(1);

    $request_json = '
            {
                "requests": [';
    $body = "";



    $indexStart = $i*15;

    $num = 15;
    if ($count-$indexStart < 15) {
        $num = $count-$indexStart;
    }


    $filesToAnalize = array();
    for ($j = 0; $j <$num; $j++) {


        $indexCurrent = intval($j)+intval($indexStart);
        $obj = $imagesToSend[$indexCurrent];
        $filesToAnalize[] = $obj;
// convert it to base64
        $data = file_get_contents($obj);
        $base64 = base64_encode($data);


        $body.='{
                        "image": {
                            "content":"' . $base64 . '"
                        },
                        "features": [
                            {
                                "type": "' . $type . '",
                                "maxResults": 10
                            }
                        ]
                    }';
        if ($j < 15-1) $body.=",";
    }


    $request_json.=$body;


    $request_json.=']
            }';




    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $cvurl);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $request_json);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, FALSE);
    curl_setopt($curl, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5 GTB6");
    $json_response = curl_exec($curl);
    $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);

    if ($status != 200) {
        echo json_encode(array("result"=>false,"data"=>curl_error($curl)));
        return;
    }

    curl_close($curl);


    $jsonObject = $JSON->decode($json_response);

    $jsonResponseObject = $jsonObject->{"responses"};

    for ($fa = 0; $fa< count($filesToAnalize);$fa++) {

        $file = $filesToAnalize[$fa];



        $labelAnotations = $jsonResponseObject[$fa]->{"labelAnnotations"};

        $labelsArray = array();
        for ($label = 0; $label < count($labelAnotations);$label++) {
            $labelsArray[] = $labelAnotations[$label]->{"description"};
        }

        $labelString = implode(",",$labelsArray);

        if (file_exists($file.".txt")) {
            // image
            $fileData = file_get_contents($file.".txt");
            $fileDataJSON = $JSON->decode($fileData);



            $result = sendToBaseLabels($labelString,0,0,$fileDataJSON->{"userID"},$fileDataJSON->{"idInBase"});
            if (!$result["result"]) {
                echo json_encode($result);
                return;
            }


            unlink($file);
        }else {
            $pathInfo = pathinfo($file);
            $dirname = $pathInfo["dirname"];
            $basename = $pathInfo["basename"];
            $ext = $pathInfo["extension"];

            $pos = strrpos($basename,".".$ext);
            $fileName = substr($basename,0,$pos);

            $pos = strrpos($fileName,"_");

            $frameIndex = intval(substr($fileName,$pos+1,strlen($fileName)-$pos));

            $originalFileName = substr($fileName,0,$pos);

            $dataFilePath = $dirname."/".$originalFileName.".txt";


            if (file_exists($dataFilePath)) {
                $dataFile = file_get_contents($dataFilePath);

                $dataFileJSON = $JSON->decode($dataFile);

                $result = sendToBaseLabels($labelString,$frameIndex,0,$dataFileJSON->{"userID"},$dataFileJSON->{"idInBase"});

                if (!$result["result"]) {
                    echo json_encode($result);
                    return;
                }
            }
            unlink($file);
        }
    }
}


echo json_encode(array("result"=>true,"data"=>""));



/*




*/












