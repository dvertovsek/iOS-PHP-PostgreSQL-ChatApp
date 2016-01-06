<?php

  function getMessages($sender_user_id, $user_id, $dbh)
  {
    $sql = "SELECT imgurl, username, message_text, to_char(time_sent, 'HH24:MI, Mon DD,YYYY') AS time_sended FROM chatapp.messages JOIN chatapp.users ON(user_id = user_id_from) WHERE user_id_from = ? AND user_id_to = ? OR user_id_from = ? AND user_id_to = ? AND is_public = false ORDER by time_sent ASC;";

    $stm = $dbh->prepare($sql);
    $JSONarray = array();

    $us_id = htmlspecialchars_decode($_POST['user_id']);
    $sender_id = htmlspecialchars_decode($_POST['sender_user_id']);
    if ($stm->execute(array($us_id, $sender_id, $sender_id, $us_id)))
    {
      while($row_messages = $stm->fetch())
      {
        $jsonprivatemessages = array("username_from" => $row_messages["username"]);
        $jsonprivatemessages["message_text"] = $row_messages["message_text"];
        $jsonprivatemessages["imgUrl"] = $row_messages["imgurl"];
        $jsonprivatemessages["time_sent"] = $row_messages["time_sended"];
        array_push($JSONarray, $jsonprivatemessages);
      }
    }
    return $JSONarray;
  }

  function getPublicMessages($user_id, $dbh)
  {
    $sql = "SELECT imgurl, username, message_text, to_char(time_sent, 'HH24:MI, Mon DD,YYYY') AS time_sended FROM chatapp.messages JOIN chatapp.users ON(user_id = user_id_from) WHERE  user_id_to = ?  AND is_public = true ORDER BY time_sent ASC;";

    $stm = $dbh->prepare($sql);
    $JSONarray = array();

    if ($stm->execute(array($user_id)))
    {
      while($row_messages = $stm->fetch())
      {
        $jsonpublicmessages = array("username_from" => $row_messages["username"]);
        $jsonpublicmessages["imgUrl"] = $row_messages["imgurl"];
        $jsonpublicmessages["message_text"] = $row_messages["message_text"];
        $jsonpublicmessages["time_sent"] = $row_messages["time_sended"];
        array_push($JSONarray, $jsonpublicmessages);
      }
    }
    return $JSONarray;
  }

  if(isset($_POST["method"]))
  {
    include 'dbPDOController.php';

    $dbh = Db::getDBInstance();

    $JSONresult = array();
    switch(htmlspecialchars_decode($_POST["method"]))
    {
        case "getAll":
          $JSONresult = array("messages" => getMessages(htmlspecialchars_decode($_POST["sender_user_id"]),htmlspecialchars_decode($_POST["user_id"]),$dbh));
          $JSONresult["errNo"] = "200";
          break;
        case 'getAllPublic':
          $JSONresult = array("errNo" => "200");
          $JSONresult["messages"] = getPublicMessages(htmlspecialchars_decode($_POST["user_id"]),$dbh);
          break;
        case "sendPrivateMessage":
          $sql = "INSERT INTO chatapp.messages(message_id,user_id_from,user_id_to,message_text,is_public,time_sent) VALUES(DEFAULT,:user_from,:user_to,:msg_txt,FALSE,DEFAULT);";

          $stm = $dbh->prepare($sql);

          $sender_user_id = htmlspecialchars_decode($_POST["sender_user_id"]);
          $user_id = htmlspecialchars_decode($_POST["user_id"]);

          $stm->bindParam(':user_from', $sender_user_id);
          $stm->bindParam(':user_to', $user_id);
          $stm->bindParam(':msg_txt', htmlspecialchars_decode($_POST["message_text"]));

          $stm->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[1] == "7")
          {
            $JSONresult = array("errNo" => $errArray[2]);
          }
          else {
            $JSONresult = array("errNo" => "200");
            $JSONresult["messages"] = getMessages($sender_user_id, $user_id, $dbh);
          }
          break;

        case "sendPublicMessage":
          $sql = "INSERT INTO chatapp.messages(message_id,user_id_from,user_id_to,message_text,is_public,time_sent) VALUES(DEFAULT,:user_from,:user_to,:msg_txt,TRUE,DEFAULT);";
          $stm = $dbh->prepare($sql);

          $sender_user_id = htmlspecialchars_decode($_POST["sender_user_id"]);
          $user_id = htmlspecialchars_decode($_POST["user_id"]);

          $stm->bindParam(':user_from', $sender_user_id);
          $stm->bindParam(':user_to', $user_id);
          $stm->bindParam(':msg_txt', htmlspecialchars_decode($_POST["message_text"]));

          $stm->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[1] == "7")
          {
            $JSONresult = array("errNo" => $errArray[2]);
          }
          else {
            $JSONresult = array("errNo" => "200");
            $JSONresult["messages"] = getPublicMessages($user_id, $dbh);
          }
          break;
    }
    echo json_encode($JSONresult);
  }
  else
  {
    echo "Messages API!";
  }
?>
