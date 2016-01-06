<?php

  if(isset($_FILES['file']['tmp_name']))
  {
    // get picture variables
    $file       = $_FILES['file']['tmp_name'];
    $fileName   = $_FILES['file']['name'];
    $fileType   = $_FILES['file']['type'];

    // check extension
    $allowedExts = array("jpg", "jpeg", "png");
    $rootName = reset(explode(".", $fileName));
    $extension = end(explode(".", $fileName));

    // create new file name
    $time = time();
    $newName = $rootName.$time.'.'.$extension;

    // temporarily save file
    $userId = htmlspecialchars_decode($_POST['sender_user_id']);

    $moved = move_uploaded_file($_FILES["file"]["tmp_name"], "uploads/".$userId.".".$extension );
    if ($moved) $path = "uploads/".$userId.".".$extension;

    $time = time();
    if ($moved) {
      $fullUrl = "https://chat-dare1234.rhcloud.com/".$path;

      include 'dbPDOController.php';

      $dbh = Db::getDBInstance();

      $sql = "UPDATE chatapp.users SET imgUrl = :imageUrl WHERE user_id = :us_id;";
      $stmt = $dbh->prepare($sql);

      $stmt->bindParam(':imageUrl', $fullUrl);
      $stmt->bindParam(':us_id', $userId);

      $stmt->execute();

      $arrayToSend = array('errNo'=>'300','time'=>$time,'userId'=>$userId, "imageURL"=>$fullUrl);
    } else {
      $arrayToSend = array('errNo'=>'Failed to upload image','time'=>$time,'userId'=>$userId);
    }

    header('Content-Type:application/json');
    echo json_encode($arrayToSend);
  }
  else {
    echo "UploadImg!";
  }
?>
