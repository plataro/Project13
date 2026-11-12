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
if (screen == 3 && _back) {
    screen = 0;
    sel = 5;
    exit;
}
if (screen == 4 && _back) {
    screen = 0;
    sel = 0;
    exit;
}

// สร้างรายการเมนู
if (screen == 0) {
    items = ["เริ่มเกม", "วิธีเล่น", "เครดิต", "ตั้งค่า", global.debug ? "Debug Mode: เปิด" : "Debug Mode: ปิด"];
    if (global.debug) array_push(items, "เลือกฉาก");
} else if (screen == 4) {
    items = ["ง่าย", "ปานกลาง", "ยาก", "กลับ"];
} else {
    items = [];
    for (var _i = 0; _i < array_length(global.levels); _i++) {
        array_push(items, room_get_name(global.levels[_i]));
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
    var _y = 250 + _j * 50;
    var _over = (_mx > 330 && _mx < 630 && _my > _y - 5 && _my < _y + 40);
    if (_over && _moved) sel = _j;
    if (_over && _click) {
        sel = _j;
        _clicked = true;
    }
}

sel = clamp(sel, 0, _n - 1);

if (_enter || _clicked) {
    if (screen == 0) {
        switch (sel) {
            case 0:
                // ไปหน้าเลือกระดับความยาก (เริ่มที่ระดับที่เลือกไว้ครั้งก่อน)
                screen = 4;
                sel = global.difficulty;
                break;
            case 1:
                screen = 1;
                break;
            case 2:
                screen = 2;
                break;
            case 3:
                if (instance_exists(obj_pause)) obj_pause.open_settings_menu();
                break;
            case 4:
                global.debug = !global.debug;
                if (global.debug) {
                    if (!instance_exists(obj_debug)) instance_create_depth(0, 0, -9500, obj_debug);
                } else {
                    global.god = false;
                    instance_destroy(obj_debug);
                }
                break;
            case 5:
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
            sel = 5;
        } else {
            game_reset();
            var _f2 = instance_create_depth(0, 0, -10000, obj_fade);
            _f2.target_room = global.levels[sel];
        }
    }
}