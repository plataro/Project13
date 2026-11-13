ui_sound_watch(sel, screen);   // ★ เสียงเลื่อน/เลือกเมนู
if (instance_exists(obj_fade)) exit;
if (instance_exists(obj_pause) && obj_pause.open) exit;   // หน้าตั้งค่าเปิดทับอยู่

// ★ เปิดเกมครั้งแรก: ถามภาษาก่อน
if (!global.lang_chosen && screen == 0) { screen = 5; sel = (global.lang == "en") ? 1 : 0; }
// ★ เปลี่ยนภาษาแล้ว ข้อความเซฟต้องสร้างใหม่
if (save_lang != global.lang) {
    save_lang = global.lang;
    if (has_save) save_text = save_summary();
}

// ★ ปุ่ม Debug: สี่เหลี่ยมมุมขวาบน (แยกจากรายการเมนู)
if (SHOW_DEBUG_MENU && mouse_check_button_pressed(mb_left)
    && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), dbg_btn[0], dbg_btn[1], dbg_btn[2], dbg_btn[3])) {
    global.debug = !global.debug;
    if (global.debug) {
        if (!instance_exists(obj_debug)) instance_create_depth(0, 0, -9500, obj_debug);
    } else {
        global.god = false;
        instance_destroy(obj_debug);
        if (screen == 3) { screen = 0; sel = 0; }
    }
    exit;
}

var _enter = input_ui_confirm();   // ★ Enter / Space / จอย A
var _click = mouse_check_button_pressed(mb_left);
var _back = input_ui_back();

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
    if (has_save) { array_push(items, L("เล่นต่อ", "Continue")); array_push(acts, "continue"); }
    array_push(items, has_save ? L("เริ่มเกมใหม่", "New Game") : L("เริ่มเกม", "Start Game")); array_push(acts, "new");
    array_push(items, L("วิธีเล่น", "How to Play"));  array_push(acts, "howto");
    array_push(items, L("เครดิต", "Credits"));    array_push(acts, "credits");
    array_push(items, L("ตั้งค่า", "Settings"));    array_push(acts, "settings");
    if (global.debug) { array_push(items, L("เลือกฉาก", "Scene Select")); array_push(acts, "scenes"); }
} else if (screen == 4) {
    items = [difficulty_data(0).name, difficulty_data(1).name, difficulty_data(2).name, L("กลับ", "Back")];
} else if (screen == 5) {
    items = ["ภาษาไทย", "English"];
} else {
    items = [];
    for (var _i = 0; _i < array_length(global.levels); _i++) {
        var _rt = room_title(global.levels[_i]);
        array_push(items, (_rt != "") ? _rt : room_get_name(global.levels[_i]));
    }
    array_push(items, L("กลับ", "Back"));
}

var _n = array_length(items);

if (input_ui_down()) sel = (sel + 1) mod _n;
if (input_ui_up()) sel = (sel - 1 + _n) mod _n;

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
                    msg = L("โหลดเซฟไม่ได้ (ไฟล์เสีย)", "Couldn't load save (file is corrupted)");
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
    } else if (screen == 5) {
        lang_set((sel == 1) ? "en" : "th");
        screen = 0;
        sel = 0;
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