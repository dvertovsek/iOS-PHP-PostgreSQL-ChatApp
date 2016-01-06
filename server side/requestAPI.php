<?php

  if(isset($_POST["method"]))
  {
    include 'dbPDOController.php';

    $dbh = Db::getDBInstance();

    $JSONresult = array();
    switch(htmlspecialchars_decode($_POST["method"]))
    {
      case "sendRequest":
        $sql = "INSERT INTO chatapp.requests(request_id, user_id_from, user_id_to, hello_message, time_sent, accepted) VALUES(DEFAULT, :user_from, :user_to, :hello_message, DEFAULT, DEFAULT);";
        $stmt = $dbh->prepare($sql);
        $stmt->bindParam(':user_from', htmlspecialchars_decode($_POST["sender_user_id"]));
        $stmt->bindParam(':user_to', htmlspecialchars_decode($_POST["user_id"]));
        $stmt->bindParam(':hello_message', htmlspecialchars_decode($_POST["hello_message"]));

        $stmt->execute();

        $errArray = $dbh->errorInfo();
        if($errArray[1] == "7")
        {
          $JSONresult = array("errNo" => $errArray[2]);
        }
        else {
          $JSONresult = array("errNo" => "Request successfuly sent!");
        }
        $JSONresult["messages"] = array();
        break;

      case "getAll":
        $sql = "SELECT user_id,first_name,last_name,location,on_line,imgurl,user_status_id,user_type_id,username,time_sent,hello_message FROM chatapp.requests JOIN chatapp.users ON(user_id_from = user_id) WHERE user_id_to = ? AND accepted IS NULL";
        $stmt = $dbh->prepare($sql);

        $JSONarray = array();
        if ($stmt->execute(array(htmlspecialchars_decode($_POST['sender_user_id']))))
        {
          while($row = $stmt->fetch())
          {
            $jsonrequest = array("username" => $row["username"]);
            $jsonrequest["user_id"] = $row["user_id"];
            $jsonrequest["first_name"] = $row["first_name"];
            $jsonrequest["last_name"] = $row["last_name"];
            $jsonrequest["location"] = $row["location"];
            $jsonrequest["on_line"] = $row["on_line"];
            $jsonrequest["imgUrl"] = $row["imgurl"];
            $jsonrequest["user_status_id"] = $row["user_status_id"];
            $jsonrequest["user_type_id"] = $row["user_type_id"];
            $jsonrequest["time_sent"] = $row["time_sent"];
            $jsonrequest["hello_message"] = $row["hello_message"];
            array_push($JSONarray, $jsonrequest);
          }
          $JSONresult = array("users" => $JSONarray);
        }
        break;

      case "updateRequest":
        $sql = "UPDATE chatapp.requests SET accepted = :accepted WHERE user_id_from = :user_from AND user_id_to = :user_to AND accepted IS NULL;";
        $stmt = $dbh->prepare($sql);
        $stmt->bindParam(':user_from', htmlspecialchars_decode($_POST["user_id"]));
        $stmt->bindParam(':user_to', htmlspecialchars_decode($_POST["sender_user_id"]));
        $stmt->bindParam(':accepted', htmlspecialchars_decode($_POST["isAccepted"]));

        $stmt->execute();

        $ret_message = "";
        if ($_POST["isAccepted"] == "false")
        {
          $ret_message = "You denied friend request!";
        }
        else {
          $ret_message = "You accepted friend request!";
        }
        $JSONresult = array("errNo" => $ret_message);
        break;
    }
    echo json_encode($JSONresult);
  }
  else
  {
    echo "request API!";
  }
?>
