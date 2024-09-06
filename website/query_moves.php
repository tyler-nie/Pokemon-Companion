<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <h2>Query Moves</h2>
        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        function createConditions() {
            $query = [];

            $moveNames = stringSanitize($_POST['moveNames']);

            if(isset($moveNames) && $moveNames != '') {
                $query[] = "MOVENAME LIKE '" . $moveNames . "'";
            }

            if(isset($_POST['movePower']) && $_POST['movePower'] != '') {
                $query[] = "POWER = " . $_POST['movePower'];
            }

            if(isset($_POST['moveAccuracy']) && $_POST['moveAccuracy'] != '') {
                $query[] = "ACCURACY = " . $_POST['moveAccuracy'];
            }

            if(isset($_POST['moveBasePP']) && $_POST['moveBasePP'] != '') {
                $query[] = "BASEPP = " . $_POST['moveBasePP'];
            }

            if(isset($_POST['moveCategory']) && $_POST['moveCategory'] != '') {
                $query[] = "CATEGORY LIKE '" . $_POST['moveCategory'] . "'";
            }

            if(isset($_POST['moveType']) && $_POST['moveType'] != '') {
                $query[] = "TYPENAME LIKE '" . $_POST['moveType'] . "'";
            }

            if (empty($query)) {
                return false;
            }

            $conditions = implode(' AND ', $query);

            if (isset($_SESSION['moveQuery']) && !empty($_SESSION['moveQuery'])) {
                $_SESSION['moveQuery'] .= ' OR (' . $conditions . ')';
            }
            else {
                $_SESSION['moveQuery'] = '(' . $conditions . ')';
            }

            return true;
        }

        function showSelection() {
            // NAME
            echo "<input type='text' name='moveNames' value=''>";

            // POWER
            echo "<select name='movePower' id='movePower'>";
            echo "<option value=''>--- Select a Power ---</option>";
            for ($i = 0; $i <= 250; $i += 5) {
                echo "<option value='$i'>$i</option>";
            }
            echo "</select>";

            // ACCURACY
            echo "<select name='moveAccuracy' id='moveAccuracy'>";
            echo "<option value=''>--- Select an Accuracy ---</option>";
            for ($i = 0; $i <= 100; $i += 5) {
                echo "<option value='$i'>$i</option>";
            }
            echo "</select>";

            // BASEPP
            echo "<select name='moveBasePP' id='moveBasePP'>";
            echo "<option value=''>--- Select a Base PP ---</option>";
            for ($i = 5; $i <= 40; $i += 5) {
                echo "<option value='$i'>$i</option>";
            }
            echo "</select>";

            // CATEGORY
            echo "<select name='moveCategory' id='moveCategory'>";
            echo "<option value=''>--- Select a Category ---</option>";
            echo "<option value='Physical'>Physical</option>";
            echo "<option value='Special'>Special</option>";
            echo "<option value='Status'>Status</option>";
            echo "</select>";

            // TYPE
            echo "<select name='moveType' id='moveType'>";
            echo "<option value=''>--- Select a Type ---</option>";
            echo "<option value='Normal'>Normal</option>";
            echo "<option value='Fire'>Fire</option>";
            echo "<option value='Water'>Water</option>";
            echo "<option value='Electric'>Electric</option>";
            echo "<option value='Grass'>Grass</option>";
            echo "<option value='Ice'>Ice</option>";
            echo "<option value='Fighting'>Fighting</option>";
            echo "<option value='Poison'>Poison</option>";
            echo "<option value='Ground'>Ground</option>";
            echo "<option value='Flying'>Flying</option>";
            echo "<option value='Phychic'>Phychic</option>";
            echo "<option value='Bug'>Bug</option>";
            echo "<option value='Rock'>Rock</option>";
            echo "<option value='Ghost'>Ghost</option>";
            echo "<option value='Dragon'>Dragon</option>";
            echo "<option value='Dark'>Dark</option>";
            echo "<option value='Steel'>Steel</option>";
            echo "<option value='Fairy'>Fairy</option>";
            echo "</select>";
        }

        if (connectToDB()) {
            echo "<form method='POST' action='query_moves.php'>";
            showSelection();
            echo "<br><input type='submit' value='Add to Query' name='querySubmit'>";
            echo "</form>";

            if (isset($_POST['querySubmit'])) {

                if (createConditions() || (isset($_SESSION['moveQuery']) && $_SESSION['moveQuery'] != '')) {

                    $move_result = executePlainSQL("SELECT MOVENAME, POWER, ACCURACY, BASEPP, CATEGORY, TYPENAME FROM MOVE WHERE " . $_SESSION['moveQuery']);

                    echo "<table>";
                    echo "<tr><th>MOVENAME</th><th>POWER</th><th>ACCURACY</th><th>BASEPP</th><th>CATEGORY</th><th>TYPENAME</th></tr>";
                    while ($move_row = OCI_Fetch_Array($move_result, OCI_ASSOC)) {
                        echo "<tr><td>" . implode("</td><td>", $move_row) . "</td></tr>";
                    }
                    echo "</table>";
                }
            }
            disconnectFromDB();
        }

        echo "<form method='POST' action='query_moves.php'>";
        echo "<br><input type='submit' value='Reset' name='reset'>";
        echo "</form>";

        if (isset($_POST['reset'])) {
            $_SESSION['moveQuery'] = '';
        }

        if (!isset($_SESSION['moveQuery']) || $_SESSION['moveQuery'] == '') {
            echo "Please select at least one value";
        }

        ?>
    </body>
</html>


