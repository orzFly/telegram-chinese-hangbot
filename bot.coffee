_ = require 'lodash'
fs = require 'fs'
Telegram = require 'telegram-bot'
Redis = require 'ioredis'
Promise = require 'bluebird'

redis = new Redis keyPrefix: "ChineseHangBot:"
tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)

dict = do ->
  _(fs.readFileSync("dict.txt").toString("utf-8").split("\n")).compact().map (i) ->
    d = i.split(" ")
    [d[0], d.slice(1)]
  .object().value()

pinyinMap = { "a": ["a"], "ai": ["ai"], "an": ["an"], "ang": ["ang"], "ao": ["ao"], "ba": ["b", "a"], "bai": ["b", "ai"], "ban": ["b", "an"], "bang": ["b", "ang"], "bao": ["b", "ao"], "bei": ["b", "ei"], "ben": ["b", "en"], "beng": ["b", "eng"], "bi": ["b", "i"], "bian": ["b", "i", "an"], "biao": ["b", "i", "ao"], "bie": ["b", "i", "e"], "bin": ["b", "i", "en"], "bing": ["b", "i", "eng"], "bo": ["b", "o"], "bu": ["b", "u"], "ca": ["c", "a"], "cai": ["c", "ai"], "can": ["c", "an"], "cang": ["c", "ang"], "cao": ["c", "ao"], "ce": ["c", "e"], "cen": ["c", "en"], "ceng": ["c", "eng"], "cha": ["ch", "a"], "chai": ["ch", "ai"], "chan": ["ch", "an"], "chang": ["ch", "ang"], "chao": ["ch", "ao"], "che": ["ch", "e"], "chen": ["ch", "en"], "cheng": ["ch", "eng"], "chi": ["ch", "i"], "chong": ["ch", "ong"], "chou": ["ch", "ou"], "chu": ["ch", "u"], "chua": ["ch", "u", "a"], "chuai": ["ch", "u", "ai"], "chuan": ["ch", "u", "an"], "chuang": ["ch", "u", "ang"], "chui": ["ch", "u", "i"], "chun": ["ch", "u", "en"], "chuo": ["ch", "u", "o"], "ci": ["c", "i"], "cong": ["c", "ong"], "cou": ["c", "ou"], "cu": ["c", "u"], "cuan": ["c", "u", "an"], "cui": ["c", "u", "i"], "cun": ["c", "u", "en"], "cuo": ["c", "u", "o"], "da": ["d", "a"], "dai": ["d", "ai"], "dan": ["d", "an"], "dang": ["d", "ang"], "dao": ["d", "ao"], "de": ["d", "e"], "dei": ["d", "ei"], "den": ["d", "en"], "deng": ["d", "eng"], "di": ["d", "i"], "dia": ["d", "i", "a"], "dian": ["d", "i", "an"], "diao": ["d", "i", "ao"], "die": ["d", "i", "e"], "ding": ["d", "i", "eng"], "diu": ["d", "i", "u"], "dong": ["d", "ong"], "dou": ["d", "ou"], "du": ["d", "u"], "duan": ["d", "u", "an"], "dui": ["d", "u", "i"], "dun": ["d", "u", "en"], "duo": ["d", "u", "o"], "e": ["e"], "ei": ["ei"], "en": ["en"], "eng": ["eng"], "er": ["er"], "fa": ["f", "a"], "fan": ["f", "an"], "fang": ["f", "ang"], "fei": ["f", "ei"], "fen": ["f", "en"], "feng": ["f", "eng"], "fo": ["f", "o"], "fou": ["f", "ou"], "fu": ["f", "u"], "ga": ["g", "a"], "gai": ["g", "ai"], "gan": ["g", "an"], "gang": ["g", "ang"], "gao": ["g", "ao"], "ge": ["g", "e"], "gei": ["g", "ei"], "gen": ["g", "en"], "geng": ["g", "eng"], "gong": ["g", "ong"], "gou": ["g", "ou"], "gu": ["g", "u"], "gua": ["g", "u", "a"], "guai": ["g", "u", "ai"], "guan": ["g", "u", "an"], "guang": ["g", "u", "ang"], "gui": ["g", "u", "i"], "gun": ["g", "u", "en"], "guo": ["g", "u", "o"], "ha": ["h", "a"], "hai": ["h", "ai"], "han": ["h", "an"], "hang": ["h", "ang"], "hao": ["h", "ao"], "he": ["h", "e"], "hei": ["h", "ei"], "hen": ["h", "en"], "heng": ["h", "eng"], "hong": ["h", "ong"], "hou": ["h", "ou"], "hu": ["h", "u"], "hua": ["h", "u", "a"], "huai": ["h", "u", "ai"], "huan": ["h", "u", "an"], "huang": ["h", "u", "ang"], "hui": ["h", "u", "i"], "hun": ["h", "u", "en"], "huo": ["h", "u", "o"], "ji": ["j", "i"], "jia": ["j", "i", "a"], "jian": ["j", "i", "an"], "jiang": ["j", "i", "ang"], "jiao": ["j", "i", "ao"], "jie": ["j", "i", "e"], "jin": ["j", "i", "en"], "jing": ["j", "i", "eng"], "jiong": ["j", "i", "ong"], "jiu": ["j", "i", "u"], "ju": ["j", "u"], "juan": ["j", "u", "an"], "jue": ["j", "u", "e"], "jun": ["j", "u", "en"], "ka": ["k", "a"], "kai": ["k", "ai"], "kan": ["k", "an"], "kang": ["k", "ang"], "kao": ["k", "ao"], "ke": ["k", "e"], "ken": ["k", "en"], "keng": ["k", "eng"], "kong": ["k", "ong"], "kou": ["k", "ou"], "ku": ["k", "u"], "kua": ["k", "u", "a"], "kuai": ["k", "u", "ai"], "kuan": ["k", "u", "an"], "kuang": ["k", "u", "ang"], "kui": ["k", "u", "i"], "kun": ["k", "u", "en"], "kuo": ["k", "u", "o"], "la": ["l", "a"], "lai": ["l", "ai"], "lan": ["l", "an"], "lang": ["l", "ang"], "lao": ["l", "ao"], "le": ["l", "e"], "lei": ["l", "ei"], "leng": ["l", "eng"], "li": ["l", "i"], "lia": ["l", "i", "a"], "lian": ["l", "i", "an"], "liang": ["l", "i", "ang"], "liao": ["l", "i", "ao"], "lie": ["l", "i", "e"], "lin": ["l", "i", "en"], "ling": ["l", "i", "eng"], "liu": ["l", "i", "u"], "long": ["l", "ong"], "lou": ["l", "ou"], "lu": ["l", "u"], "l": ["ü", "l", "ü"], "luan": ["l", "u", "an"], "lue": ["l", "u", "e"], "l": ["üe", "l", "ü", "e"], "lun": ["l", "u", "en"], "luo": ["l", "u", "o"], "m": ["m"], "ma": ["m", "a"], "mai": ["m", "ai"], "man": ["m", "an"], "mang": ["m", "ang"], "mao": ["m", "ao"], "me": ["m", "e"], "mei": ["m", "ei"], "men": ["m", "en"], "meng": ["m", "eng"], "mi": ["m", "i"], "mian": ["m", "i", "an"], "miao": ["m", "i", "ao"], "mie": ["m", "i", "e"], "min": ["m", "i", "en"], "ming": ["m", "i", "eng"], "miu": ["m", "i", "u"], "mo": ["m", "o"], "mou": ["m", "ou"], "mu": ["m", "u"], "na": ["n", "a"], "nai": ["n", "ai"], "nan": ["n", "an"], "nang": ["n", "ang"], "nao": ["n", "ao"], "ne": ["n", "e"], "nei": ["n", "ei"], "nen": ["n", "en"], "neng": ["n", "eng"], "ng": ["ng"], "ni": ["n", "i"], "nian": ["n", "i", "an"], "niang": ["n", "i", "ang"], "niao": ["n", "i", "ao"], "nie": ["n", "i", "e"], "nin": ["n", "i", "en"], "ning": ["n", "i", "eng"], "niu": ["n", "i", "u"], "nong": ["n", "ong"], "nou": ["n", "ou"], "nu": ["n", "u"], "n": ["ü", "n", "ü"], "nuan": ["n", "u", "an"], "n": ["üe", "n", "ü", "e"], "nun": ["n", "u", "en"], "nuo": ["n", "u", "o"], "o": ["o"], "ou": ["ou"], "pa": ["p", "a"], "pai": ["p", "ai"], "pan": ["p", "an"], "pang": ["p", "ang"], "pao": ["p", "ao"], "pei": ["p", "ei"], "pen": ["p", "en"], "peng": ["p", "eng"], "pi": ["p", "i"], "pian": ["p", "i", "an"], "piao": ["p", "i", "ao"], "pie": ["p", "i", "e"], "pin": ["p", "i", "en"], "ping": ["p", "i", "eng"], "po": ["p", "o"], "pou": ["p", "ou"], "pu": ["p", "u"], "qi": ["q", "i"], "qia": ["q", "i", "a"], "qian": ["q", "i", "an"], "qiang": ["q", "i", "ang"], "qiao": ["q", "i", "ao"], "qie": ["q", "i", "e"], "qin": ["q", "i", "en"], "qing": ["q", "i", "eng"], "qiong": ["q", "i", "ong"], "qiu": ["q", "i", "u"], "qu": ["q", "u"], "quan": ["q", "u", "an"], "que": ["q", "u", "e"], "qun": ["q", "u", "en"], "ran": ["r", "an"], "rang": ["r", "ang"], "rao": ["r", "ao"], "re": ["r", "e"], "ren": ["r", "en"], "reng": ["r", "eng"], "ri": ["r", "i"], "rong": ["r", "ong"], "rou": ["r", "ou"], "ru": ["r", "u"], "ruan": ["r", "u", "an"], "rui": ["r", "u", "i"], "run": ["r", "u", "en"], "ruo": ["r", "u", "o"], "sa": ["s", "a"], "sai": ["s", "ai"], "san": ["s", "an"], "sang": ["s", "ang"], "sao": ["s", "ao"], "se": ["s", "e"], "sen": ["s", "en"], "seng": ["s", "eng"], "sha": ["sh", "a"], "shai": ["sh", "ai"], "shan": ["sh", "an"], "shang": ["sh", "ang"], "shao": ["sh", "ao"], "she": ["sh", "e"], "shei": ["sh", "ei"], "shen": ["sh", "en"], "sheng": ["sh", "eng"], "shi": ["sh", "i"], "shou": ["sh", "ou"], "shu": ["sh", "u"], "shua": ["sh", "u", "a"], "shuai": ["sh", "u", "ai"], "shuan": ["sh", "u", "an"], "shuang": ["sh", "u", "ang"], "shui": ["sh", "u", "i"], "shun": ["sh", "u", "en"], "shuo": ["sh", "u", "o"], "si": ["s", "i"], "song": ["s", "ong"], "sou": ["s", "ou"], "su": ["s", "u"], "suan": ["s", "u", "an"], "sui": ["s", "u", "i"], "sun": ["s", "u", "en"], "suo": ["s", "u", "o"], "ta": ["t", "a"], "tai": ["t", "ai"], "tan": ["t", "an"], "tang": ["t", "ang"], "tao": ["t", "ao"], "te": ["t", "e"], "teng": ["t", "eng"], "ti": ["t", "i"], "tian": ["t", "i", "an"], "tiao": ["t", "i", "ao"], "tie": ["t", "i", "e"], "ting": ["t", "i", "eng"], "tong": ["t", "ong"], "tou": ["t", "ou"], "tu": ["t", "u"], "tuan": ["t", "u", "an"], "tui": ["t", "u", "i"], "tun": ["t", "u", "en"], "tuo": ["t", "u", "o"], "wa": ["u", "a"], "wai": ["u", "ai"], "wan": ["u", "an"], "wang": ["u", "ang"], "wei": ["u", "i"], "wen": ["u", "en"], "weng": ["u", "eng"], "wo": ["u", "o"], "wu": ["u"], "xi": ["x", "i"], "xia": ["x", "i", "a"], "xian": ["x", "i", "an"], "xiang": ["x", "i", "ang"], "xiao": ["x", "i", "ao"], "xie": ["x", "i", "e"], "xin": ["x", "i", "en"], "xing": ["x", "i", "eng"], "xiong": ["x", "i", "ong"], "xiu": ["x", "i", "u"], "xu": ["x", "ü"], "xuan": ["x", "ü", "an"], "xue": ["x", "ü", "e"], "xun": ["x", "ü", "en"], "ya": ["i", "a"], "yan": ["i", "an"], "yang": ["i", "ang"], "yao": ["i", "ao"], "ye": ["i", "e"], "yi": ["i"], "yin": ["i", "en"], "ying": ["i", "eng"], "yo": ["i", "o"], "yong": ["i", "ong"], "you": ["i", "ou"], "yu": ["ü"], "yuan": ["ü", "an"], "yue": ["ü", "e"], "yun": ["ü", "en"], "za": ["z", "a"], "zai": ["z", "ai"], "zan": ["z", "an"], "zang": ["z", "ang"], "zao": ["z", "ao"], "ze": ["z", "e"], "zei": ["z", "ei"], "zen": ["z", "en"], "zeng": ["z", "eng"], "zha": ["zh", "a"], "zhai": ["zh", "ai"], "zhan": ["zh", "an"], "zhang": ["zh", "ang"], "zhao": ["zh", "ao"], "zhe": ["zh", "e"], "zhei": ["zh", "ei"], "zhen": ["zh", "en"], "zheng": ["zh", "eng"], "zhi": ["zh", "i"], "zhong": ["zh", "ong"], "zhou": ["zh", "ou"], "zhu": ["zh", "u"], "zhua": ["zh", "u", "a"], "zhuai": ["zh", "u", "ai"], "zhuan": ["zh", "u", "an"], "zhuang": ["zh", "u", "ang"], "zhui": ["zh", "u", "i"], "zhun": ["zh", "u", "en"], "zhuo": ["zh", "u", "o"], "zi": ["z", "i"], "zong": ["z", "ong"], "zou": ["z", "ou"], "zu": ["z", "u"], "zuan": ["z", "u", "an"], "zui": ["z", "u", "i"], "zun": ["z", "u", "en"], "zuo": ["z", "u", "o"]}
keyboard = ["a", "ai", "an", "ang", "ao", "e", "ei", "en", "eng", "er", "i", "o", "ong", "ou", "u", "ü", "b", "c", "ch", "d", "f", "g", "h", "j", "k", "l", "m", "n", "ng", "p", "q", "r", "s", "sh", "t", "x", "z", "zh"]
map =
  help: (msg) ->
    msg.reply
      text: """
        /start - 开始游戏
        /stop - 结束游戏
        /help - 关于
      """

  stop: (msg) ->
    if sessions[msg.chat.id]
      delete sessions[msg.chat.id]
      msg.reply
        text: "停掉了╮(╯▽╰)╭"
    else
      msg.reply
        text: "根本还没开始呢啊(╯‵□′)╯︵┻━┻"

  start: (msg) ->
    word = _(dict).keys().sample()
    pinyin = dict[word]
    parts = _.map(pinyin, (i) -> pinyinMap[i])
    flatParts = _.flatten(parts)

    game =
      word: word
      pinyin: pinyin
      parts: parts
      keyboard: keyboard

    kbd = _.range(keyboard.length).map (i) -> 0

    sessionKey = "game:#{msg.chat.id.toString()}"
    
    redis.multi()
      .set(sessionKey, JSON.stringify game)
      .lpush(sessionKey + ":kbd", kbd)
      .ltrim(sessionKey + ":kbd", 0, kbd.length - 1)
    .exec().then ->
      printStatus msg, game, kbd

