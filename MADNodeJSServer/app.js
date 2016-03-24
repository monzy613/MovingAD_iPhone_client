var express = require('express')
var util = require('util')
var app = express()
var bodyParser = require('body-parser')

var validAccountDic = {"admin": "admin", "monzy613": "123456"}

app.use(bodyParser.urlencoded({extended: false}))
app.use(bodyParser.json())

app.route("/login").post(function(req, res) {
    console.log("login post request")
    if (validAccountDic[req.body.account] == req.body.password) {
        res.send({"userInfo": {"name": "Monzy", "gender": "Male"}})
    } else {
        res.send({"error": "user not valid"})
    }
})

app.route("/register").post(function(req, res)) {
    console.log("register request post")
}

app.listen(3000, function() {
    console.log("server started on port 3000");
})