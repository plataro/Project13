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

if (_near && !done) {
    for (var _i = 0; _i < array_length(watch); _i++) {
        var _w = watch[_i];
        var _hit = (_w < 0) ? mouse_check_button_pressed(mb_left) : keyboard_check_pressed(_w);
        if (_hit && a > 0.6) done = true;
    }
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
