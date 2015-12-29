<?php

  if(isset($_POST["method"]))
  {
    include 'dbPDOController.php';
  
    $dbh = Db::getDBInstance();

    $JSONresult = array();
    switch(htmlspecialchars_decode($_POST["method"]))
    {
        case "getAll":
          $sql = "SELECT * FROM chatapp.users;";
          $JSONarray = array();
          foreach ($dbh->query($sql) as $row)
          {
                $jsonuser = array("username" => $row["username"]);
                $jsonuser["first_name"] = $row["first_name"];
                $jsonuser["last_name"] = $row["last_name"];
                $jsonuser["location"] = $row["location"];
                $jsonuser["on_line"] = $row["on_line"];
                $jsonuser["user_status_id"] = $row["user_status_id"];
                $jsonuser["user_type_id"] = $row["user_type_id"];
                array_push($JSONarray, $jsonuser);
          }
          $JSONresult = array("users" => $JSONarray);
          break;
        case "getUserInfo":
          if(isset($_POST['user_id']))
          {
            $sql = "SELECT username,first_name,last_name,location,on_line,user_status_id,user_type_id,email,birthdate FROM chatapp.users WHERE user_id = ?;";
            $stmt = $dbh->prepare($sql);
            if ($stmt->execute(array(htmlspecialchars_decode($_POST['user_id']))))
            {
              $row = $stmt->fetch();
              $jsonuser = array("username" => $row["username"]);
              $jsonuser["first_name"] = $row["first_name"];
              $jsonuser["last_name"] = $row["last_name"];
              $jsonuser["location"] = $row["location"];
              $jsonuser["on_line"] = $row["on_line"];
              $jsonuser["user_status_id"] = $row["user_status_id"];
              $jsonuser["user_type_id"] = $row["user_type_id"];
              $jsonuser["email"] = $row["email"];
              $jsonuser["birthdate"] = $row["birthdate"];
              $stm = $dbh->prepare("SELECT message_text,username FROM chatapp.messages, chatapp.users WHERE user_id = user_id_from AND is_public = true AND user_id_to = ?");
              if ($stm->execute(array(htmlspecialchars_decode($_POST['user_id']))))
              {
                $jsonpublicmessages = array();
                while($row_messages = $stm->fetch())
                {
                  $jsonpublicmessages["username"] = $row_messages["username"];
                  $jsonpublicmessages["message_text"] = $row_messages["message_text"];
                }
              }
              $jsonuser["public_messages"] = $jsonpublicmessages;
              $JSONresult = $jsonuser;
            }
          }
          break;
        case "changeUserStatus":
          $stmt = $dbh->prepare("UPDATE chatapp.users SET user_status_id = :status_id WHERE user_id = :us_id;");
          $stmt->bindParam(':status_id', htmlspecialchars_decode($_POST["new_status_id"]));
          $stmt->bindParam(':us_id', htmlspecialchars_decode($_POST["sender_user_id"]));

          $stmt->execute();
          break;
        case "registerUser":
          $stmt = $dbh->prepare("INSERT INTO chatapp.users(user_id, username, email, first_name, last_name, location, password, birthdate, on_line, user_status_id, user_type_id) VALUES(DEFAULT, :username, :email, :first_name, :last_name, :location, :password, :birthdate, FALSE, 1, 2);");
          $stmt->bindParam(':username', htmlspecialchars_decode($_POST["username"]));
          $stmt->bindParam(':email', htmlspecialchars_decode($_POST["email"]));
          $stmt->bindParam(':first_name', htmlspecialchars_decode($_POST["first_name"]));
          $stmt->bindParam(':last_name', htmlspecialchars_decode($_POST["last_name"]));
          $stmt->bindParam(':location', htmlspecialchars_decode($_POST["location"]));
          $stmt->bindParam(':password', htmlspecialchars_decode($_POST["password"]));
          $stmt->bindParam(':birthdate', htmlspecialchars_decode($_POST["birthdate"]));

          $stmt->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[2] == "7")
          {
            $JSONresult = array("errNo" => "Username or email already exist!");
          }
          else {
            $JSONresult = array("errNo" => "You registered succesfully!");
          }
          break;
        case "changeUsername":
          $stmt = $dbh->prepare("UPDATE chatapp.users SET username = :username WHERE user_id = :us_id;");
          $stmt->bindParam(':username', htmlspecialchars_decode($_POST["new_username"]));
          $stmt->bindParam(':us_id', htmlspecialchars_decode($_POST["sender_user_id"]));

          $stmt->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[2] == "7")
          {
            $JSONresult = array("errNo" => "Username already exists!");
          }
          else {
            $JSONresult = array("errNo" => "Username successfuly changed!");
          }
          break;
    }
    echo json_encode($JSONresult);
  }
  else
  {
    echo "Users API!";
  }
?>
