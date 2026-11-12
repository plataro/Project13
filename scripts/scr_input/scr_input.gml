// =====================================================================
// ★ ระบบปุ่ม: ถามเป็น "การกระทำ" แทนปุ่มตรง ๆ  รองรับคีย์บอร์ด+เมาส์ และจอย
//   input_check("attack")    กดค้าง
//   input_pressed("attack")  เพิ่งกด
//   input_released("attack") เพิ่งปล่อย
//   input_move_x() / input_move_y()   ทิศเดิน -1..1 (สติ๊กซ้ายเป็นค่าต่อเนื่อง)
//   input_aim(x, y, dir_เดิม)          ทิศเล็ง (เมาส์ / สติ๊กขวา / ทิศเดิน + ช่วยเล็ง)
//   input_label("attack")    ชื่อปุ่มตามอุปกรณ์ที่ใช้อยู่ (ใช้ในป้ายสอน/แถบสกิล)
//
// รหัสปุ่มคีย์บอร์ด: >= 0 = keycode ปกติ
// รหัสเมาส์: -1 คลิกซ้าย, -2 คลิกขวา, -3 คลิกกลาง, -4 ล้อขึ้น, -5 ล้อลง
// =====================================================================
#macro PAD_DEAD 0.35

global.input_dev = "kb";    // อุปกรณ์ล่าสุดที่ผู้เล่นใช้: "kb" / "pad"
global.pad = -1;            // จอยที่เสียบอยู่ (-1 = ไม่มี)
global.inp_stick = { left: false, right: false, up: false, down: false };
global.inp_stick_prev = { left: false, right: false, up: false, down: false };
global.inp_mx = 0;
global.inp_my = 0;

// ปุ่มตั้งต้น (คีย์บอร์ด) — แต่ละการกระทำมีได้หลายปุ่ม ปุ่มแรกคือปุ่มที่ผู้เล่นตั้งเองได้
function input_kb_defaults() {
    return {
        left:      [ord("A"), vk_left],
        right:     [ord("D"), vk_right],
        up:        [ord("W"), vk_up],
        down:      [ord("S"), vk_down],
        run:       [vk_shift],
        attack:    [-1],
        roll:      [vk_space],          // กลิ้ง (มุมบน) / กระโดด (ด้านข้าง)
        shoot1:    [ord("1")],
        shoot2:    [ord("2")],
        potion:    [ord("Q")],
        interact:  [ord("E")],
        buff_use:  [ord("F")],
        buff_next: [ord("V")],
        weapon:    [ord("R"), -5],
        tree:      [ord("T")],
        status:    [vk_tab],            // ★ Tab ใกล้มือ (เดิม I)
        pause:     [ord("P")]
    };
}
// ปุ่มตั้งต้น (จอย) — ปุ่มเดียวต่อการกระทำ (-1 = ไม่มี)
function input_pad_defaults() {
    return {
        left: -1, right: -1, up: -1, down: -1,   // เดินด้วยสติ๊กซ้าย (ปุ่มลูกศรบนจอยใช้เป็นปุ่มลัดแทน)
        run: gp_shoulderl,       // LB
        attack: gp_face3,        // X
        roll: gp_face1,          // A
        shoot1: gp_shoulderr,    // RB
        shoot2: gp_shoulderrb,   // RT
        potion: gp_face4,        // Y
        interact: gp_face2,      // B
        buff_use: gp_shoulderlb, // LT
        buff_next: gp_padr,      // ลูกศรขวา
        weapon: gp_padd,         // ลูกศรลง
        tree: gp_select,         // Back
        status: gp_padu,         // ลูกศรขึ้น
        pause: gp_start
    };
}
global.bind_kb = input_kb_defaults();
global.bind_pad = input_pad_defaults();

