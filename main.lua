local love = require("love")
local bit = require("bit")
local band, bor, bxor, rshift, lshift = bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local function decode8x(s, d, m)
	local a = {}
	for i = 1, string.len(s) do
		table.insert(a, love.data.unpack(d, s, i)*m)
	end
	return a, string.len(s)
end
local function decode8(s) return decode8x(s, "b", 1/2^7) end
local function decode8u(s) return decode8x(s, "B", 1/2^9) end
local function decode8w(s) return decode8x(s, "B", 1) end

local function decode16(s)
	local m = 1/2^15
	local a = {}
	for i = 1, string.len(s)/2 do
		table.insert(a, love.data.unpack("<h", s, i*2-1)*m)
	end
	return a, string.len(s)/2
end

local chirp, chirp_len = decode8("\0*\212\50\178\18%\20\2\225\197\2_Z\5\15&\252\165\165\214\221\220\252%+\34!\15\255"..
	"\248\238\237\239\247\246\250\0\3\2\1")
local tmsEnergy = decode8u("\0\2\3\4\5\7\10\15\20 )\57Qr\161") -- 0 - 0.62890625 / 2
local tmsPeriod = decode8w("\0\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31 !\34#$%&'()*+-/\49\51\53\54\57;=?BEGIM"..
	"OQUW\92_cfjnsw{\128\133\138\143\149\154\160")
local tmsK1 = decode16("\192\130\128\131\192\131@\132\192\132@\133\0\134\128\135\128\136\128\137\192\138\0\140@\141\0"..
	"\143\192\144\192\146\0\153@\161\128\171@\184@\199\192\216\192\235\0\0@\20@'\192\56\192G\128T\192^\0g@m")
local tmsK2 = decode16("\0\174\128\180\128\187@\195\128\203@\212\192\221\128\231\128\241\192\251\0\6@\16@\26\0$@-\0"..
	"\54@>\192E\192L\0S\128X\192]@b@f\192i\192l\128o\192q\192s\128u\0w\128~")
local tmsK3 = decode8("\146\159\173\186\200\213\227\240\254\11\25&\52AO\92")
local tmsK4 = decode8("\174\188\202\216\230\244\1\15\29+\57GUcq~")
local tmsK5 = decode8("\174\186\197\209\221\232\244\255\11\23\34.\57EQ\92")
local tmsK6 = decode8("\192\203\214\225\236\247\3\14\25$/:EP[f")
local tmsK7 = decode8("\179\191\203\215\227\239\251\7\19\31+\55COZf")
local tmsK8 = decode8("\192\216\240\7\31\55Of")
local tmsK9 = decode8("\192\212\232\252\16%\57M")
local tmsK10 = decode8("\205\223\241\4\22 ;M") -- -0.3984375 - 0.6015625

-- local function printa(a, l)
-- 	for i = 1, l do
-- 		print(a[i])
-- 	end
-- end
-- printa(chirp, chirp_len)
-- printa(tmsEnergy, tmsEnergy_len)
-- printa(tmsPeriod, tmsPeriod_len)
-- printa(tmsK2, tmsK2_len)
-- printa(tmsK10, tmsK10_len)

local hastalavista = "\14\224>bm\201x\168\137\237\213'\233\174aq\3\0jE\0@r/\128\169l\13\240U\226\52\169Ghe\237\211"..
	"\164\154a\229\139O\147z\152w,>Mn\158R\217\248\180\57D\154g\149\0\240\16\158\0b<\18\0eg\2\180\236H\0\148\17+\201\34"..
	"\210\130-\173$K\13\13M\236\0\236\51\29\0\92\198\10\170\54\215P;\199\143J+\194\235\156,k\11w\155s\234\148\204(\179v"..
	"\2P\15s\0h\225\14\128\53=\0\188\178\157>V\51\169\170s\250T\220)\162\246\25b\12\163\202\198\171\8\222\221<f\27\0"..
	"\230t\7\128\146i\0\144+W\159,\187U\52\57}\214\28>\17\251tAj\198x\228\213\23E\225\19\177\207\144\148D\148'\57C\145j"..
	"Z>\51\0@f&@\147\200\4\48^\21\0\198\179\28\0LG\0@\168p\0H\21\6\192\49\195\0\192g\56\0z\247\0\224\230q\134\224\34\173"..
	"\178\210\26\130\139\136\138Zk\201\198\195B\27;\0ew\7\128\16e\0\146\34\28 \141\165\3\152\51\51\0\180\225\6\0\49\211"..
	"\0 T\181.\51IK\143\51\150\34\52$\220\138\1\128\143\48\0\240\149\10\192\189\202\0 g\181&J\201LM\210\154\204\53\204=n"..
	"\155\50\179\240\176\56-\203B\194Rm\183,ss\203H\218\202\194$,\180n+\51\151\140\244\56-+LC\194\227*\0\184*\5\128T\161"..
	"\0\16\50\29\128\156\212\169kf\151\140\185\167\174\153]*\151\158\182\21v\141\156z\134\18(\162kJ\1\162\165\10\128\244"..
	">\1\144\214f\141UaFg\212\53f\201\25\19\147\219\152\165\186v&i[\213j\20\17G\0\192f)\0x\235\51U\207\170\29\179\215\92"..
	"-\185tW]S\49d:Ue-\205\177J\231\212\181\20M\17SU\215\154\13\185oU\25[R\18\185Y\214\1\204{;\128+k\3\0\169m\0\164\188"..
	"\12\192\180\167\2\160\241T\0\208\17\2\128\206C\1\192f)\0\184L\1\0\159\165\0\224#\5\0\156\167\0\128\139\18\0\48\158"..
	"\2\0\54\18\8\221e\152\155\217~"

