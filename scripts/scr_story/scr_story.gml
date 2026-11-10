global.story_seen = {};

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
    switch (_key) {
        case "intro":
			return [
				// ไม่ระบุตัวละคร = ฉากบรรยาย ทั้งสองฝั่งหรี่ลง
				{ name: "ผู้บรรยาย", text: "กาลครั้งหนึ่งเมื่อไม่นานนี้ มีวงกลม และสี่เหลี่ยมคุยกัน" },

				// who = key ใน portrait_data, side = left หรือ right, emo = ชื่ออารมณ์
				{ name: "ตัวละคร A", who: "a", side: "left", emo: "normal", text: "สวัสดีจร้า" },
				{ name: "ตัวละคร B", who: "b", side: "right", emo: "sad", text: "ไก่ว่ะ" },

				// hide = left, right หรือ both ให้ตัวละครออกจากฉาก
				{ name: "ตัวละคร A", who: "a", side: "left", emo: "surprised", text: "เอ้าอินี่", hide: "right" },
			];

        case "level1_mid":
            return [
                { name: "ตัวละคร B", text: "อยากกินไก่" },
            ];
			
		case "ending":
            return [
                { name: "ผู้บรรยาย", text: "จบแล้วจ้า เก่งมากเรย" },
            ];
    }
    return [];
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

function dialogue_start(_lines) {
    if (instance_exists(obj_dialogue)) return;
    if (array_length(_lines) == 0) return;
    var _d = instance_create_depth(0, 0, -9000, obj_dialogue);
    _d.lines = _lines;
    _d.load_line();
}
