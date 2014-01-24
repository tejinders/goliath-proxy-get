# goliath-proxy-get

Transparent GET proxy with basic auth support

## Usage

To start the proxy on localhost:8000 run the following command to relay all GET requests (params + headers) to https://target.host
Basic auth credentials can be passed using the RELAY_PASS and RELAY_USER env params.

```
RELAY_SERVER=https://target.host RELAY_PASS=basic_auth_pass RELAY_USER=basic_auth_user bundle exec ruby proxy.rb -sv -p 8000
```
