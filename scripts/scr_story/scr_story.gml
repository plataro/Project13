global.story_seen = {};
global.ending = "kill";    // "kill" หรือ "join" (ตั้งตอนเลือกในห้องบอส)
global.choice = "";
global.arrive = "";        // ชื่อประตูที่ผู้เล่นต้องไปเกิดในห้องถัดไป ("" = จุดเริ่มห้อง)        // ค่าที่ผู้เล่นเลือกในบทสนทนาล่าสุด

// ข้อมูลตัวละครสำหรับรูปในบทสนทนา
// emotions: ตั้งชื่ออารมณ์เองได้ ตัวเลขคือลำดับเฟรมใน sprite (เริ่มที่ 0)
function portrait_data() {
    return {
        a: {
            sprite: spr_portrait_a,
            mirror_on_right: true,
            emotions: { normal: 0, happy: 1, sad: 2, angry: 3, surprised: 4 }
        },
        b: {
            sprite: spr_portrait_b,
            mirror_on_right: true,
            emotions: { normal: 0, happy: 1, sad: 2 }
        }
    };
}

function story_lines(_key) {
    // ผู้เล่น = L("ผู้ไร้นาม", "The Nameless")  ราชามังกร = who "b"  (เปลี่ยน who/emo ตามรูป portrait ที่มี)
    var _me = L("ผู้ไร้นาม", "The Nameless");
    var _dr = L("ราชามังกร", "The Dragon King");
    switch (_key) {
        // ---------- Sanctuary: ตื่นขึ้นมา ----------
        case "intro":
            return [
                { name: _me, text: L("...หนาวจัง", "...So cold.") },
                { name: _me, text: L("ที่นี่ที่ไหนกัน? ฉัน... จำอะไรไม่ได้เลย แม้แต่ชื่อของตัวเอง", "Where is this place? I... can't remember anything. Not even my own name.") },
                { name: _me, text: L("แต่มีเสียงบางอย่างเรียกอยู่ข้างนอกนั่น เหมือนมีบางอย่างที่ฉันต้องไปให้ถึง", "But something is calling to me from outside. Like there's somewhere I have to reach.") },
                { name: _me, text: L("ลองเดินออกไปดูก็แล้วกัน... ถ้าเจอทางออกนะ", "I'll head out and see... if I can find the way.") },
            ];
        case "sword_found":
            return [
                { name: _me, text: L("ดาบเล่มนี้... ทำไมมันถึงคุ้นมือขนาดนี้", "This sword... why does it feel so familiar in my hand?") },
                { name: _me, text: L("เหมือนมันรอฉันมานานแล้ว", "As if it's been waiting for me for a long time.") },
                { name: _me, text: L("ไปกันเถอะ", "Let's go.") },
            ];

        // ---------- ป่า ----------
        case "level1_mid":
            return [
                { name: _me, text: L("รอยไหม้บนพื้น... และต้นไม้ที่ล้มระเนระนาด", "Scorch marks on the ground... and trees torn down everywhere.") },
                { name: _me, text: L("นี่มันฝีมือของสัตว์ประหลาดพวกนี้... หรือของ 'มังกร' ที่ชาวบ้านพูดถึงกันนะ", "Did these monsters do this... or the 'dragon' the villagers talk about?") },
            ];

        // ---------- หมู่บ้าน ----------
        case "village_intro":
            return [
                { name: L("ชาวบ้าน", "Villager"), text: L("นั่น... นักรบเหรอ? รอดมาจากป่านั่นได้ยังไงกัน", "Is that... a warrior? How did you make it out of that forest alive?") },
                { name: L("ชาวบ้าน", "Villager"), text: L("ราชามังกรกลับมาแล้ว ท้องฟ้าเหนือปราสาทกลายเป็นสีเลือดมาหลายคืน", "The Dragon King has returned. The sky over the castle has been blood-red for many nights.") },
                { name: L("ชาวบ้าน", "Villager"), text: L("ประตูปราสาทถูกผนึกไว้ ต้องไปเอาตราจากเหมืองร้างทางตะวันออกก่อนถึงจะเข้าไปได้", "The castle gate is sealed. You'll need the crest from the abandoned mine to the east to get in.") },
                { name: _me, text: L("(ลองคุยกับพ่อค้าดูหน่อย... ของที่ซื้อได้อาจช่วยชีวิตฉันไว้)", "(Maybe I should talk to the merchants... what they sell might save my life.)") },
            ];

        // ---------- เหมือง ----------
        case "mine_intro":
            return [
                { name: _me, text: L("เหมืองร้าง... เงียบจนน่าขนลุก", "The abandoned mine... it's eerily quiet.") },
                { name: _me, text: L("บนผนังมีรอยกรงเล็บขนาดใหญ่ ใหญ่เกินกว่าสัตว์ธรรมดาจะทำได้", "Huge claw marks on the walls. Far too big for any ordinary beast.") },
            ];

        // ---------- ปราสาท ----------
        case "castle_intro":
            return [
                { name: _me, text: L("นี่คือปราสาทของราชามังกร... แต่ทำไมฉันรู้สึกเหมือนเคยมาที่นี่", "So this is the Dragon King's castle... but why do I feel like I've been here before?") },
                { name: _me, text: L("ความทรงจำบางอย่างกำลังย้อนกลับมา... ทีละนิด", "Some memories are coming back... little by little.") },
            ];

        // ---------- ห้องโถงสุดท้าย (side-scroll) ----------
        case "hall_1":
            return [
                { name: L("ผู้บรรยาย", "Narrator"), text: L("บนผนังมีภาพสลักเก่าแก่ นักรบถือดาบยืนเคียงข้างมังกรตัวใหญ่ ทั้งคู่ชูมือขึ้นสู่ท้องฟ้า", "An ancient carving covers the wall: a warrior with a sword stands beside a great dragon, both reaching toward the sky.") },
                { name: _me, text: L("เคียงข้างกัน...? มนุษย์กับมังกรเนี่ยนะ", "Side by side...? A human and a dragon?") },
            ];
        case "hall_2":
            return [
                { name: L("ผู้บรรยาย", "Narrator"), text: L("ภาพถัดมา นักรบหลับใหลอยู่ในวิหาร และมังกรตัวนั้นกำลังปิดผนึก... ด้วยน้ำตา", "The next carving: the warrior sleeps in a sanctuary, and the dragon seals it shut... in tears.") },
                { name: _me, text: L("วิหารนั่น... คือที่ที่ฉันตื่นขึ้นมา", "That sanctuary... it's where I woke up.") },
                { name: _me, text: L("แล้วคนที่ผนึกฉันไว้ก็คือ... ราชามังกรเอง?", "Then the one who sealed me away was... the Dragon King himself?") },
            ];
        case "hall_end":
            return [
                { name: _me, text: L("ประตูบานสุดท้าย", "The last door.") },
                { name: _me, text: L("ไม่ว่าเบื้องหลังจะมีอะไรอยู่ ฉันต้องรู้ความจริง", "Whatever lies beyond it, I have to know the truth.") },
            ];

        // ---------- ห้องบอส: มีตัวเลือก ----------
        case "boss_intro":
            return [
                { name: _dr, who: "b", side: "right", emo: "normal", text: L("ในที่สุดเจ้าก็มาถึง... สหายของข้า", "At last you have come... my old friend.") },
                { name: _me, who: "a", side: "left", emo: "surprised", text: L("นายรู้จักฉันงั้นเหรอ", "You know me?") },
                { name: _dr, who: "b", side: "right", emo: "sad", text: L("ข้าเองที่ผนึกเจ้าไว้ในวิหาร เพื่อให้เจ้าพ้นจากสงครามที่ข้าไม่อาจหยุดได้", "It was I who sealed you in the sanctuary, to spare you from a war I could not stop.") },
                { name: _dr, who: "b", side: "right", emo: "sad", text: L("เราเคยสร้างสันติสุขร่วมกัน ก่อนที่ไฟแห่งความแค้นจะกลืนสติของข้าไป", "Together we once built a lasting peace, before the fire of vengeance consumed my mind.") },
                { name: _dr, who: "b", side: "right", emo: "normal", text: L("ข้าเหลือสติอยู่อีกไม่นาน ถ้าเจ้าไม่หยุดข้า ข้าจะเผาโลกนี้ทั้งใบ... หรือไม่ก็ยืนเคียงข้างข้า แล้วเราจะสร้างโลกใหม่ด้วยกันอีกครั้ง", "My reason will not hold much longer. If you do not stop me, I will burn this world to ash... or stand beside me, and we will build a new world together once more.") },
                { name: _me, who: "a", side: "left", emo: "normal", text: L("ฉัน...", "I..."), choices: [
                    { t: L("ฉันจะหยุดนายเอง", "I'll stop you myself."), v: "kill" },
                    { t: L("ฉันจะอยู่เคียงข้างนาย", "I'll stand beside you."), v: "join" }
                ] },
            ];
        case "boss_kill":
            return [
                { name: _me, who: "a", side: "left", emo: "sad", text: L("ขอโทษนะ... แต่ฉันต้องทำ", "I'm sorry... but I have to.") },
                { name: _dr, who: "b", side: "right", emo: "happy", text: L("นั่นล่ะ... คำตอบที่ข้ารอคอย มาเถอะ!", "That is... the answer I have waited for. Come!") },
            ];

        // ---------- ตอนจบ ----------
        case "ending_kill":
            return [
                { name: _dr, who: "b", side: "right", emo: "happy", text: L("ขอบใจ... สหายของข้า ไฟแค้นกำลังดับลงแล้ว", "Thank you... my friend. The fire of vengeance is fading at last.") },
                { name: _me, who: "a", side: "left", emo: "sad", text: L("หลับให้สบายเถอะ... ฉันจะจำนายไว้", "Rest now... I'll remember you.") },
            ];
        case "ending_join":
            return [
                { name: _dr, who: "b", side: "right", emo: "happy", text: L("ขอบใจ... สหายของข้า ด้วยกัน เราจะไม่แพ้ใครอีก", "Thank you... my friend. Together, we will never fall again.") },
                { name: _me, who: "a", side: "left", emo: "happy", text: L("คราวนี้ ฉันจะไม่ลืมนายอีกแล้ว", "This time, I won't forget you.") },
            ];
        case "ending":
            return [];
    }
    return [];
}

