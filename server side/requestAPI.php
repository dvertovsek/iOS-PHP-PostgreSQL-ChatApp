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
        if($errArray[2] == "7")
        {
          $JSONresult = array("errNo" => $errArray[3]);
        }
        else {
          $JSONresult = array("errNo" => "Request successfuly sent!");
        }
        break;

      case "getAll":
        $sql = "SELECT username,location,time_sent,hello_message FROM chatapp.requests JOIN chatapp.users ON(user_id_from = user_id) WHERE user_id_to = ?";
        $stmt = $dbh->prepare($sql);

        $JSONarray = array();
        if ($stmt->execute(array(htmlspecialchars_decode($_POST['sender_user_id']))))
        {
          while($row = $stmt->fetch())
          {
            $jsonrequest = array("username" => $row["username"]);
            $jsonrequest["time_sent"] = $row["time_sent"];
            $jsonrequest["hello_message"] = $row["hello_message"];
            $jsonrequest["location"] = $row["location"];
            array_push($JSONarray, $jsonrequest);
          }
          $JSONresult = array("requests" => $JSONarray);
        }
        break;

      case "updateRequest":
        $sql = "UPDATE chatapp.requests SET accepted = :accepted WHERE user_id_from = :user_from AND user_id_to = :user_to AND accepted IS NULL;";
        $stmt = $dbh->prepare($sql);
        $stmt->bindParam(':user_from', htmlspecialchars_decode($_POST["user_id"]));
        $stmt->bindParam(':user_to', htmlspecialchars_decode($_POST["sender_user_id"]));
        $stmt->bindParam(':accepted', htmlspecialchars_decode($_POST["isAccepted"]));

        $stmt->execute();

        // $ret_message = "";
        switch htmlspecialchars_decode($_POST["isAccepted"])
        {
          case true:
            $ret_message = "You accepted friend request!";
            break;
          case false:
            $ret_message = "You denied friend request!";
            break;
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
