<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
        <form method="post">
            Username: <input type="text" id="username" name="username" value=""><br>
            Trainer name: <input type="text" id="trainername" name="trainername" value=""><br>
            Email: <input type="text" id="email" name="email" value=""><br>
            Province: <input type="text" id="province" name="province" value=""><br>
            City: <input type="text" id="city" name="city" value=""><br>
            Street Adress: <input type="text" id="address" name="address" value=""><br>
            Postal Code: <input type="text" id="postalcode" name="postalcode" value=""><br>
            <input type="submit" value="Register" name="register"/>
        </form>

        <?php
        session_start();

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (isset($_POST['register'])) {
            if (connectToDB()) {

                $player_username = $_POST['username'];
                $trainer_name	 = $_POST['trainername'];
                $email           = $_POST['email'];
                $address         = $_POST['address'];
                $postalcode		 = strtoupper($_POST['postalcode']);
                $city			 = $_POST['city'];
                $province		 = $_POST['province'];

                // HELP FROM: https://stackoverflow.com/questions/33890810/how-to-get-the-first-character-of-string-in-php
                if ($player_username == '' || $trainer_name == '' || $email == '' || $address == '' || $postalcode == '' || $city == '' || $province == '' || strlen($postalcode) != 6 ||
                    !(is_numeric(mb_substr($postalcode, 1, 1)) && is_numeric(mb_substr($postalcode, 3, 1)) && is_numeric(mb_substr($postalcode, 5, 1)) 
                    && ctype_alpha(mb_substr($postalcode, 0, 1)) && ctype_alpha(mb_substr($postalcode, 2, 1)) && ctype_alpha(mb_substr($postalcode, 4, 1)))) {
                    if ($player_username == '') {
                        echo "Please enter valid username<br>";
                    }
                    if ($trainer_name == '') {
                        echo "Please enter valid trainer name<br>";
                    }
                    if ($email == '') {
                        echo "Please enter valid email<br>";
                    }
                    if ($province == '') {
                        echo "Please enter valid province<br>";
                    }
                    if ($city == '') {
                        echo "Please enter valid city<br>";
                    }
                    if ($address == '') {
                        echo "Please enter valid address<br>";
                    }
                    if ($postalcode == '') {
                        echo "Please enter valid postal code<br>";
                    }
                    if (strlen($postalcode) != 6) {
                        echo "Postal code must have 6 characters<br>";
                    }
                    else if (!(is_numeric(mb_substr($postalcode, 1, 1)) && is_numeric(mb_substr($postalcode, 3, 1)) && is_numeric(mb_substr($postalcode, 5, 1)) 
                            && ctype_alpha(mb_substr($postalcode, 0, 1)) && ctype_alpha(mb_substr($postalcode, 2, 1)) && ctype_alpha(mb_substr($postalcode, 4, 1)))) {
                        echo "Must be in A1B2C3 format<br>";
                    }
                }
                else {

                    $tuple = array (
                        ":Username" => $player_username,
                        ":TrainerName" => $trainer_name,
                        ":Email" => $email,
                        ":Address" => $address,
                        ":PostalCode" => $postalcode,
                        ":City" => $city,
                        ":Province" => $province
                    );

                    $all_tuples = array (
                        $tuple
                    );
                    
                    $username_result = executeBoundSQL("SELECT USERNAME FROM PLAYER WHERE USERNAME LIKE :Username", $all_tuples);
                    $username_row = OCI_Fetch_Array($username_result, OCI_BOTH);

                    $email_result = executeBoundSQL("SELECT EMAIL FROM PLAYER WHERE EMAIL LIKE :Email", $all_tuples);
                    $email_row = OCI_Fetch_Array($email_result, OCI_BOTH);

                    if ($email_row != NULL || $username_row != NULL) {
                        if ($email_row != NULL) {
                            echo "Email already in use\n";
                        }
                        if ($username_row != NULL) {
                            echo "Username already in use\n";
                        }
                    } 
                    else {
                        $province_result = executeBoundSQL("SELECT POSTALCODE FROM PLAYERPROVINCE WHERE POSTALCODE LIKE :PostalCode", $all_tuples);
                        $province_row = OCI_Fetch_Array($province_result, OCI_BOTH);

                        $city_result = executeBoundSQL("SELECT POSTALCODE FROM PLAYERCITY WHERE POSTALCODE LIKE :PostalCode", $all_tuples);
                        $city_row = OCI_Fetch_Array($city_result, OCI_BOTH);

                        if ($province_row == NULL) {
                            executeBoundSQL("INSERT INTO PLAYERPROVINCE (POSTALCODE, PROVINCE) VALUES (:PostalCode, :City)", $all_tuples);
                            OCICommit($db_conn);
                        }

                        if ($city_row == NULL) {
                            executeBoundSQL("INSERT INTO PLAYERCITY VALUES (:PostalCode, :City)", $all_tuples);
                            OCICommit($db_conn);
                        }

                        // HELP FROM: 
                        // https://www.w3resource.com/sql/sql-dual-table.php
                        // https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16
                        // https://www.guru99.com/sql-server-variable.html
                        // https://learnsql.com/cookbook/how-to-get-the-current-date-in-oracle/
                        executeBoundSQL("
                            DECLARE
                                guid RAW(16);
                            BEGIN
                                SELECT SYS_GUID() INTO guid FROM DUAL;
                                INSERT INTO POKEMONTRAINER VALUES (guid, :TrainerName);
                                INSERT INTO PLAYER (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email) VALUES (:Username, guid, TO_CHAR(CURRENT_DATE, 'yyyy/MM/dd'), :PostalCode, :Address, :Email);
                            END;
                        ", $all_tuples);
                        oci_commit($db_conn);
                        
                        $player_result = executeBoundSQL("SELECT TRAINERID FROM PLAYER WHERE USERNAME LIKE :Username", $all_tuples);
                        $player_row = OCI_Fetch_Array($player_result, OCI_BOTH);

                        $_SESSION['registered'] = true;
                        $_SESSION['user_id'] = bin2hex($player_row['TRAINERID']);
                        Header("Location: mainpage.php");
                    }
                }

                disconnectFromDB();
            }
        }

        ?>
    </body>
</html>
