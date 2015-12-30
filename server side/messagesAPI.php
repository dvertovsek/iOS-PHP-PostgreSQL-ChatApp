<?php

  function getMessages($sender_user_id, $user_id, $dbh)
  {
    $sql = "SELECT username, message_text, time_sent FROM chatapp.messages JOIN chatapp.users ON(user_id = user_id_from) WHERE user_id_from = ? AND user_id_to = ? OR user_id_from = ? AND user_id_to = ?;";

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
        $jsonprivatemessages["time_sent"] = $row_messages["time_sent"];
        array_push($JSONarray, $jsonprivatemessages);
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
          $JSONresult = array("private_messages" => getMessages(htmlspecialchars_decode($_POST["sender_user_id"]),htmlspecialchars_decode($_POST["user_id"]),$dbh));
          break;

        case "sendPrivateMessage":
          $sql = "INSERT INTO chatapp.messages(message_id,user_id_from,user_id_to,message_text,is_public,time_sent) VALUES(DEFAULT,:user_from,:user_to,:msg_txt,FALSE,DEFAULT);";
          echo $sql;
          $stm = $dbh->prepare($sql);

          $sender_user_id = htmlspecialchars_decode($_POST["sender_user_id"]);
          $user_id = htmlspecialchars_decode($_POST["user_id"]);

          $stm->bindParam(':user_from', $sender_user_id);
          $stm->bindParam(':user_to', $user_id);
          $stm->bindParam(':msg_txt', htmlspecialchars_decode($_POST["message_text"]));

          $stm->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[2] == "7")
          {
            $JSONresult = array("errNo" => $errArray[3]);
          }
          else {
            $JSONresult = array("errNo" => "200");
            $JSONresult["private_messages"] = getMessages($sender_user_id, $user_id, $dbh);
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
