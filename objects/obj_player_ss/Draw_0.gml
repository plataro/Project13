var _a = (respawn_timer > 0 && (respawn_timer mod 8 < 4)) ? 0.35 : 1;
// ★ ท่าทางจากภาพนิ่ง: เดิน/วิ่ง = เด้ง + เอียง, กระโดด = ยืดตอนขึ้น หดตอนตก
var _bob = 0, _ang = 0, _sx = 1, _sy = 1;
switch (anim_state) {
    case "walk": _bob = abs(sin(anim_t)) * 4; _ang = sin(anim_t) * 5; break;
    case "run":  _bob = abs(sin(anim_t)) * 6; _ang = sin(anim_t) * 6 - 8 * face; break;
    case "jump":
        var _v = clamp(vsp / max(1, jump_speed), -1, 1);
        _sy = 1 - _v * 0.1; _sx = 1 + _v * 0.08; _ang = -_v * 6 * face;
        break;
    default: _sy = 1 + sin(current_time / 400) * 0.02; break;
}
draw_sprite_ext(sprite_index, 0, round(x), round(y - _bob), face * sc * _sx, sc * _sy, _ang, c_white, _a);

// ★ เอฟเฟกต์ฟันดาบ (โค้งครึ่งวงหน้าตัว)
if (atk_t > 0 && atk_t <= 13) {
    var _k = clamp(1 - (atk_t - 3) / 10, 0, 1);
    var _cx = x + face * 10;
    var _cy = y - 44;
    var _head = (face > 0) ? (80 - 150 * _k) : (100 + 150 * _k);
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= 8; _i++) {
        var _aa = _head + face * 70 * (_i / 8);
        var _al = (1 - _i / 8) * 0.8 * min(1, atk_t / 4);
        draw_vertex_color(_cx + lengthdir_x(70, _aa), _cy + lengthdir_y(70, _aa), c_white, _al);
        draw_vertex_color(_cx + lengthdir_x(36, _aa), _cy + lengthdir_y(36, _aa), c_white, 0);
    }
    draw_primitive_end();
}

// กด F1 ค้างเพื่อดูกล่องชน
if (keyboard_check(vk_f1)) {
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
	draw_text(bbox_left, bbox_top - 40, "grounded=" + string(grounded) + " vsp=" + string(vsp) + " hsp=" + string(hsp));
    draw_set_color(c_white);
}