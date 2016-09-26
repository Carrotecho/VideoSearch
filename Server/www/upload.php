<?php
/**
 * Created by PhpStorm.
 * User: easyproger
 * Date: 25.07.16
 * Time: 2:46
 */
$myparam = $_POST['userfile'];     //getting image Here
$mytextLabel= $_POST['filenames'];   //getting textLabe Here
$target_path = "uploads/";
$target_path = $target_path . basename( $_FILES['file']['name']);


if(move_uploaded_file($_FILES['file']['tmp_name'], $target_path)) {
    echo json_encode(array("result"=>true,"data"=>$target_path));
} else {
    echo json_encode(array("result"=>false,"data"=>"error occurred"));
}