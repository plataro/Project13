if (instance_exists(obj_fade)) exit;
if (instance_exists(obj_pause) && obj_pause.open) exit;   // หน้าตั้งค่าเปิดทับอยู่

var _enter = keyboard_check_pressed(vk_enter);
var _click = mouse_check_button_pressed(mb_left);
var _back = keyboard_check_pressed(vk_escape);

// หน้าวิธีเล่น / เครดิต: กดอะไรก็ได้เพื่อกลับ
if (screen == 1 || screen == 2) {
    if (_enter || _click || _back) {
        screen = 0;
        sel = 0;
    }
    exit;
}

// หน้าเลือกฉาก (Debug) / เลือกระดับความยาก: Esc กลับ
if (msg_timer > 0) msg_timer--;

if (screen == 3 && _back) {
    screen = 0;
    sel = 0;
    exit;
}
if (screen == 4 && _back) {
    screen = 0;
    sel = 0;
    exit;
}

// สร้างรายการเมนู
if (screen == 0) {
    items = [];
    acts = [];
    if (has_save) { array_push(items, "เล่นต่อ"); array_push(acts, "continue"); }
    array_push(items, has_save ? "เริ่มเกมใหม่" : "เริ่มเกม"); array_push(acts, "new");
    array_push(items, "วิธีเล่น");  array_push(acts, "howto");
    array_push(items, "เครดิต");    array_push(acts, "credits");
    array_push(items, "ตั้งค่า");    array_push(acts, "settings");
    array_push(items, global.debug ? "Debug Mode: เปิด" : "Debug Mode: ปิด"); array_push(acts, "debug");
    if (global.debug) { array_push(items, "เลือกฉาก"); array_push(acts, "scenes"); }
} else if (screen == 4) {
    items = ["ง่าย", "ปานกลาง", "ยาก", "กลับ"];
} else {
    items = [];
    for (var _i = 0; _i < array_length(global.levels); _i++) {
        var _rt = room_title(global.levels[_i]);
        array_push(items, (_rt != "") ? _rt : room_get_name(global.levels[_i]));
    }
    array_push(items, "กลับ");
}

var _n = array_length(items);

if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) sel = (sel + 1) mod _n;
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) sel = (sel - 1 + _n) mod _n;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _moved = (_mx != last_mx || _my != last_my);
last_mx = _mx;
last_my = _my;

var _clicked = false;
for (var _j = 0; _j < _n; _j++) {
    var _y = item_y(_j);
    var _over = (_mx > 320 && _mx < 640 && _my > _y - 6 && _my < _y + 30);
    if (_over && _moved) sel = _j;
    if (_over && _click) {
        sel = _j;
        _clicked = true;
    }
}

sel = clamp(sel, 0, _n - 1);

if (_enter || _clicked) {
    if (screen == 0) {
        switch (acts[sel]) {
            case "continue":
                var _r = save_load();
                if (_r == -1) {
                    msg = "โหลดเซฟไม่ได้ (ไฟล์เสีย)";
                    msg_timer = 180;
                    has_save = false;
                    sel = 0;
                } else {
                    var _fc = instance_create_depth(0, 0, -10000, obj_fade);
                    _fc.target_room = _r;
                }
                break;
            case "new":
                // ไปหน้าเลือกระดับความยาก (เริ่มที่ระดับที่เลือกไว้ครั้งก่อน)
                screen = 4;
                sel = global.difficulty;
                break;
            case "howto":
                screen = 1;
                break;
            case "credits":
                screen = 2;
                break;
            case "settings":
                if (instance_exists(obj_pause)) obj_pause.open_settings_menu();
                break;
            case "debug":
                global.debug = !global.debug;
                if (global.debug) {
                    if (!instance_exists(obj_debug)) instance_create_depth(0, 0, -9500, obj_debug);
                } else {
                    global.god = false;
                    instance_destroy(obj_debug);
                }
                break;
            case "scenes":
                screen = 3;
                sel = 0;
                break;
        }
    } else if (screen == 4) {
        if (sel >= 3) {
            screen = 0;
            sel = 0;
        } else {
            global.difficulty = sel;
            game_reset();
            var _f = instance_create_depth(0, 0, -10000, obj_fade);
            _f.target_room = global.levels[0];
        }
    } else {
        // หน้าเลือกฉาก (Debug)
        if (sel >= array_length(global.levels)) {
            screen = 0;
            sel = 0;
        } else {
            game_reset();
            var _f2 = instance_create_depth(0, 0, -10000, obj_fade);
            _f2.target_room = global.levels[sel];
        }
    }
}