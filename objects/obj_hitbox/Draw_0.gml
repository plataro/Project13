// ---------- เอฟเฟกต์ฟัน (เห็นตลอด) ----------
// ท่า 1-2 = ฟันโค้ง (ใส่ภาพจริงได้โดยสร้าง sprite ชื่อ spr_fx_slash), ท่า 3 = แทงตรง, ท่า 4 = หมุนรอบตัว
if (!is_undefined(step_data)) {
    var _af = step_data.active_from;
    var _at = step_data.active_to;
    var _life = max(1, _at - _af + 1);
    var _t = (age - _af) / _life;
    var _kind = variable_struct_exists(step_data, "kind") ? step_data.kind : "slash";

    if (_t >= 0 && _t < 1.6) {
        var _cx0 = x;
        var _cy0 = y - lift;
        var _fade = 1 - max(0, _t - 1) / 0.6;

        // ระยะไกลสุดของวงโจมตี (ใช้กำหนดขนาดเอฟเฟกต์ ปรับตามอาวุธ/สกิลอัตโนมัติ)
        var _rout = 0;
        for (var _k = 0; _k < array_length(step_data.circles); _k++) {
            var _cc = step_data.circles[_k];
            _rout = max(_rout, point_distance(0, 0, _cc[0], _cc[1]) + _cc[2]);
        }

        switch (_kind) {

            // ===== ท่า 3: แทงพุ่งตรง =====
            case "thrust": {
                var _e = 1 - power(1 - min(_t / 0.35, 1), 3);   // พุ่งออกเร็วแล้วค้าง
                var _r0 = 18;
                var _tip = _r0 + (_rout - _r0) * _e;
                var _fx = lengthdir_x(1, image_angle);
                var _fy = lengthdir_y(1, image_angle);
                var _sx = lengthdir_x(1, image_angle + 90);
                var _sy = lengthdir_y(1, image_angle + 90);
                var _bw = 13 * (1 - 0.4 * min(_t, 1));          // โคนกว้าง ค่อย ๆ บางลง
                var _mid = _r0 + (_tip - _r0) * 0.72;          // ช่วงกว้างสุดของคม

                draw_primitive_begin(pr_trianglelist);
                // ตัวคม: โคน -> กลาง (กว้าง) -> ปลายแหลม
                var _bx = _cx0 + _fx * _r0;
                var _by = _cy0 + _fy * _r0;
                var _mx = _cx0 + _fx * _mid;
                var _my = _cy0 + _fy * _mid;
                var _tx = _cx0 + _fx * _tip;
                var _ty = _cy0 + _fy * _tip;
                var _a1 = 0.85 * _fade;
                draw_vertex_color(_bx, _by, c_white, 0);
                draw_vertex_color(_mx + _sx * _bw, _my + _sy * _bw, c_white, _a1 * 0.6);
                draw_vertex_color(_mx - _sx * _bw, _my - _sy * _bw, c_white, _a1 * 0.6);
                draw_vertex_color(_mx + _sx * _bw, _my + _sy * _bw, c_white, _a1 * 0.6);
                draw_vertex_color(_mx - _sx * _bw, _my - _sy * _bw, c_white, _a1 * 0.6);
                draw_vertex_color(_tx, _ty, c_white, _a1);
                // แกนกลางสว่าง
                var _cw = _bw * 0.3;
                draw_vertex_color(_bx, _by, c_white, 0);
                draw_vertex_color(_mx + _sx * _cw, _my + _sy * _cw, c_white, _a1);
                draw_vertex_color(_tx, _ty, c_white, _a1);
                draw_vertex_color(_bx, _by, c_white, 0);
                draw_vertex_color(_mx - _sx * _cw, _my - _sy * _cw, c_white, _a1);
                draw_vertex_color(_tx, _ty, c_white, _a1);
                draw_primitive_end();

                // เส้นความเร็วข้าง ๆ วิ่งไปข้างหน้า
                draw_set_color(c_white);
                for (var _l = -1; _l <= 1; _l += 2) {
                    var _off = _l * (_bw + 9);
                    var _l1 = _r0 + (_tip - _r0) * (0.25 + 0.35 * min(_t, 1));
                    var _l2 = _l1 + (_tip - _r0) * 0.35;
                    draw_set_alpha(0.5 * _fade);
                    draw_line_width(_cx0 + _fx * _l1 + _sx * _off, _cy0 + _fy * _l1 + _sy * _off,
                                    _cx0 + _fx * _l2 + _sx * _off, _cy0 + _fy * _l2 + _sy * _off, 2);
                }
                draw_set_alpha(1);
                break;
            }

            // ===== ท่า 4: หมุนรอบตัว =====
            case "spin": {
                var _ro = _rout * 0.92;
                var _ri = _ro * 0.5;
                var _e2 = 1 - power(1 - min(_t, 1), 2);
                var _head = image_angle + 400 * _e2;           // หมุนเกินรอบนิดนึง
                var _trail = 210;
                var _seg = 18;

                draw_primitive_begin(pr_trianglestrip);
                for (var _i = 0; _i <= _seg; _i++) {
                    var _a = _head - _trail * (_i / _seg);
                    var _al = (1 - _i / _seg) * 0.85 * _fade;
                    draw_vertex_color(_cx0 + lengthdir_x(_ro, _a), _cy0 + lengthdir_y(_ro, _a), c_white, _al);
                    draw_vertex_color(_cx0 + lengthdir_x(_ri, _a), _cy0 + lengthdir_y(_ri, _a), c_white, 0);
                }
                draw_primitive_end();

                // วงแรงกระแทกขยายออกตอนเริ่ม
                if (_t < 0.5) {
                    var _rr = _ro * (0.6 + 0.5 * (_t / 0.5));
                    draw_set_color(c_white);
                    draw_set_alpha(0.5 * (1 - _t / 0.5));
                    draw_circle(_cx0, _cy0, _rr, true);
                    draw_circle(_cx0, _cy0, _rr - 1, true);
                    draw_set_alpha(1);
                }
                break;
            }

            // ===== ท่า 1-2: ฟันโค้ง =====
            default: {
                var _spr = asset_get_index("spr_fx_slash");
                if (_spr != -1 && sprite_exists(_spr)) {
                    var _fr = clamp(floor(_t * sprite_get_number(_spr)), 0, sprite_get_number(_spr) - 1);
                    draw_sprite_ext(_spr, _fr, _cx0, _cy0, 1, 1, image_angle, c_white, 1);
                } else {
                    var _ro2 = _rout * 0.95;
                    var _ri2 = _ro2 * 0.55;
                    var _dir = 1;
                    if (instance_exists(owner) && variable_instance_exists(owner, "combo")) _dir = (owner.combo mod 2 == 1) ? 1 : -1;
                    var _hd = image_angle + _dir * (-70 + 140 * min(_t, 1));
                    var _tr = 75;
                    draw_primitive_begin(pr_trianglestrip);
                    for (var _j = 0; _j <= 8; _j++) {
                        var _aa = _hd - _dir * _tr * (_j / 8);
                        var _al2 = (1 - _j / 8) * 0.8 * _fade;
                        draw_vertex_color(_cx0 + lengthdir_x(_ro2, _aa), _cy0 + lengthdir_y(_ro2, _aa), c_white, _al2);
                        draw_vertex_color(_cx0 + lengthdir_x(_ri2, _aa), _cy0 + lengthdir_y(_ri2, _aa), c_white, 0);
                    }
                    draw_primitive_end();
                }
                break;
            }
        }
        draw_set_color(c_white);
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