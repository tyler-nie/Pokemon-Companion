<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>

        <h2>All data</h2>
        <?php
        session_start();
        //this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

        if (connectToDB()) {
            // HELP FROM: https://www.sqltutorial.org/sql-list-all-tables/
            $table_result = executePlainSQL("SELECT table_name FROM user_tables");

            echo "<form method='POST' action='all_data.php'>";
            echo "<select name='tableName' id='tableName'>";
            if (isset($_POST['tableName'])) {
                echo "<option value='" . $_POST['tableName'] . "' selected>" . $_POST['tableName'] . "</option>";
            }
            else {
                echo "<option value=''>--- Select a Table ---</option>";
            }

            while ($table_row = OCI_Fetch_Array($table_result, OCI_BOTH)) {
                echo "<option value='" . $table_row[0] ."'>" . $table_row[0] . "</option>";
            }
            echo "</select> <br>";  
            echo "<input type='submit' value='Select Table' name='selectTable'>";
            echo "</form>";
            
            if (isset($_POST['tableName'])) {

                $attribute_result = executePlainSQL("SELECT COLUMN_NAME FROM USER_TAB_COLS WHERE TABLE_NAME = '" . $_POST['tableName'] . "'");

                echo "<form method='POST' action='all_data.php'>";
                while ($attribute_row = OCI_Fetch_Array($attribute_result, OCI_BOTH)) {
                    // HELP FROM: https://stackoverflow.com/questions/5182938/get-all-values-from-checkboxes
                    echo "<input type='checkbox' name='attributes[]' value='" . $attribute_row[0] ."'>" . $attribute_row[0] . "<br>";
                }
                echo "<input type='hidden' value='{$_POST['tableName']}' name='tableName'>";
                echo "<input type='submit' value='Select Attributes' name='selectAttributes'>";
                echo "</form>";
            }

            if (isset($_POST['attributes'])) {
                // HELP FROM: https://stackoverflow.com/questions/5182938/get-all-values-from-checkboxes
                if (is_array($_POST['attributes'])) {
                    $attribute_string = implode(', ', $_POST['attributes']);

                    $data_result = executePlainSQL("SELECT " . $attribute_string . " FROM " . $_POST['tableName']);

                    echo "<table>";
                    echo "<tr><th>" . implode('</th><th>', $_POST['attributes']) . "</th></tr>";
                    while ($data_row = OCI_Fetch_Array($data_result, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        echo "<tr><td>" . implode("</td><td>", $data_row) . "</td></tr>";
                    }
                    echo "</table>";
                }
            }

            disconnectFromDB();
        }

        ?>
    </body>
</html>


