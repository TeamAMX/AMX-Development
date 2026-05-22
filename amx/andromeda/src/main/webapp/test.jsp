<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>

    <title>Manufacturer Autocomplete</title>

    <link rel="stylesheet"
          href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>

</head>
<body>
<h2>Manufacturer Autocomplete</h2>

<input type="text"
       id="manufacturer"
       placeholder="Type manufacturer">

<script>

$(document).ready(function () {

    $("#manufacturer").autocomplete({

        minLength: 3,

        source: function (request, response) {

            $.ajax({

                url: "http://localhost:8080/andromeda/api/db/manufacturers",
                method: "GET",
                dataType: "json",

                data: {search: request.term},
                success: function (data) {response(data)},
                error: function () {
                    console.log("Error fetching manufacturers");
                }
            });
        }
    });
});

</script>

</body>
</html>