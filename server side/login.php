<?php

  if(isset($_POST["method"]))
  {
    $userId = htmlspecialchars_decode($_POST['sender_user_id']);
    include 'dbPDOController.php';

    $dbh = Db::getDBInstance();

    $JSONresult = array();

    $sql = "UPDATE chatapp.users SET on_line = :login WHERE user_id = :us_id";
    $stmt = $dbh->prepare($sql);
    switch(htmlspecialchars_decode($_POST["method"]))
    {
        case "logIn":
          $stmt->bindParam(':login', true);
          break;

        case "logOut":
          $stmt->bindParam(':login', false);
          break;
    }
    $stmt->bindParam(':us_id', $userId);
    $stmt->execute();
    $JSONresult = array("errNo" => "200");

    #TO DO: MAYBE ADD ERROR HANDLING

    echo json_encode($JSONresult);
  }
  else
  {
    echo "LOGIN!";
  }
?>
