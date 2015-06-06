ngx.update_time()
local stats = ngx.shared.ngx_stats;
local group = ngx.var.stats_group
local req_time = (tonumber(ngx.now() - ngx.req.start_time()) * 1000)
local status = tostring(ngx.status)

-- Geral stats
local upstream_response_time = tonumber(ngx.var.upstream_response_time)

-- Set default group, if it's not defined by nginx variable
if not group or group == "" then
    group = 'other'
end


common.incr_or_create(stats, common.key({group, 'requests_total'}), 1)

if req_time >= 0 and req_time < 100 then
    common.incr_or_create(stats, common.key({group, 'request_times', '0-100'}), 1)
elseif req_time >= 100 and req_time < 500 then
    common.incr_or_create(stats, common.key({group, 'request_times', '100-500'}), 1)
elseif req_time >= 500 and req_time < 1000 then 
    common.incr_or_create(stats, common.key({group, 'request_times', '500-1000'}), 1)
elseif req_time >= 1000 then
    common.incr_or_create(stats, common.key({group, 'request_times', '1000-inf'}), 1)
end

if upstream_response_time then
    common.incr_or_create(stats, common.key({group, 'upstream_requests_total'}), 1)
    common.incr_or_create(stats, common.key({group, 'upstream_resp_time_sum'}), (upstream_response_time or 0))
end


if common.in_table(ngx.var.upstream_cache_status, cache_status) then
    local status = string.lower(ngx.var.upstream_cache_status)
    common.incr_or_create(stats, common.key({group, 'cache', status}), 1)
end

common.incr_or_create(stats, common.key({group, 'status', common.get_status_code_class(status)}), 1)
