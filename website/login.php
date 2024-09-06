<html>
    <body>
        <form action='mainpage.php' method='post'><input type='submit' value='Back to Main Page'/></form>
		<form method="post">
			Username: <input type="text" id="username" name="username" value=""><br>
			<input type="submit" value="Log In" name="login"/>
		</form>

        <?php
        session_start();

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        require 'helpers.php';

		if (isset($_POST['login'])) {
			if (connectToDB()) {

				$player_username = $_POST['username'];

				if ($player_username == '') {
					echo "Please enter valid username";
				} else {

					$tuple = array (
						":Username" => $player_username
					);

					$all_tuples = array (
						$tuple
					);
					
					$result = executeBoundSQL("SELECT USERNAME, TRAINERID FROM PLAYER WHERE USERNAME = :Username", $all_tuples);
					$player_row = OCI_Fetch_Array($result, OCI_BOTH);

					if ($player_row == NULL) {
						echo "Username not found\n";
					} else {
                        $_SESSION['login'] = true;
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
