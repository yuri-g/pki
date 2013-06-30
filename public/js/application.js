$(function() {
    $("#generate").submit(function(event) {
        event.preventDefault()

        if($("#type").val() == "Mail") {
            if ($("#email").val().length == 0) {
                $("#error").html("For email certificate type email field can not be empty!")
                $("#error").show('slow').delay(5000).hide('slow')
            }
            else {
                this.submit()
            }
        }
        else if($("#type").val() == "Websites") {
            if($("#dns").val().length == 0) {
                $("#error").html("For website certificate type DNS field can not be empty!")
                $("#error").show('slow').delay(5000).hide('slow')
            }
            else {
                this.submit()
            }
        }
    })
});