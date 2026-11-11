// ---------- เอฟเฟกต์ฟัน (เห็นตลอด) ----------
// ใส่ภาพจริงได้โดยสร้าง sprite ชื่อ spr_fx_slash (หมุนตามทิศฟัน ขนาดตามภาพ) ถ้าไม่มีจะวาดเส้นโค้งจากโค้ด
if (!is_undefined(step_data)) {
    var _af = step_data.active_from;
    var _at = step_data.active_to;
    var _life = max(1, _at - _af + 1);
    var _t = (age - _af) / _life;
    if (_t >= 0 && _t < 1.6) {
        var _spr = asset_get_index("spr_fx_slash");
        var _cx0 = x;
        var _cy0 = y - lift;
        if (_spr != -1 && sprite_exists(_spr)) {
            var _fr = clamp(floor(_t / 1.0 * sprite_get_number(_spr)), 0, sprite_get_number(_spr) - 1);
            draw_sprite_ext(_spr, _fr, _cx0, _cy0, 1, 1, image_angle, c_white, 1);
        } else {
            var _rout = 0;
            for (var _k = 0; _k < array_length(step_data.circles); _k++) {
                var _cc = step_data.circles[_k];
                _rout = max(_rout, point_distance(0, 0, _cc[0], _cc[1]) + _cc[2]);
            }
            _rout *= 0.95;
            var _rin = _rout * 0.55;
            var _dir = 1;
            if (instance_exists(owner) && variable_instance_exists(owner, "combo")) _dir = (owner.combo mod 2 == 1) ? 1 : -1;
            var _head = image_angle + _dir * (-70 + 140 * min(_t, 1));
            var _trail = 75;
            var _fade = 1 - max(0, _t - 1) / 0.6;
            draw_set_color(c_white);
            draw_primitive_begin(pr_trianglestrip);
            for (var _i = 0; _i <= 8; _i++) {
                var _a = _head - _dir * _trail * (_i / 8);
                var _al = (1 - _i / 8) * 0.8 * _fade;
                draw_vertex_color(_cx0 + lengthdir_x(_rout, _a), _cy0 + lengthdir_y(_rout, _a), c_white, _al);
                draw_vertex_color(_cx0 + lengthdir_x(_rin, _a), _cy0 + lengthdir_y(_rin, _a), c_white, 0);
            }
            draw_primitive_end();
        }
    }
}

// แสดงเฉพาะโหมด debug
if (!global.debug || !show_hitbox || is_undefined(step_data)) exit;

var _active = (age >= step_data.active_from && age <= step_data.active_to);
draw_set_alpha(_active ? 0.45 : 0.1);
draw_set_color(_active ? c_white : c_aqua);
for (var _i = 0; _i < array_length(step_data.circles); _i++) {
    var _c = step_data.circles[_i];
    var _cx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
    var _cy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90) - lift;
    draw_circle(round(_cx), round(_cy), _c[2], false);
}
draw_set_alpha(1);
draw_set_color(c_white);