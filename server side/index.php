<?php
    include 'dbPDOController.php';

    $dbh = Db::getDBInstance();

    $sql = 'SELECT NOW() AT TIME ZONE \'Europe/Paris\';';
    foreach ($dbh->query($sql) as $row)
    {
        print $row['timezone'] . "\n";
    }
?>