// สไลด์ภาพประกอบ: img = ชื่อ sprite (ใส่ภาพชื่อนี้ในโปรเจกต์เมื่อวาดเสร็จ ถ้ายังไม่มีจะขึ้นภาพ placeholder)
function cutscene_slides(_key) {
    switch (_key) {
        case "intro":
            return [
                { img: "spr_cs_intro_1", text: L("นานมาแล้ว มังกรและมนุษย์เคยอยู่ร่วมกันภายใต้ท้องฟ้าเดียวกัน", "Long ago, dragons and humans lived together beneath the same sky.") },
                { img: "spr_cs_intro_2", text: L("จนวันหนึ่ง ไฟแห่งสงครามลุกลามไปทั่วแผ่นดิน ราชามังกรผู้ยิ่งใหญ่หายไปในเปลวเพลิง", "Until one day, the fires of war spread across the land, and the great Dragon King vanished into the flames.") },
                { img: "spr_cs_intro_3", text: L("ผู้คนเล่าขานว่า นักรบนิรนามคนหนึ่งถูกผนึกไว้ในวิหารเก่าแก่ เพื่อรอวันที่โลกต้องการเขาอีกครั้ง", "Legend tells of a nameless warrior sealed within an ancient sanctuary, waiting for the day the world would need him again.") },
                { img: "spr_cs_intro_4", text: L("และบัดนี้ ราชามังกรกลับมาแล้ว ท้องฟ้าเหนือปราสาทกลายเป็นสีเลือด", "And now, the Dragon King has returned. The sky above his castle has turned the color of blood.") },
                { img: "spr_cs_intro_5", text: L("ในความเงียบของวิหาร... บางสิ่งกำลังตื่นขึ้น", "In the silence of the sanctuary... something stirs.") },
            ];
        case "end_kill":
            return [
                { img: "spr_cs_kill_1", text: L("ร่างของราชามังกรสลายเป็นแสงสีทอง ไฟที่ลุกทั่วแผ่นดินค่อย ๆ มอดดับลง", "The Dragon King's body dissolved into golden light, and the fires across the land slowly died away.") },
                { img: "spr_cs_kill_2", text: L("ท้องฟ้ากลับเป็นสีคราม ชาวบ้านโห่ร้องเรียกขานผู้กล้า ทั้งที่ไม่มีใครรู้ชื่อจริงของเขา", "The sky turned blue once more. The people cheered for their hero, though no one knew his true name.") },
                { img: "spr_cs_kill_3", text: L("ผู้ไร้นามเก็บเกล็ดมังกรชิ้นสุดท้ายไว้ แล้วออกเดินทางต่อ เพื่อตามหาตัวตนที่เลือนหายไป", "The Nameless kept the dragon's last scale and set out again, searching for the self he had lost.") },
                { img: "spr_cs_kill_4", text: L("ตอนจบที่ 1 : ผู้พิชิตมังกร", "Ending 1 : The Dragonslayer") },
            ];
        case "end_join":
            return [
                { img: "spr_cs_join_1", text: L("ผู้ไร้นามชูดาบขึ้น ไม่ใช่เพื่อฟาดฟัน แต่เพื่อประสานกับเปลวไฟของมังกร", "The Nameless raised his sword, not to strike, but to join it with the dragon's flame.") },
                { img: "spr_cs_join_2", text: L("ไฟแห่งความแค้นถูกแบ่งเป็นสอง และอ่อนแรงลง ราชามังกรได้สติกลับคืนมา", "The fire of vengeance, split in two, grew weak, and the Dragon King came back to his senses.") },
                { img: "spr_cs_join_3", text: L("ผู้คนหวาดกลัว และไม่ใช่ทุกคนที่ยอมรับ แต่ทั้งสองเริ่มสร้างโลกใหม่ ที่มนุษย์และมังกรอยู่ร่วมกัน", "People were afraid, and not everyone accepted it. But together the two began building a new world where humans and dragons live side by side.") },
                { img: "spr_cs_join_4", text: L("ตอนจบที่ 2 : เคียงข้างราชา", "Ending 2 : Beside the King") },
            ];
    }
    return [];
}

