<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        
        <h2>Opponent Teams</h2>

        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (connectToDB()) {

            $trainerTuple = array ();
            $trainerTuples = array ( $trainerTuple );

            $trainerResult = executeBoundSQL("SELECT pt.TRAINERID, pt.TRAINERNAME, o.TRAINERCLASS FROM OPPONENT o, POKEMONTRAINER pt WHERE o.TRAINERID = pt.TRAINERID", $trainerTuples);

            echo "<form method='POST' action='opponents.php'>";
            echo "<input type='radio' name='filter' value='levelFilter'>Filter Teams Higher Leveled Than Your Highest Leveled Team<br>";
            echo "<input type='radio' name='filter' value='movePowerFilter'>Filter Teams With Higher Average Move Power";
            echo "<input type='text' id='movePower' name='movePower' value=''><br>";
            echo "<select name='trainer' id='trainer'>";
            echo "<option value=''>--- Select a Trainer ---</option>";
            while ($trainer = OCI_Fetch_Array($trainerResult, OCI_BOTH)) {
                echo "<option value='" . bin2hex($trainer['TRAINERID']) . "'>" . $trainer['TRAINERNAME'] . "</option>";
            }
            echo "</select>";
            echo "<br><input type='submit' value='Select Trainer' name='trainerSelect'>";
            echo "</form>";

            if (isset($_POST['trainerSelect'])) {
                if (!isset($_POST['trainer']) || $_POST['trainer'] == '') {
                    echo "Please select a trainer";
                }
                else {
                    if (!isset($_POST['filter'])) {
                        $trainerTeamTuple = array (
                            ":TrainerID" => $_POST['trainer']
                        );

                        $trainerTeamTuples = array (
                            $trainerTeamTuple
                        );

                        $trainerTeamResult = executeBoundSQL("SELECT TEAMID, TEAMNAME FROM TEAM WHERE TRAINERID = HEXTORAW(:TrainerID)", $trainerTeamTuples);
                    
                        echo "<h3>All Teams</h3>";
                        echo "<table>";
                        echo "<tr><th>Name</th></tr>";

                        while ($team = OCI_Fetch_Array($trainerTeamResult, OCI_BOTH)) {
                            echo "<tr><td>" . $team["TEAMNAME"] . "</td>";

                            echo "<form method='POST'>";
                            echo "<input type='hidden' name='goToTeamRequest' value='" . bin2hex($team["TEAMID"]) . "'>";
                            echo "<td><input type='submit' value='Go To Team' name='goToTeamSubmit'></td>";
                            echo "</form>";

                            echo "</tr>";
                        }

                        echo "</table>";
                    }

                    elseif ($_POST['filter'] == 'levelFilter') {
                        $userTrainerTeamTuple = array (
                            ":TrainerID" => $_POST['trainer'],
                            ":UserID" => $_SESSION['user_id']
                        );
        
                        $userTrainerTeamTuples = array (
                            $userTrainerTeamTuple
                        );
        
                        $userTrainerTeamResult = executeBoundSQL("SELECT t.TEAMID
                                                                  FROM TEAM t, BELONGSTO bt, POKEMON p
                                                                  WHERE t.TEAMID = bt.TEAMID AND 
                                                                        bt.POKEMONID = p.POKEMONID AND 
                                                                        bt.SPECIENAME LIKE p.SPECIENAME AND
                                                                        t.TRAINERID = HEXTORAW(:TrainerID)
                                                                  GROUP BY t.TEAMID
                                                                  HAVING AVG(p.POKEMONLEVEL) > all (SELECT AVG(p.POKEMONLEVEL)
                                                                                                    FROM TEAM t, BELONGSTO bt, POKEMON p
                                                                                                    WHERE t.TEAMID = bt.TEAMID AND 
                                                                                                          bt.POKEMONID = p.POKEMONID AND 
                                                                                                          bt.SPECIENAME LIKE p.SPECIENAME AND
                                                                                                          t.TRAINERID = HEXTORAW(:UserID)
                                                                                                    GROUP BY t.TEAMID)", $userTrainerTeamTuples);
                    
                        echo "<h3>All Teams</h3>";
                        echo "<table>";
                        echo "<tr><th>Name</th></tr>";
        
                        while ($team = OCI_Fetch_Array($userTrainerTeamResult, OCI_BOTH)) {
                            $teamNameTuple = array (
                                ":TeamID" => bin2hex($team['TEAMID'])
                            );
                            $teamNameTuples = array (
                                $teamNameTuple
                            );

                            $teamNameResult = executeBoundSQL("SELECT TEAMNAME FROM TEAM WHERE TEAMID = HEXTORAW(:TeamID)", $teamNameTuples);
                            $teamName = OCI_Fetch_Array($teamNameResult, OCI_BOTH);

                            echo "<tr><td>" . $teamName["TEAMNAME"] . "</td>";
        
                            echo "<form method='POST'>";
                            echo "<input type='hidden' name='goToTeamRequest' value='" . bin2hex($team["TEAMID"]) . "'>";
                            echo "<td><input type='submit' value='Go To Team' name='goToTeamSubmit'></td>";
                            echo "</form>";
        
                            echo "</tr>";
                        }
        
                        echo "</table>";
                    }

                    elseif ($_POST['filter'] == 'movePowerFilter') {
                        if (!isset($_POST['movePower']) || $_POST['movePower'] == '' || !is_numeric($_POST['movePower'])) {
                            echo "Please enter valid power level integer (ex: 10)";
                        }

                        else {
                            $movePower = stringSanitize($_POST['movePower']);
                            $moveTrainerTeamTuple = array (
                                ":TrainerID" => $_POST['trainer'],
                                ":MovePower" => intval($movePower)
                            );
            
                            $moveTrainerTeamTuples = array (
                                $moveTrainerTeamTuple
                            );

                            $moveTrainerTeamResult = executeBoundSQL("SELECT t.TEAMID
                                                                    FROM TEAM t, BELONGSTO bt, POKEMON p, MOVE m, HASMOVE hm
                                                                    WHERE t.TEAMID = bt.TEAMID AND 
                                                                            bt.POKEMONID = p.POKEMONID AND 
                                                                            bt.SPECIENAME LIKE p.SPECIENAME AND
                                                                            p.POKEMONID = hm.POKEMONID AND 
                                                                            p.SPECIENAME LIKE hm.SPECIENAME AND
                                                                            hm.MOVENAME = m.MOVENAME AND
                                                                            t.TRAINERID = HEXTORAW(:TrainerID)
                                                                    GROUP BY t.TEAMID
                                                                    HAVING AVG(m.POWER) > :MovePower", $moveTrainerTeamTuples);

                            echo "<h3>All Teams</h3>";
                            echo "<table>";
                            echo "<tr><th>Name</th></tr>";
            
                            while ($team = OCI_Fetch_Array($moveTrainerTeamResult, OCI_BOTH)) {
                                $teamNameTuple = array (
                                    ":TeamID" => bin2hex($team['TEAMID'])
                                );
                                $teamNameTuples = array (
                                    $teamNameTuple
                                );

                                $teamNameResult = executeBoundSQL("SELECT TEAMNAME FROM TEAM WHERE TEAMID = HEXTORAW(:TeamID)", $teamNameTuples);
                                $teamName = OCI_Fetch_Array($teamNameResult, OCI_BOTH);

                                echo "<tr><td>" . $teamName["TEAMNAME"] . "</td>";
            
                                echo "<form method='POST'>";
                                echo "<input type='hidden' name='goToTeamRequest' value='" . bin2hex($team["TEAMID"]) . "'>";
                                echo "<td><input type='submit' value='Go To Team' name='goToTeamSubmit'></td>";
                                echo "</form>";
            
                                echo "</tr>";
                            }
            
                            echo "</table>";
                        }
                    }
                }
            }

            if (isset($_POST['goToTeamSubmit'])) {
                $_SESSION['selectedTeamID'] = $_POST['goToTeamRequest'];
                header("Location: opponent_team.php");
                exit();
            }

            disconnectFromDB();
        }

        ?>
    </body>
</html>