local function brev(a)
	a = bor(lshift(a, 4), rshift(a, 4))
	a = bor(lshift(band(a, 0x33), 2), rshift(band(a, 0xcc), 2))
	a = bor(lshift(band(a, 0x55), 1), rshift(band(a, 0xaa), 1))
	return a
end

local addr = 8
local bitString = hastalavista
local function getBits(bits)
	local i = rshift(addr, 3)
	local b = band(addr, 7)
	local data = lshift(brev(love.data.unpack("B", bitString, i)), 8)
	if b + bits > 8 then
		data = bor(data, brev(love.data.unpack("B", bitString, i+1)))
	end
	data = band(lshift(data, b), 0xffff)
	local value = rshift(data, 16-bits)
	addr = addr + bits
	return value
end

local function skipBits(bits)
	addr = addr + bits
end

local function getFrameCount()
	local energy, rep, period
	local frames = 0
	while true do
		energy = getBits(4)
		if energy == 0 then -- rest
			frames = frames + 1
		elseif energy == 0xf then -- stop
			break
		else
			rep = getBits(1)
			period = getBits(6) -- tmsPeriod[1] == 0
			if rep == 0 then
				skipBits(18) -- K1-K4
				if period ~= 0 then
					skipBits(21) -- K5-K10
				end
			end
			frames = frames + 1
		end
	end
	addr = 8
	return frames
end

local rate      = 8000 -- samples per second
local ticks     = rate / 40
local length    = getFrameCount()*ticks
print("length is "..(length/rate).."s")
local soundData = love.sound.newSoundData(length, rate, 16, 1)

local synthEnergy, synthPeriod, synthK1, synthK2, synthK3, synthK4 = 0, 0, 0, 0, 0, 0
local synthK5, synthK6, synthK7, synthK8, synthK9, synthK10 = 0, 0, 0, 0, 0, 0
local x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, u0 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
local synthRand = 1
local periodCounter = 0

local s = 0 -- output sample
local t = ticks -- tick in a frame
local function doSynth()
	while true do
		if t >= ticks then
			local energy = getBits(4)
			if energy == 0 then -- rest
				synthEnergy = 0
			elseif energy == 0xf then -- stop
				break
			else
				synthEnergy = tmsEnergy[energy+1]
				local rep = getBits(1)
				synthPeriod = tmsPeriod[getBits(6)+1] -- tmsPeriod[1] == 0
				if rep == 0 then
					synthK1 = tmsK1[getBits(5)+1]
					synthK2 = tmsK2[getBits(5)+1]
					synthK3 = tmsK3[getBits(4)+1]
					synthK4 = tmsK4[getBits(4)+1]
					if synthPeriod ~= 0 then
						synthK5 = tmsK5[getBits(4)+1]
						synthK6 = tmsK6[getBits(4)+1]
						synthK7 = tmsK7[getBits(4)+1]
						synthK8 = tmsK8[getBits(3)+1]
						synthK9 = tmsK9[getBits(3)+1]
						synthK10 = tmsK10[getBits(3)+1]
					end
				end
			end
			t = 0
		end

		if synthPeriod ~= 0 then -- voiced
			periodCounter = periodCounter + 1
			if periodCounter >= synthPeriod then periodCounter = 0 end
			u0 = periodCounter < chirp_len and chirp[periodCounter+1] * synthEnergy or 0
		else -- unvoiced
			local br = band(synthRand, 1) == 1
			synthRand = rshift(synthRand, 1)
			if br then
				synthRand = bxor(synthRand, 0xB800)
				u0 = synthEnergy
			else
				u0 = -synthEnergy
			end
		end
		u0 = u0 - synthK10*x9 + synthK9*x8
		x9 = x8 + synthK9*u0
		u0 = u0 - synthK8*x7
		x8 = x7 + synthK8*u0
		u0 = u0 - synthK7*x6
		x7 = x6 + synthK7*u0
		u0 = u0 - synthK6*x5
		x6 = x5 + synthK6*u0
		u0 = u0 - synthK5*x4
		x5 = x4 + synthK5*u0
		u0 = u0 - synthK4*x3
		x4 = x3 + synthK4*u0
		u0 = u0 - synthK3*x2
		x3 = x2 + synthK3*u0
		u0 = u0 - synthK2*x1
		x2 = x1 + synthK2*u0
		u0 = u0 - synthK1*x0
		x1 = x0 + synthK1*u0

		u0 = math.max(math.min(u0, 1), -1)
		x0 = u0

		soundData:setSample(s, x0)
		t = t + 1
		s = s + 1
	end -- while true
end

doSynth()

local source = love.audio.newSource(soundData)
source:setLooping(true)

function love.load()
    source:play()
end