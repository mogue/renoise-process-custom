--[[

    A Collection of Interpolation Methods

    Trying to design these as lightweight as possible.

    https://stackoverflow.com/questions/1125666/how-do-you-do-bicubic-or-other-non-linear-interpolation-of-re-sampled-audio-da#1126161
    https://www.paulinternet.nl/?page=bicubic

]]--


----------------------------------------
--      Linear                        --
----------------------------------------

local function TableLinear(array, sample_time)
    local x0, x1, t = 0, 0, 0
    if sample_time >= 1 then 
        x0 = array[ math.floor(sample_time) ] 
    end
    if sample_time < #array then
        x1 = array[ math.ceil(sample_time) ]
    end
    t = math.fmod(sample_time, 1)
    return (x0 * (1-t)) + (x1 * t)
end

local function BufferLinear(buffer, channel, sample_time)
    local x0, x1, t = 0, 0, 0
    if sample_time >= 1 then
        x0 = buffer:sample_data( channel, math.floor(sample_time) )
    end
    if sample_time < buffer.number_of_frames then
        x1 = buffer:sample_data( channel, math.ceil(sample_time) )
    end
    t = math.fmod(sample_time, 1)
    return (x0 * (1-t)) + (x1 * t)
end

----------------------------------------
--      Cubic                         --
----------------------------------------

local function TableCubic(array, sample_time)
    local x0, x1, x2, x3 = 0, 0, 0, 0
    if sample_time >= 2 then
        x0 = array[ math.floor(sample_time) - 1 ]
        x1 = array[ math.floor(sample_time)     ]
    elseif sample_time >= 1 then
        x1 = array[ 1 ]
    end

    if sample_time <= #array - 1 then
        x2 = array[ math.ceil(sample_time)     ]
        x3 = array[ math.ceil(sample_time) + 1 ]
    elseif sample_time <= #array then
        x2 = array[ #array ]
    end

    local t = math.fmod(sample_time, 1)

    local a0, a1, a2, a3 = 0, 0, 0, 0
    a0 = x3 - x2 - x0 + x1
    a1 = x0 - x1 - a0
    a2 = x2 - x0
    a3 = x1
    return (a0 * (t * t * t)) + (a1 * (t * t)) + (a2 * t) + (a3)
end

local function BufferCubic(buffer, channel, sample_time)
    if (sample_time < 1 or sample_time > buffer.number_of_frames) then
        return 0
    end
    local x0, x1, x2, x3 = 0, 0, 0, 0
    if sample_time >= 2 then
        x0 = buffer:sample_data( channel, math.floor(sample_time) - 1 )
        x1 = buffer:sample_data( channel, math.floor(sample_time)     )
    elseif sample_time >= 1 then
        x1 = buffer:sample_data( channel, 0 )
    end

    if sample_time < buffer.number_of_frames - 2 then
        x2 = buffer:sample_data( channel, math.ceil(sample_time)     )
        x3 = buffer:sample_data( channel, math.ceil(sample_time) + 1 )
    elseif sample_time < buffer.number_of_frames then
        x2 = buffer:sample_data( channel, buffer.number_of_frames - 1 )
    end

    local t = math.fmod(sample_time, 1)

    local a0, a1, a2, a3 = 0, 0, 0, 0
    a0 = x3 - x2 - x0 + x1
    a1 = x0 - x1 - a0
    a2 = x2 - x0
    a3 = x1
    return (a0 * (t * t * t)) + (a1 * (t * t)) + (a2 * t) + (a3)
end

----------------------------------------
--      Hermite                       --
----------------------------------------

local function TableHermite(array, sample_time)
    local x0, x1, x2, x3 = 0, 0, 0, 0
    if sample_time >= 2 then
        x0 = array[ math.floor(sample_time) - 1 ]
        x1 = array[ math.floor(sample_time)     ]
    elseif sample_time >= 1 then
        x1 = array[ 1 ]
    end

    if sample_time <= #array - 1 then
        x2 = array[ math.ceil(sample_time)     ]
        x3 = array[ math.ceil(sample_time) + 1 ]
    elseif sample_time <= #array then
        x2 = array[ #array ]
    end

    local t = math.fmod(sample_time, 1)

    local c0 = x1;
    local c1 = .5 * (x2 - x0);
    local c2 = x0 - (2.5 * x1) + (2 * x2) - (.5 * x3);
    local c3 = (.5 * (x3 - x0)) + (1.5 * (x1 - x2));
    return (((((c3 * t) + c2) * t) + c1) * t) + c0;
end

local function BufferHermite(buffer, channel, sample_time)
    if (sample_time < 1) or (sample_time > buffer.number_of_frames) then
        return 0
    end

    local x0, x1, x2, x3 = 0, 0, 0, 0
    if sample_time >= 2 then
        x0 = buffer:sample_data( channel, math.floor(sample_time) - 1 )
        x1 = buffer:sample_data( channel, math.floor(sample_time)     )
    elseif sample_time >= 1 then
        x1 = buffer:sample_data( channel, 1 )
    end

    if sample_time < buffer.number_of_frames - 2 then
        x2 = buffer:sample_data( channel, math.ceil(sample_time)     )
        x3 = buffer:sample_data( channel, math.ceil(sample_time) + 1 )
    elseif sample_time < buffer.number_of_frames then
        x2 = buffer:sample_data( channel, buffer.number_of_frames )
    end

    local t = math.fmod(sample_time, 1)

    local c0 = x1;
    local c1 = .5 * (x2 - x0);
    local c2 = x0 - (2.5 * x1) + (2 * x2) - (.5 * x3);
    local c3 = (.5 * (x3 - x0)) + (1.5 * (x1 - x2));
    return (((((c3 * t) + c2) * t) + c1) * t) + c0;
end

return {
    TableLinear     = TableLinear,
    TableCubic      = TableCubic,
    TableHermite    = TableHermite,
    BufferLinear    = BufferLinear,
    BufferCubic     = BufferCubic,
    BufferHermite   = BufferHermite,
}