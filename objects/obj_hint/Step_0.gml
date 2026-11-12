t++;

if (hkey != "" && variable_struct_exists(global.story_seen, hkey)) {
    instance_destroy();
    exit;
}

var _p = instance_exists(obj_player) ? instance_find(obj_player, 0) : instance_find(obj_player_ss, 0);
var _near = false;
if (_p != noone) _near = point_distance(x, y, _p.x, _p.y) < radius;
if (instance_exists(obj_dialogue) || instance_exists(obj_cutscene) || instance_exists(obj_fade)) _near = false;
if (hide_flag != "" && flag_get(hide_flag)) _near = false;
if (req != "" && !variable_struct_exists(global.story_seen, req)) _near = false;

// ต้องกดครบทุกปุ่มที่โชว์ ปุ่มที่กดแล้วจะเปลี่ยนเป็นสีเขียว (เก็บใน items[i].g[j])
if (_near && !done && a > 0.6) {
    var _total = 0;
    var _have = 0;
    for (var _i = 0; _i < array_length(items); _i++) {
        var _it = items[_i];
        if (!variable_struct_exists(_it, "c")) continue;
        if (!variable_struct_exists(_it, "g")) _it.g = array_create(array_length(_it.c), false);
        for (var _j = 0; _j < array_length(_it.c); _j++) {
            var _code = _it.c[_j];
            var _hit = false;
            if (_code == -1) _hit = mouse_check_button_pressed(mb_left);
            else if (_code == -2) _hit = mouse_wheel_up() || mouse_wheel_down();
            else _hit = keyboard_check_pressed(_code);
            if (_hit) _it.g[_j] = true;
            _total++;
            if (_it.g[_j]) _have++;
        }
    }
    if (_total > 0 && _have >= _total) done = true;
}

if (done) {
    done_t++;
    _near = (done_t < 40);   // โชว์เครื่องหมายถูกแป๊บหนึ่ง แล้วจางหาย
    if (done_t >= 40 && a < 0.03) {
        if (hkey != "") global.story_seen[$ hkey] = true;
        instance_destroy();
        exit;
    }
}

a = lerp(a, _near ? 1 : 0, 0.12);
