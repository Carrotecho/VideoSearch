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
// метод сканирования директории 
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
// ограничение на 100 файлов для отпрваки в гугл 
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
// метод обработки видео через ffmpeg 
function processVideo($videofile) {

    $pathInfo = pathinfo($videofile);



    $dirName  = $pathInfo["dirname"];
    $fileName = $pathInfo["basename"];

//получаем изображение 5 кадров в секунду 
    $videofile = "http://".$_SERVER[HTTP_HOST]."/".$videofile;
    $command = 'ffmpeg -i '.$videofile.' -r 5/1 '.$dirName.'/'.$fileName.'_%03d.jpg';


    ob_start();
    passthru($command);
    $duration = ob_get_contents();
    ob_end_clean();
}


$videos = scanDirectories("uploads",array("mp4","mov"));
// ограничеваем анализ на одно видео за раз 
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

// сканируем изображения 
$imagesToSend = scanDirectories("uploads",array("jpg","png"));


// send here to google api !

$type = "LABEL_DETECTION";
$base64 = "";
$api_key = "AIzaSyDKLmKhpFtbEvfWWqwfzMnDbpMkOQOBcnY";
$cvurl = 'https://vision.googleapis.com/v1/images:annotate?key=' . $api_key;

$count = count($imagesToSend);

// если папка с изображениями пустая мы можем подчистить текстовые файлы
if (!$count) {
    $txtToRemove = scanDirectories("uploads",array("txt"));
    for ($i = 0; $i < count($txtToRemove);$i++) {
        unlink($txtToRemove[$i]);
    }
}

// разбивка на блоки по 15 фотографий 
for ($i = 0; $i < ceil($count/15);$i++) {

   // sleep(1);
// формирования запроса 
    $request_json = '
            {
                "requests": [';
    $body = "";



    $indexStart = $i*15;

    // дабы не выходить за рамки массива мы проверяем на его окончание
    $num = 15;
    if ($count-$indexStart < 15) {
        $num = $count-$indexStart;
    }

// формируем тело запроса 
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


// отправка в гугл 

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

// парсим ответ от гугл 
    $jsonObject = $JSON->decode($json_response);

    $jsonResponseObject = $jsonObject->{"responses"};

    for ($fa = 0; $fa< count($filesToAnalize);$fa++) {

        $file = $filesToAnalize[$fa];


// получаем теги 
        $labelAnotations = $jsonResponseObject[$fa]->{"labelAnnotations"};

        $labelsArray = array();
        for ($label = 0; $label < count($labelAnotations);$label++) {
            $labelsArray[] = $labelAnotations[$label]->{"description"};
        }

        $labelString = implode(",",$labelsArray);
// если анализированный кадр это изображение то у него будет отдельный файл 
// смысл в том что на отдельные изобрежния создается отдельно файл с описанием 
// на видео же создается только один файл ( не смотря на то что изображений из этого видео куда больше ) 
        if (file_exists($file.".txt")) {
            // image
            
            // алгоритм отправки данных в базу если это изображение 
            $fileData = file_get_contents($file.".txt");
            $fileDataJSON = $JSON->decode($fileData);



            $result = sendToBaseLabels($labelString,0,0,$fileDataJSON->{"userID"},$fileDataJSON->{"idInBase"});
            if (!$result["result"]) {
                echo json_encode($result);
                return;
            }


            unlink($file);
        }else {
            
            // алгоритм отправки в базу данных если это кадр из видео 
            // очищаем название от номера кадра ( сохраняя его )
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
// отправляем данные в базу 
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












