
--[[

    the mlua library -
    Inspired by the Wolfram Language.
    
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

--[[

    Core Language and Structure

--]]

--[[
    
    ml "TypeQ" {
        n: any?;
        t: string;
    } -> boolean
    
    Checks whether n is of type t.

--]]
function ml.TypeQ(p)
    return typeof(p[1]) == p[2]
end

--[[
    
    ml "IntegerQ" {
        n: any?;
    } -> boolean
    
    Checks whether n is an integer.

--]]
function ml.IntegerQ(p)
    return p[1] % 1 == 0
end

--[[
    
    ml "Range" {
        imin: number;
        imax: number;
        di: number or 1;
    } -> table
    
    Returns the table {imin, ..., imax} using steps di.

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

    Data Manipulation and Analysis
    
    Array Manipulation, Data Transformation & Filtering, Statistical Data Analysis,
    Machine Learning

--]]


--[[

    ml "Map" {
        f: function;
        t: table;
        level: number or 1;
    } -> table
    
    Applies a function to each element on the n-th level in a table.
        
    Time complexity: O(#t * max depth)
    Space complexity: O(1)
    
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

--[[

    ml "Flatten" {
        t: table;
        level: number or 1;
    } -> table
    
    Flattens out nested tables to the n-th level.
        
    Time complexity: O(#t)
    Space complexity: O(#t)
    
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

    ml "DeleteDuplicates" {
        t: table;
    } -> table
    
    Deletes all duplicates from a table, leaving only one of each element.
        
    Time complexity: O(#t)
    Space complexity: O(#t)
    
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

    ml "Drop" {
        t: table;
        index: number / table;
    } -> table
    
    ml "Drop" {t: table, n: number} gives list with its first n elements dropped.
    ml "Drop" {t: table, -n: number} gives list with its last n elements dropped.
    ml "Drop" { t: table, {n: number} } gives list with its n-th element dropped.
    ml "Drop" { t: table, {m: number, n: number} } gives list with elements m through n dropped.
    ml "Drop" { t: table, {m: number, n: number, s: number} } gives list with elements m through n in steps of s dropped.
        
    Time complexity: O(#t)
    Space complexity: O(#t)
    
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

    ml "Partition" {
        t: table;
        n: number or 1;
    } -> table
    
    Paritions table into nonoverlapping subtables of length n.
        
    Time complexity: O(1)
    Space complexity: O(#t)
    
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

    ml "FindDivisions" {
        {imin: number, imax: number};
        n: number;
        dx: number?;
    } -> table
    
    Returns a list of about n "nice" numbers that divide the interval around imin to imax into equally spaced parts.
    An optional parameter dx makes the parts always have lengths that are integer multiples of dx.
        
    Time complexity: O(n)
    Space complexity: O(n)
    
--]]
function ml.FindDivisions(p)
    local imin, imax, n, dx = p[1][1], p[1][2], p[2], p[3] or math.floor(p[1][2]-p[1][1]) / p[2]
    local divisions = {}
    while imin <= imax do
        divisions[#divisions+1] = imin
        imin = imin + dx
    end
    return divisions
end
    
--[[

    ml "Shuffle" {
        t: table;
        n: number or 1;
    } -> table
    
    Performs a Fisher-Yates shuffle on a table n times.
        
    Time complexity: O(n * #t)
    Space complexity: O(1)
    
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
    } -> table
    
    Riffles, or "interleaves" tables t1 and t2 together.
    
    For example, {a1, a2, ...}, {b1, b2, ...} -> {a1, b1, a2, b2, ...}
                 {a1, a2, a3}, {b1} -> {a1, b1, a2, b1, a3}
                 {a1, a2, a3}, {b1, b2} -> {a1, b1, a2, b2, a3}
        
    Time complexity: O(#t1)
    Space complexity: O(#t1)
    
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

--[[

    ml "RandomChoice" {
        t: table;
        weights: (number or table)?;
    } -> table
    
    ml "RandomChoice" {t: table} gives a pseudorandom choice of one of the elements in t.
    ml "RandomChoice" {t: table, n: number} gives a list of n pseudorandom choices.
    ml "RandomChoice" {t: table, weights: table} gives a pseudorandom choice weighted by weights. For example, ml "RandomChoice" { {1, 2, 3}, {0.1, 0.5, 1} }.

    Time complexity: O(#t)
    Space complexity: O(1)
    
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

--[[

    Higher Mathematical Computation
    
    Polynomial Algebra, Linear Algebra, Tensor Algebra,
    Real & Complex Analysis, Discrete Calculus, Iterated Maps & Fractals,
    Neural Networks, Probability Theory, Random Processes,
    Discrete Math, Number Theory, Group Theory,
    Mathematical Data, Cryptography, Logic & Boolean Algebra

--]]

--[[

    ml "GCD" {
        n1, n2, n3, ... : number
    } -> number
    
    Returns the greatest common divisor of all n_i using the Euclidean Algorithm.
        
    Time complexity: O(log(math.max(...)))
    Space complexity: O(1)
    
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
    } -> number
    
    Computes the Euler totient function of n.
        
    Time complexity: O(sqrt(n))
    Space complexity: O(1)
    
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

return ml
