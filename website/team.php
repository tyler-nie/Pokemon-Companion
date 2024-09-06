<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <h2>Pokemon Team</h2>

        <?php
        session_start();

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (connectToDB()) {
            $tuple = array (
                ":TeamID" => $_SESSION['selectedTeamID'],
                ":PokemonID" => $_POST['pokemonID'],
                ":PokemonSpecie" => $_POST['pokemonSpecie'],
                ":UserID" => $_SESSION['user_id']
            );

            $tuples = array (
                $tuple
            );

            if (isset($_POST['addPokemonFromTeamRequest'])) {
                $addPokemonResult = executeBoundSQL("SELECT COUNT(*) FROM BELONGSTO WHERE TEAMID = HEXTORAW(:TeamID)", $tuples);

                $pokemonCount = OCI_Fetch_Array($addPokemonResult, OCI_NUM);

                if ($pokemonCount[0] >= 6) {
                    echo "Maximum number of pokemon (6) cannot be exceeded!";
                }
                else {
                    executeBoundSQL("INSERT INTO BelongsTo VALUES (HEXTORAW(:TeamID), HEXTORAW(:PokemonID), :PokemonSpecie)", $tuples);
                    OCICommit($db_conn);

                    $pokemonNameResult = executeBoundSQL("SELECT POKEMONNAME FROM POKEMON WHERE POKEMONID = HEXTORAW(:PokemonID) AND SPECIENAME LIKE :PokemonSpecie", $tuples);
                    $pokemonName = OCI_Fetch_Array($pokemonNameResult, OCI_BOTH);
                    echo "Successfully added " . $pokemonName['POKEMONNAME'] . " to team!";
                }
            }

            if (isset($_POST['deletePokemonFromTeamRequest'])) {
                executeBoundSQL("DELETE FROM BelongsTo WHERE TEAMID= HEXTORAW(:TeamID) and POKEMONID= HEXTORAW(:PokemonID) and SPECIENAME LIKE :PokemonSpecie", $tuples);
                OCICommit($db_conn);

                $pokemonNameResult = executeBoundSQL("SELECT POKEMONNAME FROM POKEMON WHERE POKEMONID = HEXTORAW(:PokemonID) AND SPECIENAME LIKE :PokemonSpecie", $tuples);
                $pokemonName = OCI_Fetch_Array($pokemonNameResult, OCI_BOTH);
                echo "Successfully deleted " . $pokemonName['POKEMONNAME'] . " from team!";
            }

            $displayDeleteResult = executeBoundSQL("SELECT bt.SPECIENAME, p.POKEMONNAME, bt.POKEMONID, t.TEAMNAME
                                       FROM Team t, BelongsTo bt, Pokemon p 
                                       WHERE t.TEAMID = HEXTORAW(:TeamID) and t.TEAMID = bt.TEAMID and bt.POKEMONID = p.POKEMONID and bt.SPECIENAME LIKE p.SPECIENAME", $tuples);
        
            $teamResult = executeBoundSQL("SELECT TEAMNAME FROM TEAM WHERE TEAMID = HEXTORAW(:TeamID)", $tuples);
            $team = OCI_Fetch_Array($teamResult, OCI_BOTH);
        
            echo "<h3>" . $team['TEAMNAME'] . "</h3>";
            echo "<table>";
            echo "<tr><th>Specie Name</th><th>Pokemon Name</th></tr>";

            while ($row = OCI_Fetch_Array($displayDeleteResult, OCI_BOTH)) {
                echo "<tr><td>" . $row["SPECIENAME"] . "</td><td>" . $row["POKEMONNAME"] . "</td>";
                
                echo "<form method='POST' action='team.php'>";
                echo "<input type='hidden' id='deletePokemonFromTeamRequest' name='deletePokemonFromTeamRequest'>";
                echo "<input type='hidden' name='pokemonSpecie' value='" . $row["SPECIENAME"] . "'>";
                echo "<input type='hidden' name='pokemonID' value='" . bin2hex($row["POKEMONID"]) . "'>";
                echo "<td><input type='submit' value='Delete' name='deletePokemonSubmit'></td>";
                echo "</form>";

                echo "</tr>";
            }

            echo "</table>";

            $displayAddResult = executeBoundSQL("SELECT POKEMONID, SPECIENAME, POKEMONNAME 
                                       FROM Pokemon p 
                                       WHERE p.OWNERID = HEXTORAW(:UserID) 
                                            AND (p.POKEMONID, p.SPECIENAME) NOT IN (SELECT POKEMONID, SPECIENAME FROM BELONGSTO WHERE TEAMID = HEXTORAW(:TeamID))", $tuples);
        

            if (!isset($_POST['typeBreakdownSubmit'])) {
                echo "<form method='POST' action='team.php'>";
                echo "<td><input type='submit' value='Show Type Breakdown' name='typeBreakdownSubmit'></td>";
                echo "</form>";
            }
            else {
                echo "<h3>Type Breakdown</h3>";

                $result = executeBoundSQL("SELECT t.TYPENAME, COUNT(*) AS TYPECOUNT
                                           FROM BELONGSTO bt, POKEMON p, POKEMONTYPE pt, TYPE t
                                           WHERE bt.TEAMID = HEXTORAW(:TeamID) AND 
                                                 bt.POKEMONID = p.POKEMONID AND 
                                                 bt.SPECIENAME = p.SPECIENAME AND 
                                                 p.SPECIENAME = pt.SPECIENAME AND 
                                                 pt.TYPENAME = t.TYPENAME
                                           GROUP BY t.TYPENAME", $tuples);

                echo "<table>";
                echo "<tr><th>Type Name</th><th>Type Count</th></tr>";
        
                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo "<tr><td>" . $row["TYPENAME"] . "</td><td>" . $row["TYPECOUNT"] . "</td></tr>";
                }
        
                echo "</table>";
            }

            echo "<h3>Add Pokemon:</h3>";
            echo "<table>";
            echo "<tr><th>Specie Name</th><th>Pokemon Name</th></tr>";

            while ($row = OCI_Fetch_Array($displayAddResult, OCI_BOTH)) {
                echo "<tr><td>" . $row["SPECIENAME"] . "</td><td>" . $row["POKEMONNAME"] . "</td>";
                
                echo "<form method='POST' action='team.php'>";
                echo "<input type='hidden' id='addPokemonFromTeamRequest' name='addPokemonFromTeamRequest'>";
                echo "<input type='hidden' name='pokemonSpecie' value='" . $row["SPECIENAME"] . "'>";
                echo "<input type='hidden' name='pokemonID' value='" . bin2hex($row["POKEMONID"]) . "'>";
                echo "<td><input type='submit' value='Add Pokemon' name='addPokemonSubmit'></td>";
                echo "</form>";

                echo "</tr>";
            }

            echo "</table>";
        }

        ?>
    </body>
</html>


