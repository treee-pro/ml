
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
    
    !!
    NEEDS HELP!
    Its time complexity can be improved to O(#t log #t) if we use Binary Search instead of a hash table.
    I don't know how to. If you can, please send a pull-request, defining ml "BinarySearch". Thanks!
    !!

    ml "DeleteDuplicates" {
        t: table;
    } -> table
    
    Deletes all duplicates from a table, leaving only one of each element.
        
    Time complexity: O(#t log #t)
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

--[[
    
    Tests
    
--]]

-- return
return ml