// รายการที่ผู้เล่นตั้งปุ่มเองได้ (ลำดับในหน้าตั้งค่าปุ่ม)
function input_rebind_list() {
    return ["attack", "roll", "run", "shoot1", "shoot2", "potion", "interact", "buff_use", "buff_next", "weapon", "tree", "status", "pause"];
}
function input_action_name(_a) {
    switch (_a) {
        case "attack":    return L("โจมตี", "Attack");
        case "roll":      return L("กลิ้งหลบ / กระโดด", "Roll / Jump");
        case "run":       return L("วิ่ง", "Run");
        case "shoot1":    return L("ยิงลูกไฟ", "Fireball");
        case "shoot2":    return L("ยิงกระจาย", "Spread shot");
        case "potion":    return L("ดื่มยา", "Potion");
        case "interact":  return L("คุย / เปิด / ใช้", "Interact");
        case "buff_use":  return L("ใช้บัฟ", "Use buff");
        case "buff_next": return L("เปลี่ยนบัฟ", "Switch buff");
        case "weapon":    return L("สลับอาวุธ", "Switch weapon");
        case "tree":      return L("ต้นไม้สกิล", "Skill tree");
        case "status":    return L("หน้าสถานะ", "Status");
        case "pause":     return L("หยุดเกม", "Pause");
        case "left":      return L("ซ้าย", "Left");
        case "right":     return L("ขวา", "Right");
        case "up":        return L("ขึ้น", "Up");
        case "down":      return L("ลง", "Down");
    }
    return _a;
}

// ---------------------------------------------------------------------
// อัปเดตทุกเฟรม (เรียกจาก obj_pause Begin Step ซึ่งอยู่ตลอดเกม)
// ---------------------------------------------------------------------
function input_update() {
    // หาจอยที่เสียบอยู่
    if (global.pad < 0 || !gamepad_is_connected(global.pad)) {
        global.pad = -1;
        for (var _i = 0; _i < 12; _i++) if (gamepad_is_connected(_i)) { global.pad = _i; break; }
    }
    // สติ๊กซ้าย -> ทิศแบบ "กด" (ใช้เลื่อนเมนู)
    global.inp_stick_prev = global.inp_stick;
    var _st = { left: false, right: false, up: false, down: false };
    if (global.pad >= 0) {
        gamepad_set_axis_deadzone(global.pad, 0.15);
        var _h = gamepad_axis_value(global.pad, gp_axislh);
        var _v = gamepad_axis_value(global.pad, gp_axislv);
        _st.left = _h < -0.6; _st.right = _h > 0.6;
        _st.up = _v < -0.6;   _st.down = _v > 0.6;
    }
    global.inp_stick = _st;

    // อุปกรณ์ล่าสุด
    if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any)
        || abs(window_mouse_get_x() - global.inp_mx) + abs(window_mouse_get_y() - global.inp_my) > 6) {
        global.input_dev = "kb";
    }
    global.inp_mx = window_mouse_get_x();
    global.inp_my = window_mouse_get_y();
    if (global.pad >= 0) {
        var _any = false;
        for (var _b = gp_face1; _b <= gp_padr; _b++) if (gamepad_button_check_pressed(global.pad, _b)) _any = true;
        if (abs(gamepad_axis_value(global.pad, gp_axislh)) + abs(gamepad_axis_value(global.pad, gp_axislv))
          + abs(gamepad_axis_value(global.pad, gp_axisrh)) + abs(gamepad_axis_value(global.pad, gp_axisrv)) > 0.5) _any = true;
        if (_any) global.input_dev = "pad";
    }
}

