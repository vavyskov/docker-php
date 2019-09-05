<?php

// Load
require_once('class/ServerInfo.php');

// Class
$info = new ServerInfo();

?>

<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <title>It works!</title>

    <link rel="stylesheet" href="vendor/bootstrap.min.css">
    <!--
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.2.0/css/all.css">
    -->
    <style>
        .container {
            max-width: 50em;
        }

        td:first-child {
            width: 40ch;
        }
    </style>
</head>

<body class="pb-5 mb-4">
<header class="bg-dark text-white mb-5 pt-4 pb-3 sticky-top">
    <div class="container">
        <div class="media">
            <img src='asset/lightbulb.svg' alt='lightbulb' width='72' height='96' class='align-middle'>
            <div class="media-body pl-3">
                <h1>It works!</h1>
                <p class="lead">
                    The web server is up and running!
                    <img src='asset/smile-wink.svg' alt='smile-wink' width='20' height='21' class='align-middle'>
                </p>
            </div>
        </div>
    </div>
</header>
<main class="container">
    <?= $info->swVersion() ?>
    <?= $info->phpExtension() ?>
</main>
<footer class="bg-dark text-white-50 pt-3 pb-1 mt-5 fixed-bottom">
    <div class="container">
        <p class="text-center">Web server info by VeV-VA Vyškov</p>
    </div>
</footer>

<script>
    /*const success = document.querySelectorAll(".fa-check");

    function color() {
      success.forEach(item => item.classList.add('text-success'));
    }

    window.onload = function () {
      color();
    };*/
</script>
</body>

</html>
