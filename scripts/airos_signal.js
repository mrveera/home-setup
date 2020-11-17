const http = require('http')
var shell = require('shelljs');

var ubnt_user = process.env.UBNT_USER;
var ubnt_pass = process.env.UBNT_PASS;
var ubnt_host = process.env.UBNT_HOST;

if (ubnt_user === undefined) {
    ubnt_user = "ubnt";
}
if (ubnt_pass === undefined) {
    ubnt_pass = "ubnt"; 
}
if (ubnt_host === undefined) {
    ubnt_host = "192.168.1.20";
}

status = shell.exec('sshpass -p "' + ubnt_pass + '" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ' + ubnt_user + '@' + ubnt_host + ' /usr/www/status.cgi ', {
    silent: true
});
const res = status.stdout.split("\n").slice(2).join("\n");
console.log(JSON.parse(res).wireless.signal);
