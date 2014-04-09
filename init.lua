cjson = require "cjson"
common = require "stats.common"
cache_status = {"MISS", "BYPASS", "EXPIRED", "STALE", "UPDATING", "REVALIDATED", "HIT"}
local stats = ngx.shared.ngx_stats;
ngx.update_time()

-- Geral stats
stats:set('stats_start', ngx.now())
