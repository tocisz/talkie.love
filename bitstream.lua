local love = require("love")
local bit = require("bit")
local band, bor, rshift, lshift = bit.band, bit.bor, bit.rshift, bit.lshift

local bitstream = {
    Bits = {}
}

bitstream.Bits.__index = bitstream.Bits
function bitstream.Bits:new(s)
    local o = {
        bitString = s,
        addr = 8
    }
    setmetatable(o, self)
    return o
end

function bitstream.Bits:reset()
    self.addr = 8
end

local function brev(a)
	a = bor(lshift(a, 4), rshift(a, 4))
	a = bor(lshift(band(a, 0x33), 2), rshift(band(a, 0xcc), 2))
	a = bor(lshift(band(a, 0x55), 1), rshift(band(a, 0xaa), 1))
	return band(a, 0xff)
end

function bitstream.Bits:get(bits)
    local i = rshift(self.addr, 3)
	local b = band(self.addr, 7)
	local data = lshift(brev(love.data.unpack("B", self.bitString, i)), 8)
	if b + bits > 8 then
		data = bor(data, brev(love.data.unpack("B", self.bitString, i+1)))
	end
	data = band(lshift(data, b), 0xffff)
	local value = rshift(data, 16-bits)
	self.addr = self.addr + bits
	return value
end

function bitstream.Bits:skip(bits)
	self.addr = self.addr + bits
end

return bitstream