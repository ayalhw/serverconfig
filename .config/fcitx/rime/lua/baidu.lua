local json = require("dkjson")
local io = require("io")

local code = {
    ["ca"] = "ca",
    ["cb"] = "cou",
    ["ce"] = "ce",
    ["cg"] = "ceng",
    ["cf"] = "cen",
    ["ci"] = "ci",
    ["ch"] = "cang",
    ["ck"] = "cao",
    ["cj"] = "can",
    ["cl"] = "cai",
    ["co"] = "cuo",
    ["cp"] = "cun",
    ["cs"] = "cong",
    ["cr"] = "cuan",
    ["cu"] = "cu",
    ["cv"] = "cui",
    ["ba"] = "ba",
    ["bc"] = "biao",
    ["bg"] = "beng",
    ["bf"] = "ben",
    ["bi"] = "bi",
    ["bh"] = "bang",
    ["bk"] = "bao",
    ["bj"] = "ban",
    ["bm"] = "bian",
    ["bl"] = "bai",
    ["bo"] = "bo",
    ["bn"] = "bin",
    ["bu"] = "bu",
    ["by"] = "bing",
    ["bx"] = "bie",
    ["bz"] = "bei",
    ["da"] = "da",
    ["dc"] = "diao",
    ["db"] = "dou",
    ["de"] = "de",
    ["dg"] = "deng",
    ["di"] = "di",
    ["dh"] = "dang",
    ["dk"] = "dao",
    ["dj"] = "dan",
    ["dm"] = "dian",
    ["dl"] = "dai",
    ["do"] = "duo",
    ["dq"] = "diu",
    ["dp"] = "dun",
    ["ds"] = "dong",
    ["dr"] = "duan",
    ["du"] = "du",
    ["dv"] = "dui",
    ["dy"] = "ding",
    ["dx"] = "die",
    ["dz"] = "dei",
    ["ga"] = "ga",
    ["gb"] = "gou",
    ["ge"] = "ge",
    ["gd"] = "guang",
    ["gg"] = "geng",
    ["gf"] = "gen",
    ["gh"] = "gang",
    ["gk"] = "gao",
    ["gj"] = "gan",
    ["gl"] = "gai",
    ["go"] = "guo",
    ["gp"] = "gun",
    ["gs"] = "gong",
    ["gr"] = "guan",
    ["gu"] = "gu",
    ["gw"] = "gua",
    ["gv"] = "gui",
    ["gy"] = "guai",
    ["gz"] = "gei",
    ["fa"] = "fa",
    ["fb"] = "fou",
    ["fg"] = "feng",
    ["ff"] = "fen",
    ["fh"] = "fang",
    ["fj"] = "fan",
    ["fo"] = "fo",
    ["fu"] = "fu",
    ["fz"] = "fei",
    ["ia"] = "cha",
    ["ib"] = "chou",
    ["ie"] = "che",
    ["id"] = "chuang",
    ["ig"] = "cheng",
    ["if"] = "chen",
    ["ii"] = "chi",
    ["ih"] = "chang",
    ["ik"] = "chao",
    ["ij"] = "chan",
    ["il"] = "chai",
    ["io"] = "chuo",
    ["ip"] = "chun",
    ["is"] = "chong",
    ["ir"] = "chuan",
    ["iu"] = "chu",
    ["iv"] = "chui",
    ["iy"] = "chuai",
    ["ha"] = "ha",
    ["hb"] = "hou",
    ["he"] = "he",
    ["hd"] = "huang",
    ["hg"] = "heng",
    ["hf"] = "hen",
    ["hh"] = "hang",
    ["hk"] = "hao",
    ["hj"] = "han",
    ["hl"] = "hai",
    ["ho"] = "huo",
    ["hp"] = "hun",
    ["hs"] = "hong",
    ["hr"] = "huan",
    ["hu"] = "hu",
    ["hw"] = "hua",
    ["hv"] = "hui",
    ["hy"] = "huai",
    ["hz"] = "hei",
    ["ka"] = "ka",
    ["kb"] = "kou",
    ["ke"] = "ke",
    ["kd"] = "kuang",
    ["kg"] = "keng",
    ["kf"] = "ken",
    ["kh"] = "kang",
    ["kk"] = "kao",
    ["kj"] = "kan",
    ["kl"] = "kai",
    ["ko"] = "kuo",
    ["kp"] = "kun",
    ["ks"] = "kong",
    ["kr"] = "kuan",
    ["ku"] = "ku",
    ["kw"] = "kua",
    ["kv"] = "kui",
    ["ky"] = "kuai",
    ["jc"] = "jiao",
    ["jd"] = "jiang",
    ["ji"] = "ji",
    ["jm"] = "jian",
    ["jn"] = "jin",
    ["jq"] = "jiu",
    ["jp"] = "jun",
    ["js"] = "jiong",
    ["jr"] = "juan",
    ["ju"] = "ju",
    ["jt"] = "jue",
    ["jw"] = "jia",
    ["jy"] = "jing",
    ["jx"] = "jie",
    ["ma"] = "ma",
    ["mc"] = "miao",
    ["mb"] = "mou",
    ["me"] = "me",
    ["mg"] = "meng",
    ["mf"] = "men",
    ["mi"] = "mi",
    ["mh"] = "mang",
    ["mk"] = "mao",
    ["mj"] = "man",
    ["mm"] = "mian",
    ["ml"] = "mai",
    ["mo"] = "mo",
    ["mn"] = "min",
    ["mq"] = "miu",
    ["mu"] = "mu",
    ["my"] = "ming",
    ["mx"] = "mie",
    ["mz"] = "mei",
    ["la"] = "la",
    ["lc"] = "liao",
    ["lb"] = "lou",
    ["le"] = "le",
    ["ld"] = "liang",
    ["lg"] = "leng",
    ["li"] = "li",
    ["lh"] = "lang",
    ["lk"] = "lao",
    ["lj"] = "lan",
    ["lm"] = "lian",
    ["ll"] = "lai",
    ["lo"] = "luo",
    ["ln"] = "lin",
    ["lq"] = "liu",
    ["lp"] = "lun",
    ["ls"] = "long",
    ["lr"] = "luan",
    ["lu"] = "lu",
    ["lt"] = "lve",
    ["lv"] = "lv",
    ["ly"] = "ling",
    ["lx"] = "lie",
    ["lz"] = "lei",
    ["na"] = "na",
    ["nc"] = "niao",
    ["nb"] = "nou",
    ["ne"] = "ne",
    ["nd"] = "niang",
    ["ng"] = "neng",
    ["nf"] = "nen",
    ["ni"] = "ni",
    ["nh"] = "nang",
    ["nk"] = "nao",
    ["nj"] = "nan",
    ["nm"] = "nian",
    ["nl"] = "nai",
    ["no"] = "nuo",
    ["nn"] = "nin",
    ["nq"] = "niu",
    ["ns"] = "nong",
    ["nr"] = "nuan",
    ["nu"] = "nu",
    ["nt"] = "nve",
    ["nv"] = "nv",
    ["ny"] = "ning",
    ["nx"] = "nie",
    ["nz"] = "nei",
    ["qc"] = "qiao",
    ["qd"] = "qiang",
    ["qi"] = "qi",
    ["qm"] = "qian",
    ["qn"] = "qin",
    ["qq"] = "qiu",
    ["qp"] = "qun",
    ["qs"] = "qiong",
    ["qr"] = "quan",
    ["qu"] = "qu",
    ["qt"] = "que",
    ["qw"] = "qia",
    ["qy"] = "qing",
    ["qx"] = "qie",
    ["pa"] = "pa",
    ["pc"] = "piao",
    ["pb"] = "pou",
    ["pg"] = "peng",
    ["pf"] = "pen",
    ["pi"] = "pi",
    ["ph"] = "pang",
    ["pk"] = "pao",
    ["pj"] = "pan",
    ["pm"] = "pian",
    ["pl"] = "pai",
    ["po"] = "po",
    ["pn"] = "pin",
    ["pu"] = "pu",
    ["py"] = "ping",
    ["px"] = "pie",
    ["pz"] = "pei",
    ["sa"] = "sa",
    ["sb"] = "sou",
    ["se"] = "se",
    ["sg"] = "seng",
    ["sf"] = "sen",
    ["si"] = "si",
    ["sh"] = "sang",
    ["sk"] = "sao",
    ["sj"] = "san",
    ["sl"] = "sai",
    ["so"] = "suo",
    ["sp"] = "sun",
    ["ss"] = "song",
    ["sr"] = "suan",
    ["su"] = "su",
    ["sv"] = "sui",
    ["rb"] = "rou",
    ["re"] = "re",
    ["rg"] = "reng",
    ["rf"] = "ren",
    ["ri"] = "ri",
    ["rh"] = "rang",
    ["rk"] = "rao",
    ["rj"] = "ran",
    ["ro"] = "ruo",
    ["rp"] = "run",
    ["rs"] = "rong",
    ["rr"] = "ruan",
    ["ru"] = "ru",
    ["rv"] = "rui",
    ["ua"] = "sha",
    ["ub"] = "shou",
    ["ue"] = "she",
    ["ud"] = "shuang",
    ["ug"] = "sheng",
    ["uf"] = "shen",
    ["ui"] = "shi",
    ["uh"] = "shang",
    ["uk"] = "shao",
    ["uj"] = "shan",
    ["ul"] = "shai",
    ["uo"] = "shuo",
    ["up"] = "shun",
    ["ur"] = "shuan",
    ["uu"] = "shu",
    ["uw"] = "shua",
    ["uv"] = "shui",
    ["uy"] = "shuai",
    ["uz"] = "shei",
    ["ta"] = "ta",
    ["tc"] = "tiao",
    ["tb"] = "tou",
    ["te"] = "te",
    ["tg"] = "teng",
    ["ti"] = "ti",
    ["th"] = "tang",
    ["tk"] = "tao",
    ["tj"] = "tan",
    ["tm"] = "tian",
    ["tl"] = "tai",
    ["to"] = "tuo",
    ["tp"] = "tun",
    ["ts"] = "tong",
    ["tr"] = "tuan",
    ["tu"] = "tu",
    ["tv"] = "tui",
    ["ty"] = "ting",
    ["tx"] = "tie",
    ["wa"] = "wa",
    ["wg"] = "weng",
    ["wf"] = "wen",
    ["wh"] = "wang",
    ["wj"] = "wan",
    ["wl"] = "wai",
    ["wo"] = "wo",
    ["wu"] = "wu",
    ["wz"] = "wei",
    ["va"] = "zha",
    ["vb"] = "zhou",
    ["ve"] = "zhe",
    ["vd"] = "zhuang",
    ["vg"] = "zheng",
    ["vf"] = "zhen",
    ["vi"] = "zhi",
    ["vh"] = "zhang",
    ["vk"] = "zhao",
    ["vj"] = "zhan",
    ["vl"] = "zhai",
    ["vo"] = "zhuo",
    ["vp"] = "zhun",
    ["vs"] = "zhong",
    ["vr"] = "zhuan",
    ["vu"] = "zhu",
    ["vw"] = "zhua",
    ["vv"] = "zhui",
    ["vy"] = "zhuai",
    ["ya"] = "ya",
    ["yb"] = "you",
    ["ye"] = "ye",
    ["yi"] = "yi",
    ["yh"] = "yang",
    ["yk"] = "yao",
    ["yj"] = "yan",
    ["yl"] = "yai",
    ["yo"] = "yo",
    ["yn"] = "yin",
    ["yp"] = "yun",
    ["ys"] = "yong",
    ["yr"] = "yuan",
    ["yu"] = "yu",
    ["yt"] = "yue",
    ["yy"] = "ying",
    ["xc"] = "xiao",
    ["xd"] = "xiang",
    ["xi"] = "xi",
    ["xm"] = "xian",
    ["xn"] = "xin",
    ["xq"] = "xiu",
    ["xp"] = "xun",
    ["xs"] = "xiong",
    ["xr"] = "xuan",
    ["xu"] = "xu",
    ["xt"] = "xue",
    ["xw"] = "xia",
    ["xy"] = "xing",
    ["xx"] = "xie",
    ["za"] = "za",
    ["zb"] = "zou",
    ["ze"] = "ze",
    ["zg"] = "zeng",
    ["zf"] = "zen",
    ["zi"] = "zi",
    ["zh"] = "zang",
    ["zk"] = "zao",
    ["zj"] = "zan",
    ["zl"] = "zai",
    ["zo"] = "zuo",
    ["zp"] = "zun",
    ["zs"] = "zong",
    ["zr"] = "zuan",
    ["zu"] = "zu",
    ["zv"] = "zui",
    ["zz"] = "zei",
    ["aa"] = "a",
    ["ai"] = "ai",
    ["an"] = "an",
    ["ah"] = "ang",
    ["ao"] = "ao",
    ["ee"] = "e",
    ["ei"] = "ei",
    ["en"] = "en",
    ["er"] = "er",
    ["oo"] = "o",
    ["ou"] = "ou",
    ["v"] = "zh",
    ["i"] = "ch",
    ["u"] = "sh"
}

local function translator(input, seg, env)
    local input2 = ""
    local dictstr = ""
    for i = 1, #input, 2 do
        local w = input:sub(i, i + 1)
        local w2 = code[w]
        if w2 then
            input2 = input2 .. w2
            dictstr = dictstr .. w2 .. " "
        else
            input2 = input2 .. w
            dictstr = dictstr .. w .. " "
        end
    end
    local f = assert(io.popen("cloudinput " .. input2, "r"))
    local s = assert(f:read("*a"))
    f:close()
    local _, j = pcall(json.decode, s)
    if j and j.status == "T" and j.result and j.result[1] then
        for _, v in ipairs(j.result[1]) do
            local c = Candidate("phrase", seg.start, seg.start + v[2], v[1], dictstr)
            c.quality = 2
            if string.gsub(v[3].pinyin, "'", "") == string.sub(input, 1, v[2]) then
                c.preedit = string.gsub(v[3].pinyin, "'", " ")
            end
            yield(c)
        end
    end
end

return translator