// ---------------------------------------------------------------------
// ตรวจปุ่ม (_mode 0 = ค้าง, 1 = เพิ่งกด, 2 = เพิ่งปล่อย)
// ---------------------------------------------------------------------
function input_code_check(_c, _mode) {
    if (_c >= 0) {
        if (_mode == 0) return keyboard_check(_c);
        if (_mode == 1) return keyboard_check_pressed(_c);
        return keyboard_check_released(_c);
    }
    var _mb = mb_none;
    switch (_c) {
        case -1: _mb = mb_left; break;
        case -2: _mb = mb_right; break;
        case -3: _mb = mb_middle; break;
        case -4: return (_mode != 2) && mouse_wheel_up();
        case -5: return (_mode != 2) && mouse_wheel_down();
    }
    if (_mb == mb_none) return false;
    if (_mode == 0) return mouse_check_button(_mb);
    if (_mode == 1) return mouse_check_button_pressed(_mb);
    return mouse_check_button_released(_mb);
}
function input_act(_act, _mode) {
    var _kb = global.bind_kb[$ _act];
    if (!is_undefined(_kb)) {
        for (var _i = 0; _i < array_length(_kb); _i++) if (input_code_check(_kb[_i], _mode)) return true;
    }
    if (global.pad >= 0) {
        var _pb = global.bind_pad[$ _act];
        if (!is_undefined(_pb) && _pb >= 0) {
            if (_mode == 0 && gamepad_button_check(global.pad, _pb)) return true;
            if (_mode == 1 && gamepad_button_check_pressed(global.pad, _pb)) return true;
            if (_mode == 2 && gamepad_button_check_released(global.pad, _pb)) return true;
        }
        // ทิศจากสติ๊กซ้าย
        if (_act == "left" || _act == "right" || _act == "up" || _act == "down") {
            var _now = global.inp_stick[$ _act];
            var _was = global.inp_stick_prev[$ _act];
            if (_mode == 0 && _now) return true;
            if (_mode == 1 && _now && !_was) return true;
            if (_mode == 2 && !_now && _was) return true;
        }
    }
    return false;
}
function input_check(_act)    { return input_act(_act, 0); }
function input_pressed(_act)  { return input_act(_act, 1); }
function input_released(_act) { return input_act(_act, 2); }

// ทิศเดิน (สติ๊กซ้ายให้ค่าต่อเนื่อง ปุ่มให้ -1/0/1)
function input_move_x() {
    if (global.pad >= 0) {
        var _h = gamepad_axis_value(global.pad, gp_axislh);
        if (abs(_h) > PAD_DEAD) return clamp(_h, -1, 1);
    }
    return input_check("right") - input_check("left");
}
function input_move_y() {
    if (global.pad >= 0) {
        var _v = gamepad_axis_value(global.pad, gp_axislv);
        if (abs(_v) > PAD_DEAD) return clamp(_v, -1, 1);
    }
    return input_check("down") - input_check("up");
}

// ทิศเล็ง: เมาส์ (คีย์บอร์ด) / สติ๊กขวา / ทิศเดิน / ทิศเดิม + ช่วยเล็งหาศัตรูใกล้ ๆ (จอย)
function input_aim(_px, _py, _fallback) {
    if (global.input_dev != "pad" || global.pad < 0) return point_direction(_px, _py, mouse_x, mouse_y);
    var _dir = _fallback;
    var _rh = gamepad_axis_value(global.pad, gp_axisrh);
    var _rv = gamepad_axis_value(global.pad, gp_axisrv);
    if (point_distance(0, 0, _rh, _rv) > 0.4) _dir = point_direction(0, 0, _rh, _rv);
    else {
        var _lh = gamepad_axis_value(global.pad, gp_axislh);
        var _lv = gamepad_axis_value(global.pad, gp_axislv);
        if (point_distance(0, 0, _lh, _lv) > PAD_DEAD) _dir = point_direction(0, 0, _lh, _lv);
    }
    // ช่วยเล็ง: ศัตรูที่ใกล้ทิศนั้นที่สุด (ภายใน 40 องศา ระยะ 420)
    var _best = noone;
    var _score = 99999;
    with (obj_enemy) {
        if (hp <= 0) continue;
        if (variable_instance_exists(id, "vis") && vis < 0.3) continue;
        var _d = point_distance(_px, _py, x, y - 30);
        if (_d > 420) continue;
        var _diff = abs(angle_difference(point_direction(_px, _py, x, y - 30), _dir));
        if (_diff > 40) continue;
        var _s = _d + _diff * 6;
        if (_s < _score) { _score = _s; _best = id; }
    }
    if (_best != noone) _dir = point_direction(_px, _py, _best.x, _best.y - 30);
    return _dir;
}

