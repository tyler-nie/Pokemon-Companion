<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <h2>Pokemons</h2>
        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        function handleAddPokemonRequest() {
            global $db_conn;

            $valid_input = true;

            $pokemonname = stringSanitize($_POST['pokemonname']);
            $level = stringSanitize($_POST['level']);

            if (!isset($pokemonname) || $pokemonname == '') {
                echo "Please enter a valid pokemon name<br>";
                $valid_input = false;
            }
            if (!isset($level) || $level == '' || !is_numeric($level) || intval($level) < 0) {
                echo "Please enter a valid positive integer level<br>";
                $valid_input = false;
            }
            if (!isset($_POST['gender']) || $_POST['gender'] == '') {
                echo "Please enter a gender<br>";
                $valid_input = false;
            }
            if (!isset($_POST['speciename']) || $_POST['speciename'] == '') {
                echo "Please enter a specie<br>";
                $valid_input = false;
            }
            if (!isset($_POST['ability']) || $_POST['ability'] == '') {
                echo "Please enter an ability<br>";
                $valid_input = false;
            }
            if (!isset($_POST['item']) || $_POST['item'] == '') {
                echo "Please enter an item<br>";
                $valid_input = false;
            }

            if ($valid_input) {
                $tuple = array (
                    ":PokemonName" => $pokemonname,
                    ":Gender" => $_POST['gender'],
                    ":SpecieName" => $_POST['speciename'],
                    ":AbilityName" => $_POST['ability'],
                    ":ItemName" => $_POST['item'],
                    ":OwnerID" => $_SESSION['user_id'],
                    ":PokemonLevel" => intval($level)
                );

                $alltuples = array (
                    $tuple
                );

                executeBoundSQL("INSERT INTO Pokemon VALUES (SYS_GUID(), :PokemonName, :Gender, :SpecieName, :AbilityName, :ItemName, :PokemonLevel, HEXTORAW(:OwnerID))", $alltuples);
                OCICommit($db_conn);

                echo "Successfully created pokemon!";
            }
        }

        function handleCountRequest() {
            global $db_conn;

            $result = executePlainSQL("SELECT Count(*) FROM Pokemon");

            if (($row = oci_fetch_row($result)) != false) {
                echo "<br> The number of tuples in Pokemon: " . $row[0] . "<br>";
            }
        }

        function allPokemon() {
            if (connectToDB()) {

                $tuple = array (
                    ":UserID" => $_SESSION['user_id']
                );

                $tuples = array (
                    $tuple
                );

                $result = executeBoundSQL("SELECT SPECIENAME, POKEMONNAME, POKEMONID FROM Pokemon p WHERE p.OWNERID = HEXTORAW(:UserID)", $tuples);
            
                echo "<table>";
                echo "<tr><th>Specie Name</th><th>Pokemon Name</th></tr>";

                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo "<tr><td>'" . $row["SPECIENAME"] . "'</td><td>" . $row["POKEMONNAME"] . "</td>";
                    echo "<form method='POST'>";
                    echo "<input type='hidden' name='editPokemonID' value='" . bin2hex($row["POKEMONID"]) . "'>";
                    echo "<input type='hidden' name='editPokemonSpecie' value='" . $row["SPECIENAME"] . "'>";
                    echo "<td><input type='submit' value='Edit Pokemon' name='editPokemonSubmit'></td>";
                    echo "</form>";

                    echo "</tr>";
                }

                echo "</table>";

                disconnectFromDB();
            }
        }

        function createForm() {
            echo "<h3>New Pokemon</h3>";
            echo "<form method='POST' action='pokemons.php'>";
            echo specieSelect();
            echo "<label for='pokemonname'>Pokemon name:</label><br>";
            echo "<input type='text' id='pokemonname' name='pokemonname' value=''><br>";
            echo "<label for='gender'>Gender: </label><br>";
            echo "<select name='gender' id='gender'>";
            echo "<option value=''>--- Select a gender ---</option>";
            echo "<option value='F'>F</option>";
            echo "<option value='M'>M</option>";
            echo "<option value='U'>U</option>";
            echo "</select> <br>\n";
            echo abilityDropdown();
            echo itemDropdown();
            echo "<label for='level'>Pokemon level:</label><br>";
            echo "<input type='text' id='level' name='level' value=''><br>";
            echo "<input type='hidden' id='addPokemonRequest' name='addPokemonRequest'>";
            echo "<input type='submit' value='Add' name='addSubmit'></p>";
            echo "</form>";
        }

        // specie selection menu
        function specieSelect(){
            if (connectToDB()) {
                $result = executePlainSQL("SELECT EVOLVINGINTOSPECIENAME FROM PokemonSpecies ORDER BY EvolvingIntoSpecieName ASC");
                echo "<label for='speciename'>Specie: </label><br>";
                echo "<select name='speciename' id='speciename'>";
                echo "<option value=''>--- Select a Specie ---</option>";
                
                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo  $row["EVOLVINGINTOSPECIENAME"] . "<br>\n";
                    echo "<option value='" . $row["EVOLVINGINTOSPECIENAME"] ."'>" . $row["EVOLVINGINTOSPECIENAME"] . "</option>";
                }
                echo "</select> <br>";  

                disconnectFromDB();
            }
        }

        // ability dropdown menu
        function abilityDropdown() {
            if (connectToDB()) {
                $result = executePlainSQL("SELECT ABILITYNAME FROM Ability ORDER BY AbilityName ASC");
                echo "<label for='ability'>Ability: </label><br>";
                echo "<select name='ability' id='ability'>";
                echo "<option value=''>--- Select a ability ---</option>";
                
                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo  $row["ABILITYNAME"] . "<br>\n";
                    echo "<option value='" . $row["ABILITYNAME"] . "'>" . $row["ABILITYNAME"] . "</option>";
                }
                echo "</select> <br>";

                disconnectFromDB();
            }
        }

        // item dropdown menu
        function itemDropdown() {
            if (connectToDB()) {
                $result = executePlainSQL("SELECT ITEMNAME FROM Item ORDER BY ItemName ASC");
                echo "<label for='item'>Item: </label><br>";
                echo "<select name='item' id='item'>";
                echo "<option value=''>--- Select a item ---</option>";
                
                while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                    echo  $row["ITEMNAME"] . "<br>\n";
                    echo "<option value='" . $row["ITEMNAME"] . "'>" . $row["ITEMNAME"] . "</option>";
                }
                echo "</select> <br>";

                disconnectFromDB();
            }
        }

        // HANDLE ALL POST ROUTES
        // A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handlePOSTRequest() {
            if (connectToDB()) {
                if (array_key_exists('addPokemonRequest', $_POST)) {
                    handleAddPokemonRequest();
                } else if (array_key_exists('editPokemonID', $_POST) && array_key_exists('editPokemonSpecie', $_POST)) {
                    $_SESSION['selectedPokemonID'] = $_POST['editPokemonID'];
                    $_SESSION['selectedPokemonSpecie'] = $_POST['editPokemonSpecie'];

                    header("Location: pokemon.php");
                    exit();
                }

                disconnectFromDB();
            }
        }

        // HANDLE ALL GET ROUTES
        // A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handleGETRequest() {
            if (connectToDB()) {
                handleCountRequest();

                disconnectFromDB();
            }
        }

        if (isset($_POST['addSubmit']) ||
            isset($_POST['editPokemonSubmit'])) {
            handlePOSTRequest();
        } 
        // else if (isset($_GET['countTupleRequest'])) {
        // }
        createForm();
        allPokemon();
        //handleGETRequest();
        ?>
    </body>
</html>


