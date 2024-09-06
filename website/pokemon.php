<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <h2>Pokemon</h2>
        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require "helpers.php";

        if (connectToDB()){
            if (isset($_POST['saveSubmit'])) {
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
                if (!isset($_POST['ability']) || $_POST['ability'] == '') {
                    echo "Please enter an ability<br>";
                    $valid_input = false;
                }
                if (!isset($_POST['item']) || $_POST['item'] == '') {
                    echo "Please enter an item<br>";
                    $valid_input = false;
                }

                if ($valid_input) {
                    $saveTuple = array (
                        ":PID" => $_SESSION['selectedPokemonID'],
                        ":PName" => $pokemonname,
                        ":PGender" => $_POST['gender'],
                        ":PSpecieName" => $_SESSION['selectedPokemonSpecie'],
                        ":PAbilityName" => $_POST['ability'],
                        ":PItemName" => $_POST['item'],
                        ":PLevel" => intval($level)
                    );
        
                    $saveTuples = array (
                        $saveTuple
                    );
        
                    executeBoundSQL("UPDATE Pokemon 
                                    SET 
                                    PokemonName = :PName,
                                    Gender = :PGender,
                                    AbilityName = :PAbilityName,
                                    ItemName = :PItemName,
                                    PokemonLevel = :PLevel
                                    WHERE PokemonID = HEXTORAW(:PID)
                                    AND SpecieName LIKE :PSpecieName", $saveTuples);
                    OCICommit($db_conn);

                    echo "Successfully updated pokemon!";
                }
            }

            if (isset($_POST['deleteMoveSubmit'])) {
                $deleteMoveTuple = array (
                    ":PokemonID" => $_SESSION['selectedPokemonID'],
                    ":SpecieName" => $_SESSION['selectedPokemonSpecie'],
                    ":MoveName" => $_POST['moveName']
                );
            
                $deleteMoveTuples = array (
                    $deleteMoveTuple
                );
            
                executeBoundSQL("DELETE FROM HasMove WHERE POKEMONID = HEXTORAW(:PokemonID) AND SPECIENAME LIKE :SpecieName AND MOVENAME = :MoveName", $deleteMoveTuples);
                OCICommit($db_conn);

                echo "Successfully deleted " . $_POST['moveName'] . " from pokemon!";
            }

            if (isset($_POST['addMoveSubmit'])) {
                $addMoveTuple = array (
                    ":PokemonID" => $_SESSION['selectedPokemonID'],
                    ":SpecieName" => $_SESSION['selectedPokemonSpecie'],
                    ":MoveName" => $_POST['moveName']
                );
            
                $addMoveTuples = array (
                    $addMoveTuple
                );
            
                $addMoveResult = executeBoundSQL("SELECT COUNT(*) FROM HASMOVE WHERE POKEMONID = HEXTORAW(:PokemonID) AND SPECIENAME LIKE :SpecieName", $addMoveTuples);

                $moveCount = OCI_Fetch_Array($addMoveResult, OCI_NUM);

                if ($moveCount[0] >= 4) {
                    echo "Maximum number of moves (4) cannot be exceeded!";
                }
                else {
                    executeBoundSQL("INSERT INTO HasMove VALUES (HEXTORAW(:PokemonID), :SpecieName, :MoveName)", $addMoveTuples);
                    OCICommit($db_conn);

                    echo "Successfully added " . $_POST['moveName'] . " to pokemon!";
                }
            }

            $pokemonTuple = array (
                ":PokemonID" => $_SESSION['selectedPokemonID'],
                ":PokemonSpecie" => $_SESSION['selectedPokemonSpecie']
            );

            $pokemonTuples = array (
                $pokemonTuple
            );

            // DELETE/DISPLAY MOVES
            $result = executeBoundSQL("SELECT h.MoveName
                                       FROM HasMove h, Move m
                                       WHERE h.PokemonID = HEXTORAW(:PokemonID) AND 
                                             h.SpecieName LIKE :PokemonSpecie AND 
                                             h.MoveName = m.MoveName", $pokemonTuples);
        
            echo "<table>";
            echo "<tr><th>Move</th></tr>";
            while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                echo "<tr><td>" . $row["MOVENAME"] . "</td>";
                
                echo "<form method='POST' action='pokemon.php'>";
                echo "<input type='hidden' name='moveName' value='" . $row["MOVENAME"] . "'>";
                echo "<td><input type='submit' value='Delete' name='deleteMoveSubmit'></td>";
                echo "</form>";
                echo "</tr>";
            }
            echo "</table>";

            // ADD MOVES OPTIONS
            $result = executeBoundSQL("SELECT m.MOVENAME 
                                       FROM Move m
                                       WHERE m.MOVENAME NOT IN (SELECT MOVENAME 
                                                                FROM HASMOVE 
                                                                WHERE POKEMONID = HEXTORAW(:PokemonID) AND 
                                                                      SPECIENAME LIKE :PokemonSpecie)", $pokemonTuples);
            
            echo "<h3>Add Move:</h3>";
            echo "<table>";
            echo "<tr><th>Move Name</th></tr>";
    
            while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                echo "<tr><td>" . $row["MOVENAME"] . "</td>";
                
                echo "<form method='POST' action='pokemon.php'>";
                echo "<input type='hidden' name='moveName' value='" . $row["MOVENAME"] . "'>";
                echo "<td><input type='submit' value='Add Move' name='addMoveSubmit'></td>";
                echo "</form>";
    
                echo "</tr>";
            }
    
            echo "</table>";

            $currpokemon = executeBoundSQL("SELECT POKEMONNAME, GENDER, SPECIENAME, POKEMONLEVEL 
                                            FROM Pokemon p 
                                            WHERE p.POKEMONID = HEXTORAW(:PokemonID) AND 
                                                  p.SPECIENAME LIKE :PokemonSpecie", $pokemonTuples);
        
            $curr = OCI_Fetch_Array($currpokemon, OCI_BOTH);
            echo "<h3>Edit Pokemon</h3>";
            echo "<h4>Specie: " . $curr['SPECIENAME'] . "<br>";

            echo "<form method='POST' action='pokemon.php'>";

            // POKEMONNAME
            echo "<label for='pokemonname'>Pokemon name:</label><br>";
            echo "<input type='text' id='pokemonname' name='pokemonname' value='" . $curr['POKEMONNAME'] . "'><br>";

            // GENDER
            echo "<label for='gender'>Gender: </label><br>";
            echo "<select name='gender' id='gender'>";
            echo "<option value='" . $curr['GENDER'] ."'>" . $curr['GENDER'] . "</option>";
            echo "<option value='F'>F</option>";
            echo "<option value='M'>M</option>";
            echo "<option value='U'>U</option>";
            echo "</select> <br>\n";

            // ABILITY
            $abilityResult = executePlainSQL("SELECT ABILITYNAME FROM Ability ORDER BY AbilityName ASC");
            $currpokemon = executeBoundSQL("SELECT ABILITYNAME FROM Pokemon p WHERE p.POKEMONID = HEXTORAW(:PokemonID) AND p.SPECIENAME LIKE :PokemonSpecie", $pokemonTuples);
            $ability = OCI_Fetch_Array($currpokemon, OCI_BOTH);
            echo "<label for='ability'>Ability: </label><br>";
            echo "<select name='ability' id='ability'>";
            echo "<option value='" . $ability['ABILITYNAME'] ."'>" . $ability['ABILITYNAME'] . "</option>";
            while ($row = OCI_Fetch_Array($abilityResult, OCI_BOTH)) {
                echo "<option value='" . $row["ABILITYNAME"] . "'>" . $row["ABILITYNAME"] . "</option>";
            }
            echo "</select> <br>";

            // ITEM
            $itemResult = executePlainSQL("SELECT ITEMNAME FROM Item ORDER BY ItemName ASC");
            $currpokemon = executeBoundSQL("SELECT ITEMNAME FROM Pokemon p WHERE p.POKEMONID = HEXTORAW(:PokemonID) AND p.SPECIENAME LIKE :PokemonSpecie", $pokemonTuples);
            $item = OCI_Fetch_Array($currpokemon, OCI_BOTH);
            echo "<label for='item'>Item: </label><br>";
            echo "<select name='item' id='item'>";
            echo "<option value='" . $item['ITEMNAME'] ."'>" . $item['ITEMNAME'] . "</option>";
            while ($row = OCI_Fetch_Array($itemResult, OCI_BOTH)) {
                echo "<option value='" . $row["ITEMNAME"] . "'>" . $row["ITEMNAME"] . "</option>";
            }
            echo "</select> <br>";

            // LEVEL
            echo "<label for='level'>Pokemon level:</label><br>";
            echo "<input type='text' id='level' name='level' value='" . $curr['POKEMONLEVEL'] . "'><br>";

            echo "<input type='submit' value='Save' name='saveSubmit'></p>";
            echo "</form>";

            disconnectFromDB();
        }
        ?>
    </body>
</html>