// ---------------------------------------------------------------------
// เมนู: เลื่อน/ยืนยัน/ย้อนกลับ (คีย์บอร์ด + จอย)
// ---------------------------------------------------------------------
function input_stick_edge(_d) { return global.pad >= 0 && global.inp_stick[$ _d] && !global.inp_stick_prev[$ _d]; }
function input_ui_up()      { return keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || input_pad_pressed(gp_padu) || input_stick_edge("up"); }
function input_ui_down()    { return keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || input_pad_pressed(gp_padd) || input_stick_edge("down"); }
function input_ui_left()    { return keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || input_pad_pressed(gp_padl) || input_stick_edge("left"); }
function input_ui_right()   { return keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || input_pad_pressed(gp_padr) || input_stick_edge("right"); }
function input_ui_confirm() { return keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || (global.pad >= 0 && gamepad_button_check_pressed(global.pad, gp_face1)); }
function input_ui_back()    { return keyboard_check_pressed(vk_escape) || (global.pad >= 0 && gamepad_button_check_pressed(global.pad, gp_face2)); }
// ปุ่มยืนยันเฉพาะจอย (ใช้ที่ที่คีย์บอร์ดต้องคลิกเมาส์ เช่น ตัวเลือกตอนจบ)
function input_pad_confirm() { return global.pad >= 0 && gamepad_button_check_pressed(global.pad, gp_face1); }
function input_pad_pressed(_b) { return global.pad >= 0 && gamepad_button_check_pressed(global.pad, _b); }

// ---------------------------------------------------------------------
// ชื่อปุ่ม
// ---------------------------------------------------------------------
function input_key_name(_c) {
    switch (_c) {
        case -1: return L("คลิกซ้าย", "LMB");
        case -2: return L("คลิกขวา", "RMB");
        case -3: return L("คลิกกลาง", "MMB");
        case -4: return L("ล้อขึ้น", "Wheel Up");
        case -5: return L("ล้อลง", "Wheel Down");
        case vk_space: return "Space";
        case vk_shift: case vk_lshift: case vk_rshift: return "Shift";
        case vk_control: case vk_lcontrol: case vk_rcontrol: return "Ctrl";
        case vk_alt: case vk_lalt: case vk_ralt: return "Alt";
        case vk_enter: return "Enter";
        case vk_tab: return "Tab";
        case vk_escape: return "Esc";
        case vk_backspace: return "Backspace";
        case vk_up: return L("ลูกศรขึ้น", "Up");
        case vk_down: return L("ลูกศรลง", "Down");
        case vk_left: return L("ลูกศรซ้าย", "Left");
        case vk_right: return L("ลูกศรขวา", "Right");
    }
    if (_c >= ord("A") && _c <= ord("Z")) return chr(_c);
    if (_c >= ord("0") && _c <= ord("9")) return chr(_c);
    if (_c >= vk_numpad0 && _c <= vk_numpad9) return "Num" + string(_c - vk_numpad0);
    if (_c >= vk_f1 && _c <= vk_f12) return "F" + string(_c - vk_f1 + 1);
    return "#" + string(_c);
}
function input_pad_name(_b) {
    switch (_b) {
        case gp_face1: return "A";
        case gp_face2: return "B";
        case gp_face3: return "X";
        case gp_face4: return "Y";
        case gp_shoulderl: return "LB";
        case gp_shoulderr: return "RB";
        case gp_shoulderlb: return "LT";
        case gp_shoulderrb: return "RT";
        case gp_select: return "Back";
        case gp_start: return "Start";
        case gp_stickl: return "L3";
        case gp_stickr: return "R3";
        case gp_padu: return L("ปุ่มลูกศรขึ้น", "D-Up");
        case gp_padd: return L("ปุ่มลูกศรลง", "D-Down");
        case gp_padl: return L("ปุ่มลูกศรซ้าย", "D-Left");
        case gp_padr: return L("ปุ่มลูกศรขวา", "D-Right");
    }
    return "-";
}
// ชื่อปุ่มของการกระทำตามอุปกรณ์ที่ใช้อยู่
function input_label(_act) {
    if (global.input_dev == "pad" && global.pad >= 0) {
        if (_act == "move") return L("สติ๊กซ้าย", "L-Stick");
        if (_act == "aim") return L("สติ๊กขวา", "R-Stick");
        var _pb = global.bind_pad[$ _act];
        return (is_undefined(_pb) || _pb < 0) ? "-" : input_pad_name(_pb);
    }
    if (_act == "move") return "WASD";
    if (_act == "aim") return L("เมาส์", "Mouse");
    var _kb = global.bind_kb[$ _act];
    return (is_undefined(_kb) || array_length(_kb) == 0) ? "-" : input_key_name(_kb[0]);
}

