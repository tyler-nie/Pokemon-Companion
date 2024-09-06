<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <h2>Opponent Team</h2>

        <?php
        session_start();

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (connectToDB()) {
            $tuple = array (
                ":TID" => $_SESSION['selectedTeamID']
            );

            $tuples = array (
                $tuple
            );

            $pokemonResult = executeBoundSQL("SELECT bt.SPECIENAME, p.POKEMONNAME, p.POKEMONLEVEL
                                       FROM Team t, BelongsTo bt, Pokemon p 
                                       WHERE t.TEAMID = HEXTORAW(:TID) and t.TEAMID = bt.TEAMID and bt.POKEMONID = p.POKEMONID and bt.SPECIENAME LIKE p.SPECIENAME", $tuples);

            $teamResult = executeBoundSQL("SELECT TEAMNAME FROM TEAM WHERE TEAMID = HEXTORAW(:TID)", $tuples);
            $team = OCI_Fetch_Array($teamResult, OCI_BOTH);
        
            echo "<h3>" . $team['TEAMNAME'] . "</h3>";
            echo "<table>";
            echo "<tr><th>Specie Name</th><th>Pokemon Name</th><th>Pokemon Level</th></tr>";
            while ($row = OCI_Fetch_Array($pokemonResult, OCI_BOTH)) {
                echo "<tr><td>" . $row["SPECIENAME"] . "</td><td>" . $row["POKEMONNAME"] . "</td><td>" . $row["POKEMONLEVEL"] . "</td>";

                echo "</tr>";
            }
            echo "</table>";

            disconnectFromDB();
        }

        ?>
    </body>
</html>