// ฟังก์ชันที่ถูกเรียกหลังบทสนทนาจบ
function story_done(_key) {
    switch (_key) {
        case "boss_intro": return boss_intro_done;
    }
    return undefined;
}

function boss_intro_done() {
    if (global.choice == "join") {
        global.ending = "join";
        if (!instance_exists(obj_fade)) {
            var _f = instance_create_depth(0, 0, -10000, obj_fade);
            _f.target_room = rm_end;
        }
    } else {
        global.ending = "kill";
        dialogue_start(story_lines("boss_kill"));
    }
}

// ตอนจบ: บทสนทนา -> สไลด์ -> หน้าจบ
function ending_after_dialogue() {
    cutscene_start("end_" + global.ending, ending_after_slides);
}
function ending_after_slides() {
    with (obj_ending) shown_end = true;
}

function cutscene_start(_key, _on_done = undefined) {
    if (instance_exists(obj_cutscene)) return;
    var _c = instance_create_depth(0, 0, -16000, obj_cutscene);
    _c.slides = cutscene_slides(_key);
    _c.on_done = _on_done;
    if (array_length(_c.slides) == 0) instance_destroy(_c);
}

// ป้ายสอนปุ่มในฉาก (วาดในพิกัดโลก ลอยอยู่เหนือพื้น ไม่ติดหน้าจอ)
// _items = [ { k: ["W","A","S","D"], t: "เดิน" }, ... ]
function draw_key_hint(_x, _y, _items, _alpha, _t, _tick = false) {
    if (_alpha < 0.02) return;
    draw_set_font(fnt_dialog);
    var _s = 0.62;
    var _n = array_length(_items);
    var _rowh = 34;
    var _pad = 12;
    var _wmax = 0;
    // ★ ชื่อปุ่มตามอุปกรณ์ที่ใช้อยู่ (คีย์บอร์ด/จอย/ปุ่มที่ตั้งเอง)
    var _labels = [];
    for (var _li = 0; _li < _n; _li++) {
        var _kk = _items[_li].k;
        var _cc = variable_struct_exists(_items[_li], "c") ? _items[_li].c : [];
        var _row = [];
        for (var _lj = 0; _lj < array_length(_kk); _lj++) {
            var _lab = _kk[_lj];
            if (_lj < array_length(_cc)) {
                var _code = _cc[_lj];
                var _padnow = (global.input_dev == "pad" && global.pad >= 0);
                if (_code == -4) _lab = _padnow ? L("สติ๊กขึ้น", "Stick Up") : input_label("up");
                else if (_code == -5 || _code == -6) _lab = _padnow ? L("สติ๊กซ้าย", "L-Stick") : _lab;
                else if (_code == -2) _lab = input_label("weapon");
                else _lab = input_code_label(_code, _lab);
            }
            _row[_lj] = _lab;
        }
        _labels[_li] = _row;
    }
    for (var _a = 0; _a < _n; _a++) {
        var _w = 0;
        var _ks = _labels[_a];
        for (var _b = 0; _b < array_length(_ks); _b++) _w += max(28, string_width(_ks[_b]) * _s + 16) + 5;
        _w += string_width(_items[_a].t) * _s + 4;
        _wmax = max(_wmax, _w);
    }
    var _pw = _wmax + _pad * 2;
    var _ph = _n * _rowh + _pad * 2 - 6;
    var _x0 = _x - _pw / 2;
    var _y0 = _y - _ph / 2 + sin(_t / 25) * 3;

    // ★ สไตล์เดียวกับ UI ใหม่ (ไล่สี + ขอบทอง / เขียวเมื่อทำแล้ว)
    draw_set_alpha(_alpha * 0.85);
    draw_rectangle_color(_x0, _y0, _x0 + _pw, _y0 + _ph, UI_BG2, UI_BG2, UI_BG, UI_BG, false);
    draw_set_alpha(_alpha);
    draw_set_color(_tick ? make_color_rgb(120, 230, 120) : UI_GOLD);
    draw_rectangle(_x0, _y0, _x0 + _pw, _y0 + _ph, true);
    draw_set_color(_tick ? make_color_rgb(60, 140, 60) : UI_GOLD_DARK);
    draw_rectangle(_x0 + 3, _y0 + 3, _x0 + _pw - 3, _y0 + _ph - 3, true);

    draw_set_valign(fa_middle);
    for (var _c = 0; _c < _n; _c++) {
        var _cy = _y0 + _pad + _c * _rowh + 14;
        var _cx = _x0 + _pad;
        var _ks2 = _labels[_c];
        for (var _d = 0; _d < array_length(_ks2); _d++) {
            var _kw = max(28, string_width(_ks2[_d]) * _s + 16);
            draw_set_alpha(_alpha * 0.95);
            var _gt = variable_struct_exists(_items[_c], "g") && _items[_c].g[_d];
            draw_set_color(_gt ? make_color_rgb(40, 110, 50) : make_color_rgb(150, 120, 70));
            draw_rectangle(_cx, _cy - 11, _cx + _kw, _cy + 14, false);
            draw_set_color(_gt ? make_color_rgb(150, 240, 150) : make_color_rgb(250, 235, 200));
            draw_rectangle(_cx, _cy - 13, _cx + _kw, _cy + 11, false);
            draw_set_halign(fa_center);
            draw_set_color(make_color_rgb(40, 30, 20));
            draw_text_transformed(_cx + _kw / 2, _cy, _ks2[_d], _s, _s, 0);
            draw_set_halign(fa_left);
            _cx += _kw + 5;
        }
        draw_set_alpha(_alpha);
        ui_text(_cx + 4, _cy, _items[_c].t, _s, UI_TEXT);
    }
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// ตัดบรรทัดอัตโนมัติ (ภาษาไทยไม่มีเว้นวรรค ต้องตัดเอง)
function text_wrap_thai(_str, _maxw) {
    draw_set_font(fnt_dialog);
    // ★ ภาษาอังกฤษ: ตัดบรรทัดตามช่องว่าง (คำไม่ขาดกลางคำ)
    if (global.lang == "en") return text_wrap_words(_str, _maxw);
    var _out = "";
    var _line = "";
    var _n = string_length(_str);
    for (var _i = 1; _i <= _n; _i++) {
        var _c = string_char_at(_str, _i);
        if (_c == "\n") {
            _out += _line + "\n";
            _line = "";
            continue;
        }
        if (string_width(_line + _c) > _maxw) {
            _out += _line + "\n";
            _line = "";
        }
        _line += _c;
    }
    return _out + _line;
}

function dialogue_start(_lines, _on_done = undefined) {
    if (instance_exists(obj_dialogue) && !obj_dialogue.closing) return;
    if (array_length(_lines) == 0) {
        if (is_callable(_on_done)) _on_done();
        return;
    }
    var _d = instance_create_depth(0, 0, -9000, obj_dialogue);
    _d.lines = _lines;
    _d.on_done = _on_done;
    _d.load_line();
}

// ★ ตัดบรรทัดแบบภาษาอังกฤษ (ตามช่องว่าง)
function text_wrap_words(_str, _maxw) {
    draw_set_font(fnt_dialog);
    var _out = "";
    var _paras = string_split(_str, "\n");
    for (var _p = 0; _p < array_length(_paras); _p++) {
        var _words = string_split(_paras[_p], " ");
        var _line = "";
        for (var _w = 0; _w < array_length(_words); _w++) {
            var _try = (_line == "") ? _words[_w] : (_line + " " + _words[_w]);
            if (_line != "" && string_width(_try) > _maxw) {
                _out += _line + "\n";
                _line = _words[_w];
            } else _line = _try;
        }
        _out += _line;
        if (_p < array_length(_paras) - 1) _out += "\n";
    }
    return _out;
}
