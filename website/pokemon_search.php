<html>
    <body>
    <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        
        <h2>Pokemon Search</h2>

        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (connectToDB()) {

            echo "<form method='POST' action='pokemon_search.php'>";

            // Type 1
            echo "<input type='radio' name='type1' value='Dark'>Dark";
            echo "<input type='radio' name='type1' value='Dragon'>Dragon";
            echo "<input type='radio' name='type1' value='Electric'>Electric";
            echo "<input type='radio' name='type1' value='Fairy'>Fairy";
            echo "<input type='radio' name='type1' value='Fighting'>Fighting";
            echo "<input type='radio' name='type1' value='Fire'>Fire";
            echo "<input type='radio' name='type1' value='Flying'>Flying";
            echo "<input type='radio' name='type1' value='Ghost'>Ghost";
            echo "<input type='radio' name='type1' value='Grass'>Grass";
            echo "<input type='radio' name='type1' value='Ground'>Ground";
            echo "<input type='radio' name='type1' value='Ice'>Ice";
            echo "<input type='radio' name='type1' value='Normal'>Normal";
            echo "<input type='radio' name='type1' value='Poison'>Poison";
            echo "<input type='radio' name='type1' value='Psychic'>Psychic";
            echo "<input type='radio' name='type1' value='Steel'>Steel";
            echo "<input type='radio' name='type1' value='Water'>Water";

            echo "<br>";

            // Type 2
            echo "<input type='radio' name='type2' value='Dark'>Dark";
            echo "<input type='radio' name='type2' value='Dragon'>Dragon";
            echo "<input type='radio' name='type2' value='Electric'>Electric";
            echo "<input type='radio' name='type2' value='Fairy'>Fairy";
            echo "<input type='radio' name='type2' value='Fighting'>Fighting";
            echo "<input type='radio' name='type2' value='Fire'>Fire";
            echo "<input type='radio' name='type2' value='Flying'>Flying";
            echo "<input type='radio' name='type2' value='Ghost'>Ghost";
            echo "<input type='radio' name='type2' value='Grass'>Grass";
            echo "<input type='radio' name='type2' value='Ground'>Ground";
            echo "<input type='radio' name='type2' value='Ice'>Ice";
            echo "<input type='radio' name='type2' value='Normal'>Normal";
            echo "<input type='radio' name='type2' value='Poison'>Poison";
            echo "<input type='radio' name='type2' value='Psychic'>Psychic";
            echo "<input type='radio' name='type2' value='Steel'>Steel";
            echo "<input type='radio' name='type2' value='Water'>Water";

            echo "<br><input type='submit' value='Select Types' name='typeSelect'>";
            echo "</form>";

            if (isset($_POST['type1']) || isset($_POST['type2'])) {

                $typeCondition = '';

                if (!isset($_POST['type1'])) {
                    $typeCondition = "t.TYPENAME LIKE '" . $_POST['type2'] . "'";
                }
                elseif (!isset($_POST['type2'])) {
                    $typeCondition = "t.TYPENAME LIKE '" . $_POST['type1'] . "'";
                }
                else {
                    $typeCondition = "(t.TYPENAME LIKE '" . $_POST['type1'] . "'" . " OR " . "t.TYPENAME LIKE '" . $_POST['type2'] . "')";
                }

                $result = executePlainSQL("SELECT ps.EVOLVINGINTOSPECIENAME
                                           FROM POKEMONSPECIES ps
                                           WHERE NOT EXISTS (SELECT t.TYPENAME
                                                             FROM TYPE t
                                                             WHERE " . $typeCondition . " AND
                                                                NOT EXISTS (SELECT pt.SPECIENAME
                                                                            FROM POKEMONTYPE pt
                                                                            WHERE t.TYPENAME LIKE pt.TYPENAME AND
                                                                                pt.SPECIENAME LIKE ps.EVOLVINGINTOSPECIENAME))");

                echo "<table>";
                echo "<tr><th>SPECIENAME</th></tr>";
                while ($row = OCI_Fetch_Array($result, OCI_ASSOC)) {
                    echo "<tr><td>" . implode("</td><td>", $row) . "</td></tr>";
                }
                echo "</table>";
            }
            else {
                echo "Please select at least one type";
            }

            $tuple = array ();
            $tuples = array ( $tuple );

            disconnectFromDB();
        }

        ?>
    </body>
</html>


