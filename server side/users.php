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
                $jsonuser["user_id"] = $row["user_id"];
                $jsonuser["first_name"] = $row["first_name"];
                $jsonuser["last_name"] = $row["last_name"];
                $jsonuser["location"] = $row["location"];
                $jsonuser["on_line"] = $row["on_line"];
                $jsonuser["imgUrl"] = $row["imgurl"];
                $jsonuser["user_status_id"] = $row["user_status_id"];
                $jsonuser["user_type_id"] = $row["user_type_id"];
                array_push($JSONarray, $jsonuser);
          }
          $JSONresult = array("users" => $JSONarray);
          break;
        case "changeUserStatus":
          $stmt = $dbh->prepare("UPDATE chatapp.users SET user_status_id = :status_id WHERE user_id = :us_id;");
          $stmt->bindParam(':status_id', htmlspecialchars_decode($_POST["new_status_id"]));
          $stmt->bindParam(':us_id', htmlspecialchars_decode($_POST["sender_user_id"]));

          $stmt->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[1] == "7")
          {
            $JSONresult = array("errNo" => $errArray[2]);
          }
          else {
            $JSONresult = array("errNo" => "200");
          }
          break;
        case "registerUser":
          $stmt = $dbh->prepare("INSERT INTO chatapp.users(user_id, username, first_name, last_name, location, password, on_line, user_status_id, user_type_id) VALUES(DEFAULT, :username, :first_name, :last_name, :location, :password, FALSE, 1, 2);");
          $stmt->bindParam(':username', htmlspecialchars_decode($_POST["username"]));
          $stmt->bindParam(':first_name', htmlspecialchars_decode($_POST["first_name"]));
          $stmt->bindParam(':last_name', htmlspecialchars_decode($_POST["last_name"]));
          $stmt->bindParam(':location', htmlspecialchars_decode($_POST["location"]));
          $stmt->bindParam(':password', htmlspecialchars_decode($_POST["password"]));

          $stmt->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[1] == "7")
          {
            $JSONresult = array("errNo" => $errArray[2]);
          }
          else {
            $JSONresult = array("errNo" => "200");
          }
          break;
        case "changeUsername":
          $stmt = $dbh->prepare("UPDATE chatapp.users SET username = :username WHERE user_id = :us_id;");
          $stmt->bindParam(':username', htmlspecialchars_decode($_POST["new_username"]));
          $stmt->bindParam(':us_id', htmlspecialchars_decode($_POST["sender_user_id"]));

          $stmt->execute();

          $errArray = $dbh->errorInfo();
          if($errArray[1] == "7")
          {
            $JSONresult = array("errNo" => $errArray[2]);
          }
          else {
            $JSONresult = array("errNo" => "200");
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
