// ★ ทางออกขอบฉาก: แสงจากทางข้างหน้า (แทนรูปประตู)
var _x1 = x - 40;
var _x2 = x + 104;
var _y1 = y - 80;
var _y2 = y + 140;
var _warm = locked ? c_gray : make_color_rgb(255, 235, 180);
var _pul = 0.75 + 0.25 * sin(current_time / 250);
gpu_set_blendmode(bm_add);
draw_primitive_begin(pr_trianglestrip);
draw_vertex_color(_x1, _y1, _warm, 0);
draw_vertex_color(_x1, _y2, _warm, 0);
draw_vertex_color(_x2, _y1, _warm, 0.55 * _pul);
draw_vertex_color(_x2, _y2, _warm, 0.55 * _pul);
draw_primitive_end();
gpu_set_blendmode(bm_normal);
// ลูกศรลอย + ชื่อพื้นที่ถัดไป
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var _bob = sin(current_time / 200) * 6;
var _ax = (_x1 + _x2) / 2 + _bob;
var _ay = _y1 - 10;
draw_set_color(locked ? c_gray : c_yellow);
draw_triangle(_ax + 14, _ay - 12, _ax - 6, _ay - 24, _ax - 6, _ay, false);
var _t = room_title(next_room);
if (locked) _t += L("  (ยังไปไม่ได้)", "  (locked)");
draw_set_color(c_black);
draw_text_transformed(_ax + 1, _ay - 27, _t, 0.6, 0.6, 0);
draw_set_color(locked ? c_ltgray : c_yellow);
draw_text_transformed(_ax, _ay - 28, _t, 0.6, 0.6, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// โหมด debug (F3): โชว์สถานะประตูเหนือประตู
if (global.debug) {
    // ★ ข้อความ debug ของประตู: สั้นลง และดันให้อยู่ในจอเสมอ (ประตูชิดขอบห้อง ข้อความเคยหลุดจอ)
    var _ov = place_meeting(x, y, obj_player_ss);
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam);
    var _vw = camera_get_view_width(_cam);
    var _dt = "locked=" + string(locked) + " req=" + req_flag
        + "\nnext=" + ((next_room == noone) ? "NONE" : room_get_name(next_room))
        + "\nsword=" + string(flag_get("sword")) + " overlap=" + string(_ov);
    draw_set_font(fnt_dialog);
    var _tw = string_width(_dt) * 0.45;
    var _tx = clamp(x - _tw / 2, _vx + 8, _vx + _vw - 8 - _tw);
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_tx - 4, y - 172, _tx + _tw + 4, y - 120, false);
    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_set_halign(fa_left);
    draw_text_transformed(_tx, y - 170, _dt, 0.45, 0.45, 0);
    draw_set_color(c_white);
    draw_rectangle_color(x - 40, y - 80, x + 104, y + 140, c_yellow, c_yellow, c_yellow, c_yellow, true);
}
