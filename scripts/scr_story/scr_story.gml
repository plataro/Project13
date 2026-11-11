global.story_seen = {};
global.ending = "kill";    // "kill" หรือ "join" (ตั้งตอนเลือกในห้องบอส)
global.choice = "";        // ค่าที่ผู้เล่นเลือกในบทสนทนาล่าสุด

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
    // ผู้เล่น = "ผู้ไร้นาม"  ราชามังกร = who "b"  (เปลี่ยน who/emo ตามรูป portrait ที่มี)
    var _me = "ผู้ไร้นาม";
    var _dr = "ราชามังกร";
    switch (_key) {
        // ---------- Sanctuary: ตื่นขึ้นมา ----------
        case "intro":
            return [
                { name: _me, text: "...หนาวจัง" },
                { name: _me, text: "ที่นี่ที่ไหนกัน? ฉัน... จำอะไรไม่ได้เลย แม้แต่ชื่อของตัวเอง" },
                { name: _me, text: "แต่มีเสียงบางอย่างเรียกอยู่ข้างนอกนั่น เหมือนมีบางอย่างที่ฉันต้องไปให้ถึง" },
                { name: _me, text: "ลองเดินออกไปดูก็แล้วกัน... ถ้าเจอทางออกนะ" },
            ];
        case "sword_found":
            return [
                { name: _me, text: "ดาบเล่มนี้... ทำไมมันถึงคุ้นมือขนาดนี้" },
                { name: _me, text: "เหมือนมันรอฉันมานานแล้ว" },
                { name: _me, text: "ไปกันเถอะ" },
            ];

        // ---------- ป่า ----------
        case "level1_mid":
            return [
                { name: _me, text: "รอยไหม้บนพื้น... และต้นไม้ที่ล้มระเนระนาด" },
                { name: _me, text: "นี่มันฝีมือของสัตว์ประหลาดพวกนี้... หรือของ 'มังกร' ที่ชาวบ้านพูดถึงกันนะ" },
            ];

        // ---------- หมู่บ้าน ----------
        case "village_intro":
            return [
                { name: "ชาวบ้าน", text: "นั่น... นักรบเหรอ? รอดมาจากป่านั่นได้ยังไงกัน" },
                { name: "ชาวบ้าน", text: "ราชามังกรกลับมาแล้ว ท้องฟ้าเหนือปราสาทกลายเป็นสีเลือดมาหลายคืน" },
                { name: "ชาวบ้าน", text: "ประตูปราสาทถูกผนึกไว้ ต้องไปเอาตราจากเหมืองร้างทางตะวันออกก่อนถึงจะเข้าไปได้" },
                { name: _me, text: "(ลองคุยกับพ่อค้าดูหน่อย... ของที่ซื้อได้อาจช่วยชีวิตฉันไว้)" },
            ];

        // ---------- เหมือง ----------
        case "mine_intro":
            return [
                { name: _me, text: "เหมืองร้าง... เงียบจนน่าขนลุก" },
                { name: _me, text: "บนผนังมีรอยกรงเล็บขนาดใหญ่ ใหญ่เกินกว่าสัตว์ธรรมดาจะทำได้" },
            ];

        // ---------- ปราสาท ----------
        case "castle_intro":
            return [
                { name: _me, text: "นี่คือปราสาทของราชามังกร... แต่ทำไมฉันรู้สึกเหมือนเคยมาที่นี่" },
                { name: _me, text: "ความทรงจำบางอย่างกำลังย้อนกลับมา... ทีละนิด" },
            ];

        // ---------- ห้องโถงสุดท้าย (side-scroll) ----------
        case "hall_1":
            return [
                { name: "ผู้บรรยาย", text: "บนผนังมีภาพสลักเก่าแก่ นักรบถือดาบยืนเคียงข้างมังกรตัวใหญ่ ทั้งคู่ชูมือขึ้นสู่ท้องฟ้า" },
                { name: _me, text: "เคียงข้างกัน...? มนุษย์กับมังกรเนี่ยนะ" },
            ];
        case "hall_2":
            return [
                { name: "ผู้บรรยาย", text: "ภาพถัดมา นักรบหลับใหลอยู่ในวิหาร และมังกรตัวนั้นกำลังปิดผนึก... ด้วยน้ำตา" },
                { name: _me, text: "วิหารนั่น... คือที่ที่ฉันตื่นขึ้นมา" },
                { name: _me, text: "แล้วคนที่ผนึกฉันไว้ก็คือ... ราชามังกรเอง?" },
            ];
        case "hall_end":
            return [
                { name: _me, text: "ประตูบานสุดท้าย" },
                { name: _me, text: "ไม่ว่าเบื้องหลังจะมีอะไรอยู่ ฉันต้องรู้ความจริง" },
            ];

        // ---------- ห้องบอส: มีตัวเลือก ----------
        case "boss_intro":
            return [
                { name: _dr, who: "b", side: "right", emo: "normal", text: "ในที่สุดเจ้าก็มาถึง... สหายของข้า" },
                { name: _me, who: "a", side: "left", emo: "surprised", text: "นายรู้จักฉันงั้นเหรอ" },
                { name: _dr, who: "b", side: "right", emo: "sad", text: "ข้าเองที่ผนึกเจ้าไว้ในวิหาร เพื่อให้เจ้าพ้นจากสงครามที่ข้าไม่อาจหยุดได้" },
                { name: _dr, who: "b", side: "right", emo: "sad", text: "เราเคยสร้างสันติสุขร่วมกัน ก่อนที่ไฟแห่งความแค้นจะกลืนสติของข้าไป" },
                { name: _dr, who: "b", side: "right", emo: "normal", text: "ข้าเหลือสติอยู่อีกไม่นาน ถ้าเจ้าไม่หยุดข้า ข้าจะเผาโลกนี้ทั้งใบ... หรือไม่ก็ยืนเคียงข้างข้า แล้วเราจะสร้างโลกใหม่ด้วยกันอีกครั้ง" },
                { name: _me, who: "a", side: "left", emo: "normal", text: "ฉัน...", choices: [
                    { t: "ฉันจะหยุดนายเอง", v: "kill" },
                    { t: "ฉันจะอยู่เคียงข้างนาย", v: "join" }
                ] },
            ];
        case "boss_kill":
            return [
                { name: _me, who: "a", side: "left", emo: "sad", text: "ขอโทษนะ... แต่ฉันต้องทำ" },
                { name: _dr, who: "b", side: "right", emo: "happy", text: "นั่นล่ะ... คำตอบที่ข้ารอคอย มาเถอะ!" },
            ];

        // ---------- ตอนจบ ----------
        case "ending_kill":
            return [
                { name: _dr, who: "b", side: "right", emo: "happy", text: "ขอบใจ... สหายของข้า ไฟแค้นกำลังดับลงแล้ว" },
                { name: _me, who: "a", side: "left", emo: "sad", text: "หลับให้สบายเถอะ... ฉันจะจำนายไว้" },
            ];
        case "ending_join":
            return [
                { name: _dr, who: "b", side: "right", emo: "happy", text: "ขอบใจ... สหายของข้า ด้วยกัน เราจะไม่แพ้ใครอีก" },
                { name: _me, who: "a", side: "left", emo: "happy", text: "คราวนี้ ฉันจะไม่ลืมนายอีกแล้ว" },
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
                { img: "spr_cs_intro_1", text: "นานมาแล้ว มังกรและมนุษย์เคยอยู่ร่วมกันภายใต้ท้องฟ้าเดียวกัน" },
                { img: "spr_cs_intro_2", text: "จนวันหนึ่ง ไฟแห่งสงครามลุกลามไปทั่วแผ่นดิน ราชามังกรผู้ยิ่งใหญ่หายไปในเปลวเพลิง" },
                { img: "spr_cs_intro_3", text: "ผู้คนเล่าขานว่า นักรบนิรนามคนหนึ่งถูกผนึกไว้ในวิหารเก่าแก่ เพื่อรอวันที่โลกต้องการเขาอีกครั้ง" },
                { img: "spr_cs_intro_4", text: "และบัดนี้ ราชามังกรกลับมาแล้ว ท้องฟ้าเหนือปราสาทกลายเป็นสีเลือด" },
                { img: "spr_cs_intro_5", text: "ในความเงียบของวิหาร... บางสิ่งกำลังตื่นขึ้น" },
            ];
        case "end_kill":
            return [
                { img: "spr_cs_kill_1", text: "ร่างของราชามังกรสลายเป็นแสงสีทอง ไฟที่ลุกทั่วแผ่นดินค่อย ๆ มอดดับลง" },
                { img: "spr_cs_kill_2", text: "ท้องฟ้ากลับเป็นสีคราม ชาวบ้านโห่ร้องเรียกขานผู้กล้า ทั้งที่ไม่มีใครรู้ชื่อจริงของเขา" },
                { img: "spr_cs_kill_3", text: "ผู้ไร้นามเก็บเกล็ดมังกรชิ้นสุดท้ายไว้ แล้วออกเดินทางต่อ เพื่อตามหาตัวตนที่เลือนหายไป" },
                { img: "spr_cs_kill_4", text: "ตอนจบที่ 1 : ผู้พิชิตมังกร" },
            ];
        case "end_join":
            return [
                { img: "spr_cs_join_1", text: "ผู้ไร้นามชูดาบขึ้น ไม่ใช่เพื่อฟาดฟัน แต่เพื่อประสานกับเปลวไฟของมังกร" },
                { img: "spr_cs_join_2", text: "ไฟแห่งความแค้นถูกแบ่งเป็นสอง และอ่อนแรงลง ราชามังกรได้สติกลับคืนมา" },
                { img: "spr_cs_join_3", text: "ผู้คนหวาดกลัว และไม่ใช่ทุกคนที่ยอมรับ แต่ทั้งสองเริ่มสร้างโลกใหม่ ที่มนุษย์และมังกรอยู่ร่วมกัน" },
                { img: "spr_cs_join_4", text: "ตอนจบที่ 2 : เคียงข้างราชา" },
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
    for (var _a = 0; _a < _n; _a++) {
        var _w = 0;
        var _ks = _items[_a].k;
        for (var _b = 0; _b < array_length(_ks); _b++) _w += max(28, string_width(_ks[_b]) * _s + 16) + 5;
        _w += string_width(_items[_a].t) * _s + 4;
        _wmax = max(_wmax, _w);
    }
    var _pw = _wmax + _pad * 2;
    var _ph = _n * _rowh + _pad * 2 - 6;
    var _x0 = _x - _pw / 2;
    var _y0 = _y - _ph / 2 + sin(_t / 25) * 3;

    draw_set_alpha(_alpha * 0.65);
    draw_set_color(c_black);
    draw_roundrect_ext(_x0, _y0, _x0 + _pw, _y0 + _ph, 14, 14, false);
    draw_set_alpha(_alpha * 0.8);
    draw_set_color(_tick ? c_lime : c_white);
    draw_roundrect_ext(_x0, _y0, _x0 + _pw, _y0 + _ph, 14, 14, true);

    draw_set_valign(fa_middle);
    for (var _c = 0; _c < _n; _c++) {
        var _cy = _y0 + _pad + _c * _rowh + 14;
        var _cx = _x0 + _pad;
        var _ks2 = _items[_c].k;
        for (var _d = 0; _d < array_length(_ks2); _d++) {
            var _kw = max(28, string_width(_ks2[_d]) * _s + 16);
            draw_set_alpha(_alpha * 0.95);
            draw_set_color(make_color_rgb(38, 42, 60));
            draw_roundrect_ext(_cx, _cy - 13, _cx + _kw, _cy + 13, 6, 6, false);
            draw_set_color(make_color_rgb(255, 214, 102));
            draw_roundrect_ext(_cx, _cy - 13, _cx + _kw, _cy + 13, 6, 6, true);
            draw_set_halign(fa_center);
            draw_set_color(c_white);
            draw_text_transformed(_cx + _kw / 2, _cy, _ks2[_d], _s, _s, 0);
            draw_set_halign(fa_left);
            _cx += _kw + 5;
        }
        draw_set_alpha(_alpha);
        draw_set_color(c_white);
        draw_text_transformed(_cx + 4, _cy, _items[_c].t, _s, _s, 0);
    }
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// ตัดบรรทัดอัตโนมัติ (ภาษาไทยไม่มีเว้นวรรค ต้องตัดเอง)
function text_wrap_thai(_str, _maxw) {
    draw_set_font(fnt_dialog);
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
