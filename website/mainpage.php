<html>
    <?php
        session_start();

        require 'helpers.php';

        if (isset($_SESSION['registered'])) {
            echo "Successfully registered!";
            unset($_SESSION['registered']);
        }

        if (isset($_SESSION['login'])) {
            echo "Successfully logged in!";
            unset($_SESSION['login']);
        }

        if(isset($_SESSION['user_id'])) {
            echo "<form action='teams.php' method='post'><input type='submit' value='Teams'/></form>";
            echo "<form action='pokemons.php' method='post'><input type='submit' value='Pokemons'/></form>";
            echo "<form action='all_data.php' method='post'><input type='submit' value='Show All Data'/></form>";
            echo "<form action='query_moves.php' method='post'><input type='submit' value='Query Moves'/></form>";
            echo "<form action='opponents.php' method='post'><input type='submit' value='Opponents'/></form>";
            echo "<form action='pokemon_search.php' method='post'><input type='submit' value='Pokemon Search'/></form>";
            echo "<form method='post'><input type='submit' value='Log Out' name='logout'/></form>";
        } else {
            echo "<form action='login.php' method='post'><input type='submit' value='Log In'/></form>";
            echo "<form action='register.php' method='post'><input type='submit' value='Register'/></form>";
        }

        if (isset($_POST['logout'])) {
            unset($_SESSION['user_id']);
            Header("Location: mainpage.php");
        }

        unset($_SESSION['moveQuery']);
    ?>


</html>
