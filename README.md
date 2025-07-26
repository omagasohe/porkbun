# porkbun api scripts
Repo for shell scripts to use [porkbun](http://porkbun.com)'s api to manage various tasks. the goal is to break down tasks into a series of independent tasks. That way you can build your own scripts around these.
# Requirements
- [jq](https://github.com/jqlang/jq) to parse json. 
- [curl](https://github.com/curl/curl) to do the actual connections.
- [gum](https://github.com/charmbracelet/gum) Tui's use gum to be pretty
- [pop](https://github.com/charmbracelet/pop) E-mail notifications using Resend with a sub domain. Pop can use SMTP as well.
- [skate](https://github.com/charmbracelet/skate) Used for storing apikeys.

# apikey.json
the scripts expect you to have a apikey.json file with apropriate keys from porkbun.

```
{
    "apikey":"pk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "secretapikey":"sk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    "resend":"re_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

# settings.json
currently used just to set the ssl storage location

# ssl_gui.sh
displays a table of ssl certs available in your porkbun account, looks to see if they are downloaded and not expiring, gives the option to download them if needed. 

# ssl_pull_keys.sh
```
get_ssl_keys.sh [domain]
```
This gets the ssl key bundle for domain and places it into `~/ssl_keys/[domain]/`

# ssl_key_expire.sh 
`check_ssl_keys.sh domain [--bool]`
simple check to see when a set of keys expire. the --bool flag give true or false if it expires in 7 days.

Please note, porkbun uses lets encrypt for DNS level ssl certs. They expire after 90 days, but new ones are generated every 75 days. this allows for a comfortable overlap.

# ddns_check.sh
checks that a sub/domain is pointed at you networks outside ip. I wouldnt run this much.