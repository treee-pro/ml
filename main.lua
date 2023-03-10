
--[[

    the mlua library -
    Inspired by the Wolfram Language.
    
    Algorithms, computations, etc.
    
--]]

-- var
local Services = setmetatable({}, {
    __index = function(self, s)
        return game:GetService(s)
    end
    }
)

local ml = setmetatable({}, {
    __call = function(self, m)
        return self[m] or nil
    end
})


--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    
    Core Language & Structure
        > List Manipulation
            > Constructing Lists

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

--[[
    
    ml "Range" {
        imin: number;
        imax: number;
        di: number or 1;
    } -> table
    
    Returns the table {imin, ..., imax} using steps di.
    
    T/S: O(n), O(n)

--]]
function ml.Range(p)
    local imin, imax, di = p[1], p[2], p[3] or 1
    local result = {}
    while imin <= imax do
        table.insert(result, imin)
        imin = imin + di
    end
    return result
end

--[[

    ml "Table" {
        expr: any;
        t<imin: number, imax: number, di: number or 1>: table || n: number;
    }: table
    
    Table(expr, n) generates a table of n copies of expr.
    Table(expr: function, {imin, imax, di}) generates a table of the values of expr(i) when i runs from [imin, imax], using steps di.
    
    T/S: O(n), O(n)
    
--]]
function ml.Table(p)
    local expr, n, result = p[1], p[2], {}
    if type(n) == "table" then
        local imin, imax, di = n[1], n[2], n[3] or 1
        if di == 0 then
            return {expr(imin)}
        end
        for i = imin, imax, di do
            result[#result + 1] = expr(i)
        end
        return result
        else
            result[n] = nil
            for i = 1, n do
                result[i] = expr
            end
        return result
    end
end

--[[

    ml "FixedPointList" {
        f: function;
        expr: any;
        max_iterations: number;
    }: table
    
    Generates a table giving the results of applying f repeatedly, starting with expr, until the results no longer change.
    Calculations may not converge in a finite number of steps. Setting the max iterations n will guarantee termination.
    Convergence may fail in machine-precision computations.
    
    T/S: O(n), O(n)
    
--]]
function ml.FixedPointList(p)
    local f, expr, n = p[1], p[2], p[3] or math.huge
    local result, last_result = {expr}, expr
    local i = 1
    while i <= n do
        local new_result = f(last_result)
        result[#result + 1] = new_result
        if new_result == last_result then
            return result
        end
        last_result = new_result
        i = i + 1
    end
    return result
end

--[[

    ml "Subdivide" {
        xmin: number;
        xmax: number;
        n: number;
    }: table
    
    Generates a table of values from subdividing [xmin, xmax] into n equal parts.
    
    T/S: O(n), O(n)
    
--]]
function ml.Subdivide(p)
    local xmin, xmax, n = p[1], p[2], p[3]
    local result, step = {}, (xmax - xmin) / n
    for i = 1, n + 1 do
        result[i] = xmin + (i - 1) * step
    end
    return result
end

--[[

    ml "Characters" {
        str: string;
    }: table
    
    Gives a table of all the characters in a string.
    
    T/S: O(n), O(n)
    
--]]
function ml.Characters(p)
    local str, result = p[1] or "", {}
    for i = 1, #str do
        result[i] = str:sub(i, i)
    end
    return result
end

--[[

    ml "CharacterRange" {
        c1: string || number;
        c2: string || number;
    }: table
    
    CharacterRange(c1: string, c2: string) yields a table of the characters in the range from c1 to c2.
    CharacterRange(c1: number, c2: number) yields a table of the characters with character codes in the range [c1, c2]
    
    T/S: O(n), O(n)
    
--]]
function ml.CharacterRange(p)
    local c1, c2, result = p[1], p[2], {}
    if type(c1) == "string" then
        c1 = string.byte(c1)
    end
    if type(c2) == "string" then
        c2 = string.byte(c2)
    end
    for i = c1, c2 do
        table.insert(result, string.char(i))
    end
    return result
end

--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    
    Core Language & Structure
        > List Manipulation
            > Elements of Lists

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

--[[
    ml "Drop" {
        t: table;
        index: number || table;
    }: table
    
    Drop(t: table, n: number) gives t with its first n elements dropped.
    Drop(t: table, -n: number) gives t with its last n elements dropped.
    Drop(t: table, {n: number}) gives t with its nth element dropped.
    Drop(t: table, {m: number, n: number}) gives t with elements m through n dropped.
    Drop(t: table, {m: number, n: number, s: number}) gives t with elements m through n in steps of s dropped.
        
    T/S: O(#t), O(#t)
    
--]]
function ml.Drop(p)
    local t, index, result = p[1], p[2], {}
    if ml "TypeQ" {index, "number"} then
        if index > 0 then
            for i = index + 1, #t do
                result[#result+1] = t[i]
            end
        elseif index < 0 then
            for i = 1, #t + index do
                result[#result + 1] = t[i]
            end
        end
    elseif ml "TypeQ" {index, "table"} then
        if #index == 1 then
            for i=1, #t do
                if i ~= index[1] then
                    result[#result+1] = t[i]
                end
            end
        elseif #index == 2 then
            for i=1, #t do
                if i < index[1] or i > index[2] then
                    result[#result+1] = t[i]
                end
            end
        elseif #index == 3 then
            for i=1, #t do
                if i < index[1] or i > index[2] or ((i - index[1]) % index[3] ~= 0) then
                    result[#result + 1] = t[i]
                end
            end
        end
    end
    return result
end

--[[
    ml "DeleteDuplicates" {
        t: table;
    }: table
    
    Deletes all duplicates from a table, leaving only one of each element.
        
    T/S: O(#t), O(#t)
    
--]]
function ml.DeleteDuplicates(p)
    local t, seen, unique = p[1], {}, {}
    for _, v in ipairs(t) do
        if not seen[v] then
            seen[v] = true
            unique[#unique + 1] = v
        end
    end
    return unique
end

--[[
    ml "RandomChoice" {
        t: table;
        weights: number || table;
    }: table
    
    RandomChoice(t: table) gives a pseudorandom choice of one of the elements in t.
    RandomChoice(t: table, n: number) gives a list of n pseudorandom choices.
    RandomChoice(t: table, weights: table) gives a pseudorandom choice weighted by weights. Weights must be from 0 to 1.
    
    T/S: O(#t), O(1)
    
--]]
function ml.RandomChoice(p)
    local t, weights = p[1], p[2] or nil
    if not weights then
        return t[math.random(#t)]
    elseif ml "TypeQ" {weights, "number"} then
        local result = {}
        for i=1, weights do
            table.insert(result, t[math.random(#t)])
        end
        return result
    elseif ml "TypeQ" {weights, "table"} then
        if #t ~= #weights then
            return warn("size of t and weights must be equal")
        end
        local total_weight = 0
        for i=1, #t do
            total_weight = total_weight + weights[i]
        end
        local random_weight = math.random() * total_weight
        for i=1, #t do
            random_weight = random_weight - weights[i]
            if random_weight <= 0 then
                return t[i]
            end
        end
    end
    return
end

--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    
    Core Language & Structure
        > List Manipulation
            > Rearraging & Restructuring Lists

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

--[[
    ml "Flatten" {
        t: table;
        level: number || 1;
    }: table
    
    Flattens out nested tables to the n-th level.
        
    T/S: O(#t), O(#t)
    
--]]
function ml.Flatten(p)
    local t, level, result = p[1], p[2] or 1, {}
    if level == 0 then
        return t
    end
    local function flatten(t, level)
        for i, v in pairs(t) do
            if type(v) == "table" then
                if level > 0 then
                    flatten(v, level - 1)
                    else
                        table.insert(result, v)
                end
                else
                    table.insert(result, v)
            end
        end
    end
    flatten(t, level)
    return result
end

--[[
    ml "Partition" {
        t: table;
        n: number || 1;
    }: table
    
    Partitions table into nonoverlapping subtables of length n.
        
    T/S: O(1), O(#t)
    
--]]
function ml.Partition(p)
    local t, n, result = p[1], p[2] or 1, {}
    for i=1, #t, n do
        local sublist = {}
        for j = i, math.min(i + n - 1, #t) do
            sublist[#sublist + 1] = t[j]
        end
        result[#result + 1] = sublist
    end
    return result
end

--[[
    ml "Shuffle" {
        t: table;
        n: number || 1;
    }: table
    
    Performs a Fisher-Yates shuffle on a table n times.
        
    T/S: O(n * #t), O(1)
    
--]]
function ml.Shuffle(p)
    local t, n = p[1], p[2] or 1
    for i=1, n do
        for j = #t, 2, -1 do
            local k = math.random(j)
            t[j], t[k] = t[k], t[j]
        end
    end
    return t
end

--[[
    ml "Riffle" {
        t1: table;
        t2: table;
    }: table
    
    Riffles, or "interleaves" tables t1 and t2 together.
    
    For example, {a1, a2, ...}, {b1, b2, ...} -> {a1, b1, a2, b2, ...}
                 {a1, a2, a3}, {b1} -> {a1, b1, a2, b1, a3}
                 {a1, a2, a3}, {b1, b2} -> {a1, b1, a2, b2, a3}
        
    T/S: O(#t), O(#t)
    
--]]
function ml.Riffle(p)
    local t1, t2, n, result = p[1], p[2], #p[1], {}
    for i=1, n do
        result[#result+1] = t1[i]
        result[#result+1] = t2[(i-1) % #t2 + 1]
    end
    table.remove(result)
    return result
end

--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    
    Core Language & Structure
        > List Manipulation
            > Applying Functions to Lists

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

--[[
    ml "Map" {
        f: function;
        t: table;
        level: number || 1;
    }: table
    
    Applies a function to each element on the n-th level in a table.
    
    T/S: O(#t * max depth), O(1)
    
--]]
function ml.Map(p)
    local f, t, level = p[1], p[2], p[3] or 1
    if level == 0 then
        return t
    end
    for i, v in ipairs(t) do
        if type(v) == "table" then
            t[i] = ml "Map" {f, v, level - 1}
            else
                t[i] = f(v)
        end
    end
    return t
end

--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    
    Higher Mathematical Computation
        > Number Theory
            > Number Theoretic Functions

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

--[[
    ml "GCD" {
        n1, n2, n3, ... : number
    }: number
    
    Returns the greatest common divisor of all n_i using the Euclidean Algorithm.
        
    T/S: O(log(math.max(...))), O(1)
    
--]]
function ml.GCD(...)
    local t = ...
    if #t == 1 then
        return t[1]
    end
    local function gcd(a, b)
        if a == 0 then
            return b
        elseif b == 0 then
            return a
        end
        return gcd(b, a % b)
    end
    local result = gcd(t[1], t[2])
    for i=3, #t do
        result = gcd(result, t[i])
    end
    return result
end

--[[
    ml "EulerPhi" {
        n : number
    }: number
    
    Computes the Euler totient function of n.
        
    T/S: O(sqrt(n)), O(1)
    
--]]
function ml.EulerPhi(p)
    local result, n, i = p[1], p[1], 2
    if not ml "IntegerQ" {n} then
        return warn("must be an integer")
    end
    while i^2 <= n do
        if n % i == 0 then
            result = result - math.floor(result / i)
            while n % i == 0 do
                n = math.floor(n / i)
            end
        end
    i = i + 1
    end
    if n > 1 then
        result = result - math.floor(result / n)
    end
    return result
end

--[[ ---------- ---------- ---------- ---------- ---------- ---------- ----------

    Final handling;

--]] ---------- ---------- ---------- ---------- ---------- ---------- ----------

return ml