printStatus = (msg, game, kbd) ->
  text = "音节："

  text += game.parts.map (part) ->
    part.map (i) ->
      if parseInt(kbd[game.keyboard.indexOf(i)], 10) > 0 then i else "➖"
    .join ("")
  .join("")

  text += "\n"

  text += "汉字："
  text += game.parts.map (part, index) ->
    if _.all(part, (i) -> parseInt(kbd[game.keyboard.indexOf(i)], 10) > 0)
      game.word[index]
    else "➖"
  .join("")

  markup = _.select game.keyboard, (key, index) -> parseInt(kbd[index], 10) == 0
  markup = _.chunk markup, Math.ceil(markup.length / 3)

  msg.reply
    text: text
    reply_markup:
      keyboard: markup
      resize_keyboard: false
      one_time_keyboard: false
      selective: false

readSession = (msg) ->
  sessionKey = "game:#{msg.chat.id.toString()}"

  game = kbd = null
  redis.get(sessionKey).then (value) ->
    return unless _.isString(value)
    
    game = JSON.parse value
    redis.lrange(sessionKey + ":kbd", 0, -1).then (value) ->
      kbd = value
    .then ->
      {game, kbd}

tg.on 'message', (msg) ->
  console.log "#{msg.date} #{msg.from.username || msg.from.first_name}: #{msg.text}"
  text = String(msg.text).trim()
  msg.reply = (options) ->
    tg.sendMessage _.defaults options,
      reply_to_message_id: @message_id
      chat_id: @chat.id

  cmd = String(text.match(/^\/([a-zA-Z0-9]*)(@coxxsbot)?/i)?[1]).toLowerCase()
  return map[cmd](msg) if cmd && map[cmd]

  readSession(msg).then (x) ->
    return unless x
    {game, kbd} = x

    Promise.resolve()
    .then ->
      index = game.keyboard.indexOf(text)
      if index >= 0
        kbd[index] = 1
        redis.lset("game:#{msg.chat.id.toString()}:kbd", index, 1)
    .then ->
      printStatus msg, game, kbd


tg.start()
