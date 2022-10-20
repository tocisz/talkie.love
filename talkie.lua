local love = require("love")
local bit = require("bit")
local bitstream = require("bitstream")
local band, bxor, rshift = bit.band, bit.bxor, bit.rshift

local talkie = {}

local function decode8x(s, d, m)
	local a = {}
	for i = 1, string.len(s) do
		table.insert(a, love.data.unpack(d, s, i)*m)
	end
	return a
end
local function decode8(s) return decode8x(s, "b", 1/2^7) end
local function decode8e(s) return decode8x(s, "B", 1/2^9) end
local function decode8p(s) return decode8x(s, "B", 1) end

local function decode16(s)
	local m = 1/2^15
	local a = {}
	for i = 1, string.len(s)/2 do
		table.insert(a, love.data.unpack("<h", s, i*2-1)*m)
	end
	return a
end

-- CONSTANTS
-- luacheck: push no max line length
local chirp = decode8("\0*\212\50\178\18%\20\2\225\197\2_Z\5\15&\252\165\165\214\221\220\252%+\34!\15\255\248\238\237\239\247\246\250\0\3\2\1")
local tmsEnergy = decode8e("\0\2\3\4\5\7\10\15\20 )\57Qr\161") -- 0 - 0.62890625 / 2
local tmsPeriod = decode8p("\0\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31 !\34#$%&'()*+-/\49\51\53\54\57;=?BEGIMOQUW\92_cfjnsw{\128\133\138\143\149\154\160")
local tmsK1 = decode16("\192\130\128\131\192\131@\132\192\132@\133\0\134\128\135\128\136\128\137\192\138\0\140@\141\0\143\192\144\192\146\0\153@\161\128\171@\184@\199\192\216\192\235\0\0@\20@'\192\56\192G\128T\192^\0g@m")
local tmsK2 = decode16("\0\174\128\180\128\187@\195\128\203@\212\192\221\128\231\128\241\192\251\0\6@\16@\26\0$@-\0\54@>\192E\192L\0S\128X\192]@b@f\192i\192l\128o\192q\192s\128u\0w\128~")
local tmsK3 = decode8("\146\159\173\186\200\213\227\240\254\11\25&\52AO\92")
local tmsK4 = decode8("\174\188\202\216\230\244\1\15\29+\57GUcq~")
local tmsK5 = decode8("\174\186\197\209\221\232\244\255\11\23\34.\57EQ\92")
local tmsK6 = decode8("\192\203\214\225\236\247\3\14\25$/:EP[f")
local tmsK7 = decode8("\179\191\203\215\227\239\251\7\19\31+\55COZf")
local tmsK8 = decode8("\192\216\240\7\31\55Of")
local tmsK9 = decode8("\192\212\232\252\16%\57M")
local tmsK10 = decode8("\205\223\241\4\22 ;M") -- -0.3984375 - 0.6015625
-- luacheck: pop
local rate = 8000 -- samples per second
local ticks = rate / 40

local function getFrameCount(bits)
	local energy, rep, period
	local frames = 0
	bits:reset()
	while true do
		energy = bits:get(4)
		if energy == 0 then -- rest
			frames = frames + 1
		elseif energy == 0xf then -- stop
			break
		else
			rep = bits:get(1)
			period = bits:get(6) -- tmsPeriod[1] == 0
			if rep == 0 then
				bits:skip(18) -- K1-K4
				if period ~= 0 then
					bits:skip(21) -- K5-K10
				end
			end
			frames = frames + 1
		end
	end
	return frames
end

-- local state
local synthEnergy, synthPeriod, synthK1, synthK2, synthK3, synthK4
local synthK5, synthK6, synthK7, synthK8, synthK9, synthK10
local x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, u0
local synthRand, periodCounter, s, t

local function reset()
	synthEnergy, synthPeriod, synthK1, synthK2, synthK3, synthK4 = 0, 0, 0, 0, 0, 0
	synthK5, synthK6, synthK7, synthK8, synthK9, synthK10 = 0, 0, 0, 0, 0, 0
	x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, u0 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	synthRand = 1
	periodCounter = 1
	s = 0 -- output sample
	t = ticks -- tick in a frame
end

local function randomBit()
	local br = band(synthRand, 1) == 1
	synthRand = rshift(synthRand, 1)
	if br then
		synthRand = bxor(synthRand, 0xB800)
	end
	return br
end

local function doSynth(soundData, bits)
	reset()
	bits:reset()
	while true do
		if t >= ticks then
			local energy = bits:get(4)
			if energy == 0 then -- rest
				synthEnergy = 0
			elseif energy == 0xf then -- stop
				break
			else
				synthEnergy = tmsEnergy[energy+1]
				local rep = bits:get(1)
				synthPeriod = tmsPeriod[bits:get(6)+1] -- tmsPeriod[1] == 0
				if rep == 0 then
					synthK1 = tmsK1[bits:get(5)+1]
					synthK2 = tmsK2[bits:get(5)+1]
					synthK3 = tmsK3[bits:get(4)+1]
					synthK4 = tmsK4[bits:get(4)+1]
					if synthPeriod ~= 0 then
						synthK5 = tmsK5[bits:get(4)+1]
						synthK6 = tmsK6[bits:get(4)+1]
						synthK7 = tmsK7[bits:get(4)+1]
						synthK8 = tmsK8[bits:get(3)+1]
						synthK9 = tmsK9[bits:get(3)+1]
						synthK10 = tmsK10[bits:get(3)+1]
					else
						x9 = 0
						x8 = 0
						x7 = 0
						x6 = 0
						x5 = 0
					end
				end
			end
			t = 0
		end

		if synthPeriod ~= 0 then -- voiced
			periodCounter = periodCounter + 1
			if periodCounter > synthPeriod then periodCounter = 1 end
			u0 = periodCounter <= #chirp and chirp[periodCounter] * synthEnergy or 0
		else -- unvoiced
			u0 = randomBit() and synthEnergy or -synthEnergy
		end
		if synthPeriod ~= 0 then
			u0 = u0 - (synthK10*x9 + synthK9*x8)
			x9 = x8 + synthK9*u0
			u0 = u0 - synthK8*x7
			x8 = x7 + synthK8*u0
			u0 = u0 - synthK7*x6
			x7 = x6 + synthK7*u0
			u0 = u0 - synthK6*x5
			x6 = x5 + synthK6*u0
			u0 = u0 - synthK5*x4
			x5 = x4 + synthK5*u0
		end
		u0 = u0 - synthK4*x3
		x4 = x3 + synthK4*u0
		u0 = u0 - synthK3*x2
		x3 = x2 + synthK3*u0
		u0 = u0 - synthK2*x1
		x2 = x1 + synthK2*u0
		u0 = u0 - synthK1*x0
		x1 = x0 + synthK1*u0

		x0 = math.max(math.min(u0, 1), -1)

		soundData:setSample(s, x0)
		t = t + 1
		s = s + 1
	end -- while true
end

function talkie.synth(bitString)
    local bits = bitstream.Bits:new(bitString)
    local length = getFrameCount(bits)*ticks
    print("length is "..(length/rate).."s")
    local soundData = love.sound.newSoundData(length, rate, 16, 1)
    doSynth(soundData, bits)
    return soundData
end

return talkie