// ---------------------------------------------------------------------
// เซฟ/โหลดการตั้งปุ่ม (settings.ini)
// ---------------------------------------------------------------------
function input_save() {
    ini_open("settings.ini");
    ini_write_real("keys", "ver", 2);
    var _l = input_rebind_list();
    for (var _i = 0; _i < array_length(_l); _i++) {
        ini_write_real("keys", _l[_i], global.bind_kb[$ _l[_i]][0]);
        ini_write_real("pad", _l[_i], global.bind_pad[$ _l[_i]]);
    }
    ini_close();
}
function input_load() {
    global.bind_kb = input_kb_defaults();
    global.bind_pad = input_pad_defaults();
    ini_open("settings.ini");
    var _ver = ini_read_real("keys", "ver", 0);   // ★ ver 2: ปุ่มหน้าสถานะเปลี่ยนจาก I เป็น Tab (เซฟเก่าไม่ทับค่าใหม่)
    var _l = input_rebind_list();
    for (var _i = 0; _i < array_length(_l); _i++) {
        var _a = _l[_i];
        if (_a == "status" && _ver < 2) continue;
        if (ini_key_exists("keys", _a)) global.bind_kb[$ _a][0] = ini_read_real("keys", _a, global.bind_kb[$ _a][0]);
        if (ini_key_exists("pad", _a)) global.bind_pad[$ _a] = ini_read_real("pad", _a, global.bind_pad[$ _a]);
    }
    ini_close();
}
function input_reset_defaults() {
    global.bind_kb = input_kb_defaults();
    global.bind_pad = input_pad_defaults();
    input_save();
}

// ปุ่มเดิมในป้ายสอน (Creation Code ของห้อง) -> การกระทำ
function input_code_act(_c) {
    switch (_c) {
        case -1: return "attack";
        case vk_space: return "roll";
        case vk_shift: return "run";
        case ord("E"): return "interact";
        case ord("1"): return "shoot1";
        case ord("2"): return "shoot2";
        case ord("Q"): return "potion";
        case ord("T"): return "tree";
        case ord("R"): return "weapon";
        case ord("A"): return "left";
        case ord("D"): return "right";
        case ord("W"): return "up";
        case ord("S"): return "down";
    }
    return "";
}
// ป้ายชื่อปุ่มในป้ายสอน: แปลงจากรหัสปุ่มเดิมเป็นชื่อปุ่มตามอุปกรณ์ที่ใช้อยู่
function input_code_label(_c, _fallback) {
    var _a = input_code_act(_c);
    if (_a == "") return _fallback;
    if (global.input_dev == "pad" && global.pad >= 0 && (_a == "left" || _a == "right" || _a == "up" || _a == "down")) return L("สติ๊กซ้าย", "L-Stick");
    return input_label(_a);
}
