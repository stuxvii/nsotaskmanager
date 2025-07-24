-- lots of love to needy streamer overload and ame
-- credits to spriters resource for the icon sprites rips and the love2d wiki/forums
-- also to stack overflow
-- and to the lua handbook
-- i am not making this work on windows fuck you

function love.load()
    processes = love.graphics.newImage("img/processes.png")
    cpu = love.graphics.newImage("img/cpu.png")
    ram = love.graphics.newImage("img/ram.png")
    disk = love.graphics.newImage("img/disk.png")

    cpuypos = 100
    cpuxpos = 66
    cpuflip = false

    memypos = 160
    memxpos = 66
    memflip = false
    
    diskypos = 220
    diskxpos = 66
    diskflip = false

    cpubar = 338
    membar = 338
    dskbar = 338

    -- default placeholder values
    prcnt = 1001
    cpuus = 100
    freemem = 100
    diskus = 100

end

local ffi = require("ffi")

ffi.cdef[[
    typedef struct FILE FILE;
    FILE *popen(const char *command, const char *mode);
    int pclose(FILE *stream);
    char *fgets(char *s, int size, FILE *stream);
]]

local function getout(command)
    local f = ffi.C.popen(command, "r")
    if f == nil then return nil end

    local BUFSIZE = 256
    local buffer = ffi.new("char[?]", BUFSIZE)

    local result = ""
    if ffi.C.fgets(buffer, BUFSIZE, f) ~= nil then
        result = ffi.string(buffer)
    end

    ffi.C.pclose(f)
    return result:match("^%s*(.-)%s*$")  -- trim result
end

cpugraphs = {}
cpugraphs.list = {}

function newcpugraph(x,y,w,h)
    if cpubar == 218 then
        cpugraphs = {}
        cpugraphs.list = {}
        cpubar = 338
    end
    local graph = {}
    graph.x=cpubar
    graph.y=130
    graph.w=2
    graph.h=-cpuus/2
    cpubar = cpubar - 2

    table.insert(cpugraphs, graph)
    return graph
end

memgraphs = {}
memgraphs.list = {}

function newramgraph(x,y,w,h)
    if membar == 218 then
        memgraphs = {}
        memgraphs.list = {}
        membar = 338
    end
    local graph = {}
    graph.x=membar
    graph.y=195
    graph.w=2
    graph.h=-freemem/2
    membar = membar - 2

    table.insert(memgraphs, graph)
    return graph
end

dskgraphs = {}
dskgraphs.list = {}

function newdskgraph(x,y,w,h)
    if dskbar == 218 then
        dskgraphs = {}
        dskgraphs.list = {}
        dskbar = 338
    end
    local graph = {}
    graph.x=dskbar
    graph.y=260
    graph.w=2
    graph.h=-diskus/2
    dskbar = dskbar - 2
    
    table.insert(dskgraphs, graph)
    return graph
end

function love.update(dt)
    prcnt = getout("ps -eo pid | wc -l")
    cpuus = getout("./binblobs/cpu")
    freemem = getout("./binblobs/mem")
    diskus = getout("./binblobs/disk")

    if tonumber(cpuus) > 80 then
        if cpuypos < 110 and not cpuflip then
            cpuypos = cpuypos + 5
            cpuxpos = cpuxpos + 5
            if cpuypos == 110 then
                cpuflip = true
            end
        elseif cpuypos > 90 and cpuflip then
            cpuypos = cpuypos - 5
            cpuxpos = cpuxpos - 5
            if cpuypos == 90 then
                cpuflip = false
            end
        end
    else
	    cpuypos = 100
        cpuxpos = 66
    end

    if tonumber(freemem) > 80 then
        if memypos < 170 and not memflip then
            memypos = memypos + 5
            memxpos = memxpos + 5
            if memypos == 170 then
                memflip = true
            end
        elseif memypos > 150 and memflip then
            memypos = memypos - 5
            memxpos = memxpos - 5
            if memypos == 150 then
                memflip = false
            end
        end
    else
	    memypos = 160
        memxpos = 66
    end

    if tonumber(freemem) > 80 then
        if diskypos < 230 and not memflip then
            diskypos = diskypos + 5
            diskxpos = diskxpos + 5
            if diskypos == 230 then
                memflip = true
            end
        elseif diskypos > 210 and memflip then
            diskypos = diskypos - 5
            diskxpos = diskxpos - 5
            if diskypos == 210 then
                memflip = false
            end
        end
    else
	    diskypos = 220
        diskxpos = 66
    end

    newcpugraph()
    newramgraph()
    newdskgraph()
    collectgarbage("collect") -- gotta do this because fuck i know love2d is a bitch with ram and i want it to not occupy fucking 200mbs
end

function love.draw()
    love.graphics.setBackgroundColor(0.988, 0.941, 0.992)
    
    section = love.graphics.newFont('fonts/dinkiebitmap.ttf', 14)
    big = love.graphics.newFont('fonts/retro.ttf', 40)
    normal = love.graphics.newFont('fonts/retro.ttf', 24) 
    limit = love.graphics.newFont('fonts/retro.ttf', 16)
    
    love.graphics.setFont(section)
    love.graphics.setColor(0.361,0.702,0.875)
    
    love.graphics.print('Processes', 64, 16)
    love.graphics.print('CPU Usage', 64, 84)
    love.graphics.print('RAM Usage', 64, 146)
    love.graphics.print('Disk Usage', 64, 205)
    love.graphics.setFont(big)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(processes, 10, 25)
    love.graphics.draw(cpu, 10, 85)
    love.graphics.draw(ram, 10, 145)
    love.graphics.draw(disk, 10, 205)
    love.graphics.setColor(0.302,0.129,0.796)
    love.graphics.print(prcnt, 66, 32)
    love.graphics.setFont(normal)
    
    if tonumber(cpuus) > 80 then
	    love.graphics.setColor(1,0,0)
    end
    love.graphics.print(cpuus, cpuxpos, cpuypos)

    love.graphics.setColor(0.302,0.129,0.796)
    if tonumber(freemem) > 80 then
	    love.graphics.setColor(1,0,0)
    end
    love.graphics.print(freemem, memxpos, memypos)
    
    love.graphics.setColor(0.302,0.129,0.796)
    if tonumber(diskus) > 80 then
	    love.graphics.setColor(1,0,0)
    end
    love.graphics.print(diskus, diskxpos, diskypos)
    
    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.setFont(limit)
    love.graphics.print("/100", 141, 110)
    love.graphics.print("/100", 141, 170)
    love.graphics.print("/100", 141, 230)

    love.graphics.setColor(0.859,0.745,0.929)
    love.graphics.rectangle("fill", 220, 80, 120, 50)
    love.graphics.rectangle("fill", 220, 145, 120, 50)
    love.graphics.rectangle("fill", 220, 210, 120, 50)
    love.graphics.setColor(0.361,0.702,0.875)
    
    for k,v in ipairs(cpugraphs) do
        love.graphics.rectangle("fill", v.x,v.y,v.w,v.h)
    end
    for k,v in ipairs(memgraphs) do
        love.graphics.rectangle("fill", v.x,v.y,v.w,v.h)
    end
    for k,v in ipairs(dskgraphs) do
        love.graphics.rectangle("fill", v.x,v.y,v.w,v.h)
    end
end
