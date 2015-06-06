# ngx_stats

Watch live nginx stats from your servers


## Installation

1. Install [nginx](http://nginx.org/) configured with [--add-module=/path/to/lua-nginx-module](https://github.com/chaoslawful/lua-nginx-module)
2. Clone [ngx_stats](https://github.com/StudioSol/ngx_stats) in path specified by ```lua_package_path``` policy

```sh
cd /etc/nginx/lua/
git clone git@github.com:StudioSol/ngx_stats.git stats
```

## Overview

Nginx Lua module to capture and show stats.
```stats/log.lua``` module collect statistics for requests across location with ```log_by_lua_file 'stats/log.lua';``` directive.
```stats/show.lua``` response for JSON reply.




## Configure nginx:

```nginx
user www-data;
worker_processes  1;
error_log  /var/log/nginx/error.log error;
pid        /var/run/nginx.pid;
events {
    worker_connections  61440;
}

http {
    access_log  off;

    lua_shared_dict ngx_stats 10m;
    lua_package_path '/etc/nginx/lua/?.lua;;';
    lua_package_cpath '/etc/nginx/lua/?.so;;';
    init_by_lua_file /etc/nginx/lua/stats/init.lua;

    proxy_cache_path /var/tmp/cache_http levels=1:1:1
        keys_zone=g_cache:64m
        max_size=1024m inactive=4h;

    server {
        listen 80;
        server_name example.com;
        set $stats_group "example.com";
        log_by_lua_file /etc/nginx/lua/stats/log.lua;
        location / {
            proxy_pass "http://127.0.0.1:8080";
            proxy_cache g_cache;
        }
        location = /status.json {
            default_type 'application/json';
            content_by_lua_file /etc/nginx/lua/stats/show.lua;
        }
    }
    server {
        listen 80;
        server_name  sub.example.com;
        set $stats_group "sub.example.com";
        log_by_lua_file /etc/nginx/lua/stats/log.lua;
        location / {
            proxy_pass "http://127.0.0.1:8081";
            proxy_cache g_cache;
        }
    }
    server {
        listen 80 default_server;
        server_name  _;
        log_by_lua_file /etc/nginx/lua/stats/log.lua;
        return 404;
    }
}

```
## Result


- See result in ```example.com/status.json```
- All requests that do not have ```$stats_group```, are displayed in the group: ```other```

```json
{
    "stats_start": 1397069333.819,
    "example.com": {
        "cache": {
            "expired": 812415,
            "updating": 1526,
            "miss": 13276642,
            "hit": 24260426,
            "stale": 162
        },
        "upstream_requests_total": 14090608,
        "request_time": {
            "sum": 803899.9091289
        },
        "status": {
            "3xx": 2,
            "4xx": 238784,
            "5xx": 18619,
            "2xx": 38109854
        },
        "upstream_resp_time_sum": 636378.56698991,
        "requests_total": 38367259
    },
    "sub.example.com": {
        "cache": {
            "expired": 911851,
            "updating": 1187,
            "miss": 1742453,
            "hit": 61705830,
            "stale": 1061
        },
        "upstream_requests_total": 2657158,
        "request_time": {
            "sum": 1607474.1242547
        },
        "status": {
            "3xx": 538834,
            "4xx": 1080163,
            "5xx": 1693,
            "2xx": 62743490
        },
        "upstream_resp_time_sum":105318.85199993,
        "requests_total": 64364180
    },
    "other": {
        "status": {
            "4xx":4169
        },
        "requests_total": 4169,
        "request_time": {
            "sum": 51761.917998552
        }
    }
}
```

## See Also

- [lua-nginx-module](https://github.com/chaoslawful/lua-nginx-module) Embed the Power of Lua into NginX
- [LuaJIT](http://luajit.org/) a Just-In-Time Compiler for Lua
- [nginx](http://nginx.org/) HTTP and reverse proxy server
