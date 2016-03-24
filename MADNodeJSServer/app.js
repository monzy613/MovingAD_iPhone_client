var express = require('express')
var util = require('util')
var app = express()
var bodyParser = require('body-parser')

var validAccountDic = {"admin": "admin", "monzy613": "123456", "adm": "adm"}
var accountNameDic = {"admin": "ADMIN", "monzy613": "MONZY", "adm": "ADM"}
var VERIFYNUM = "111111"
var phoneVerifynumberMap = {}

app.use(bodyParser.urlencoded({extended: false}))
app.use(bodyParser.json())

app.route("/login").post(function(req, res) {
    console.log("login post request")
    if (validAccountDic[req.body.account] === req.body.password) {
        res.send({"userInfo": {"name": "Monzy", "gender": 0}})//0 1
    } else {
        res.send({"error": "user not valid"})
    }
})

app.route("/registerPhone").post(function(req, res) {
    var account = req.body.account
    console.log("register post request with account: " + account)
    if (validAccountDic[account] !== undefined) {// already exist
        res.send({"error": "user already exist"})    
    } else {
        phoneVerifynumberMap[account] = VERIFYNUM
        res.send({"success": "user send account success"})
    }
})

app.route("/registerVerify").post(function(req, res) {
    var account = req.body.account
	var verifyNumber = req.body.verifyNumber
	console.log("coming verify number is: " + verifyNumber)
	if (verifyNumber === phoneVerifynumberMap[account]) {
		res.send({"success": "verify number correct"})
	} else {
		res.send({"error": "verify number wrong"})
	}
})

app.route("/register").post(function(req, res) {
    var account = req.body.account
    var name = req.body.name
    var password = req.body.password
    if (phoneVerifynumberMap[account] !== undefined) {
        //success
        console.log("register success from " + account)
        validAccountDic[account] = password
        accountNameDic[account] = name
        res.send({"success": "register success"})
    } else {
        res.send({"error": "account not verified"})
    }
})

app.route("register").post(function(req, res) {
    var name = req.body.name
    var password = req.body.password
    res.send({"success": "register success"})
})

app.listen(3000, function() {
    console.log("server started on port 3000");
})
