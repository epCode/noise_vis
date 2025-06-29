function noise_vis.parse_table(str)
    local function trim(s)
        return s:match("^%s*(.-)%s*$")
    end

    local function match_braces(s, start)
        local depth = 1
        local i = start + 1
        while i <= #s and depth > 0 do
            local c = s:sub(i, i)
            if c == "{" then depth = depth + 1
            elseif c == "}" then depth = depth - 1 end
            i = i + 1
        end
        return s:sub(start, i - 1), i
    end

    local function parse(s)
        local tbl = {}
        local i = 1
        local len = #s

        while i <= len do
            -- Skip whitespace
            while i <= len and s:sub(i,i):match("%s") do i = i + 1 end

            if i > len then break end

            -- Parse key
            local key
            if s:sub(i,i) == "[" then
                local j = s:find("]", i + 1, true)
                if not j then error("Unmatched [ in key") end
                key = trim(s:sub(i+2, j-2))  -- assume key is like ["foo"]
                i = j + 1
            else
                local start = i
                while i <= len and s:sub(i,i):match("[%w_]") do i = i + 1 end
                key = trim(s:sub(start, i - 1))
            end

            -- Skip whitespace and equal
            while i <= len and s:sub(i,i):match("[%s=]") do i = i + 1 end

            -- Parse value
            local val
            if s:sub(i,i) == "{" then
                local raw, new_i = match_braces(s, i)
                val = parse(raw:sub(2, -2))
                i = new_i
            elseif s:sub(i,i) == "\"" then
                -- Parse quoted string value
                local j = s:find("\"", i + 1, true)
                if not j then error("Unmatched \" in value") end
                val = s:sub(i + 1, j - 1)
                i = j + 1
            else
                local start = i
                while i <= len and not s:sub(i,i):match("[,%}]") do i = i + 1 end
                local raw = trim(s:sub(start, i - 1))
                val = tonumber(raw) or raw
            end

            tbl[key] = val

            -- Skip comma or closing brace
            while i <= len and s:sub(i,i):match("[%s,}]") do
                if s:sub(i,i) == "}" then break end
                i = i + 1
            end
        end

        return tbl
    end

    str = trim(str)
    if str:sub(1,1) == "{" and str:sub(-1) == "}" then
        str = str:sub(2, -2)
    end

    return parse(str)
end
