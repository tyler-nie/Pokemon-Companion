<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        
        <h2>Pokemon Teams</h2>

        <h3>Create New Team</h3>
        <form method="POST" action="teams.php">
            <label for="teamname">Team name:</label><br>
            <input type="text" id="teamname" name="teamname" value=""><br>
            <input type="hidden" id="insertTeamRequest" name="insertTeamRequest">
            <input type="submit" value="Insert" name="insertSubmit"></p>
        </form>

        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';
        
        function handleInsertTeamRequest() {
            global $db_conn;
        
            if (isset($_POST['insertSubmit'])) {
        
                $teamname = stringSanitize($_POST['teamname']);

                // Check if the teamname is not empty
                if (!empty($teamname)) {
        
                    $tuple = array (
                        ":TeamName" => $teamname,
                        ":UserID" => $_SESSION['user_id']
                    );

                    $tuples = array (
                        $tuple
                    );

                    // Insert the new team into the Team table
                    executeBoundSQL("INSERT INTO Team (TeamID, TeamName, TrainerID) VALUES (SYS_GUID(), :TeamName, :UserID)", $tuples);
                    OCICommit($db_conn);
                    echo "<br>Inserted new team successfully!<br>";
                } else {
                    echo "<br>Team name cannot be empty. Please enter a team name.<br>";
                }
            }
        }

        function handleDeleteTeamRequest() {
            global $db_conn;
        
            if (isset($_POST['deleteSubmit'])) {
        
                $tuple = array (
                    ":TID" => $_POST['deleteTeamRequest']
                );

                $tuples = array (
                    $tuple
                );

                // delete the Pokemon team from the Team table
                executeBoundSQL("DELETE FROM Team WHERE TEAMID= HEXTORAW(:TID)", $tuples);
                OCICommit($db_conn);

                echo "Team deleted successfully!";
            }
        }

        function displayAllTeams() {
            if (connectToDB()) {

                $tuple = array (
                    ":UserID" => $_SESSION['user_id']
                );

                $tuples = array (
                    $tuple
                );

                $result = executeBoundSQL("SELECT * FROM Team WHERE TRAINERID = :UserID", $tuples);
            
                echo "<h3>All Teams</h3>";
                echo "<table>";
                echo "<tr><th>Name</th></tr>";

                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo "<tr><td>" . $row["TEAMNAME"] . "</td>";
                    
                    // Does nothing rn
                    echo "<form method='POST' action='teams.php'>";
                    echo "<input type='hidden' name='deleteTeamRequest' value='" . bin2hex($row["TEAMID"]) . "'>";
                    echo "<td><input type='submit' value='Delete' name='deleteSubmit'></td>";
                    echo "</form>";

                    echo "<form method='POST'>";
                    echo "<input type='hidden' name='goToTeamRequest' value='" . bin2hex($row["TEAMID"]) . "'>";
                    echo "<td><input type='submit' value='Go To Team' name='goToTeamSubmit'></td>";
                    echo "</form>";

                    echo "</tr>";
                }

                echo "</table>";

                disconnectFromDB();
            }
        }

        // HANDLE ALL POST ROUTES
        // A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handlePOSTRequest() {
            if (connectToDB()) {
                if (array_key_exists('resetTablesRequest', $_POST)) {
                    handleResetRequest();
                } else if (array_key_exists('updateQueryRequest', $_POST)) {
                    handleUpdateRequest();
                } else if (array_key_exists('insertTeamRequest', $_POST)) {
                    handleInsertTeamRequest();
                } else if (array_key_exists('deleteTeamRequest', $_POST)) {
                    handleDeleteTeamRequest();
                } else if (array_key_exists('goToTeamRequest', $_POST)) {
                    $_SESSION['selectedTeamID'] = $_POST['goToTeamRequest'];
                    header("Location: team.php");
                    exit();
                }

                disconnectFromDB();
            }
        }

        if (isset($_POST['reset']) || 
            isset($_POST['updateSubmit']) || 
            isset($_POST['insertSubmit']) ||
            isset($_POST['deleteSubmit']) ||
            isset($_POST['goToTeamSubmit'])) {
            handlePOSTRequest();
        } 

        displayAllTeams();
        ?>
    </body>
</html>


