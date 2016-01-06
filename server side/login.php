<?php

  if(isset($_POST["method"]))
  {
    $username = htmlspecialchars_decode($_POST['username']);
    include 'dbPDOController.php';

    $dbh = Db::getDBInstance();

    $JSONresult = array();


    switch(htmlspecialchars_decode($_POST["method"]))
    {
        case "logIn":

          $stm = $dbh->prepare("SELECT user_id,password,imgurl,user_type_id,user_status_id FROM chatapp.users WHERE username = ?;");
          if ($stm->execute(array($username)))
          {
            if($row = $stm->fetch())
            {
              if($row["password"] == htmlspecialchars_decode($_POST["password"]))
              {
                $sql = "UPDATE chatapp.users SET on_line = true WHERE username = :user AND user_id != 1";
                $stmt = $dbh->prepare($sql);
                $stmt->bindParam('user', $username);

                $stmt->execute();
                $errArray = $dbh->errorInfo();
                if($errArray[1] == "7")
                {
                  $JSONresult = array("errNo" => $errArray[2]);
                }
                else{
                  $JSONresult["errNo"] = "200";
                  $JSONresult["user_id"] = $row["user_id"];
                  $JSONresult["imgUrl"] = $row["imgurl"];
                  $JSONresult["user_type_id"] = $row["user_type_id"];
                  $JSONresult["user_status_id"] = $row["user_status_id"];
                }

              }
              else{
                $JSONresult["errNo"] = "Wrong password!";
              }
            }
            else {
              $JSONresult["errNo"] = "Non existing user!";
            }
          }
          break;

        case "logOut":
          $sql = "UPDATE chatapp.users SET on_line = false WHERE username = :user";
          $stmt = $dbh->prepare($sql);
          $stmt->bindParam(':user', $username);

          $stmt->execute();
          $JSONresult["errNo"] = "200";
          break;

        case "appLog":
          $sql = "SELECT imgurl,username,description,to_char(log_time, 'HH24:MI, Mon DD,YYYY') AS log_time from chatapp.users JOIN chatapp.log USING(user_id);";
          $JSONarray = array();
          foreach ($dbh->query($sql) as $row)
          {
                $jsonuser = array("username" => $row["username"]);
                $jsonuser["imgUrl"] = $row["imgurl"];
                $jsonuser["description"] = $row["description"];
                $jsonuser["log_time"] = $row["log_time"];
                array_push($JSONarray, $jsonuser);
          }
          $JSONresult = array("log" => $JSONarray);
          break;
    }

    echo json_encode($JSONresult);
  }
  else
  {
    echo "LOGIN!";
  }
?>
