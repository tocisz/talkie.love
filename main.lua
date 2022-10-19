local love = require("love")
local talkie = require("talkie")

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

local soundData = talkie.synth(hastalavista)
local source = love.audio.newSource(soundData)
source:setLooping(true)

function love.load()
    source:play()
end