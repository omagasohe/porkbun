# porkbun api scripts
Repo for shell scripts to use [porkbun](http://porkbun.com)'s api to manage various tasks.

# Requirements
- [jq](https://github.com/jqlang/jq) to parse json. 
- [curl](https://github.com/curl/curl) to do the actual connections.

# apikey.json
the scripts expect you to have a apikey.json file with apropriate keys from porkbun.

```
{
    "apikey":"pk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "secretapikey":"sk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```
# settings.json
This has the commmon configuration info. modify this to your liking, because it's definately how I like it.
# get_ssl_keys.sh
```
get_ssl_keys.sh [domain]
```
This gets the ssl key bundle for domain and places it into `~/ssl_keys/[domain]/`

# check_ssl_keys.sh 
`check_ssl_keys.sh domain [--bool]`
simple check to see when a set of keys expire. the --bool flag give true or false if it expires in 7 days.

Please note, porkbun uses lets encrypt for DNS level ssl certs. They expire after 90 days, but new ones are generated every 75 days. this allows for a comfortable overlap.