if (!carved) exit;

// ทางเดินดินยาวไปจนขอบฉาก
var _c1 = make_color_rgb(120, 95, 60);
draw_set_alpha(0.45);
draw_set_color(_c1);
draw_rectangle(corr[0], corr[1], corr[2], corr[3], false);
draw_set_alpha(1);

// ลูกศรเลื่อนไปทางขอบ
var _ang = side * 90;
var _len = (side == 0 || side == 2) ? (corr[2] - corr[0]) : (corr[3] - corr[1]);
var _cx = (corr[0] + corr[2]) / 2;
var _cy = (corr[1] + corr[3]) / 2;
var _off = (current_time / 20) mod 60;
draw_set_color(locked ? c_gray : make_color_rgb(255, 230, 150));
for (var _i = -_len / 2; _i < _len / 2; _i += 60) {
    var _d = _i + _off;
    if (abs(_d) > _len / 2 - 20) continue;
    var _ax = _cx + lengthdir_x(_d, _ang);
    var _ay = _cy + lengthdir_y(_d, _ang);
    draw_set_alpha(0.35 * (1 - abs(_d) / (_len / 2)) + 0.15);
    draw_triangle(_ax + lengthdir_x(14, _ang), _ay + lengthdir_y(14, _ang),
                  _ax + lengthdir_x(10, _ang + 130), _ay + lengthdir_y(10, _ang + 130),
                  _ax + lengthdir_x(10, _ang - 130), _ay + lengthdir_y(10, _ang - 130), false);
}

// ความมืดไล่ไปทางขอบ = ทางยังไปต่ออีก
var _fl = 220;
draw_primitive_begin(pr_trianglestrip);
switch (side) {
    case 0:
        draw_vertex_color(corr[2] - _fl, corr[1], c_black, 0); draw_vertex_color(corr[2] - _fl, corr[3], c_black, 0);
        draw_vertex_color(corr[2], corr[1], c_black, 0.9);     draw_vertex_color(corr[2], corr[3], c_black, 0.9);
        break;
    case 2:
        draw_vertex_color(corr[0] + _fl, corr[1], c_black, 0); draw_vertex_color(corr[0] + _fl, corr[3], c_black, 0);
        draw_vertex_color(corr[0], corr[1], c_black, 0.9);     draw_vertex_color(corr[0], corr[3], c_black, 0.9);
        break;
    case 1:
        draw_vertex_color(corr[0], corr[1] + _fl, c_black, 0); draw_vertex_color(corr[2], corr[1] + _fl, c_black, 0);
        draw_vertex_color(corr[0], corr[1], c_black, 0.9);     draw_vertex_color(corr[2], corr[1], c_black, 0.9);
        break;
    default:
        draw_vertex_color(corr[0], corr[3] - _fl, c_black, 0); draw_vertex_color(corr[2], corr[3] - _fl, c_black, 0);
        draw_vertex_color(corr[0], corr[3], c_black, 0.9);     draw_vertex_color(corr[2], corr[3], c_black, 0.9);
        break;
}
draw_primitive_end();
draw_set_alpha(1);

// หินกั้นตอนล็อก
if (instance_exists(blocker)) {
    with (blocker) {
        draw_set_color(make_color_rgb(90, 85, 80));
        draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
        draw_set_color(make_color_rgb(130, 125, 118));
        draw_rectangle(bbox_left + 6, bbox_top + 6, bbox_right - 6, bbox_bottom - 6, false);
    }
}

// ป้ายบอกทาง
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var _txt = room_title(next_room) + ((lock_msg != "") ? ("  (" + lock_msg + ")") : "");
var _sx = x;
var _sy = y - 70;
if (_txt != "") {
    draw_set_color(c_black);
    draw_text_transformed(_sx + 1, _sy + 1, _txt, 0.6, 0.6, 0);
    draw_set_color(locked ? c_ltgray : c_yellow);
    draw_text_transformed(_sx, _sy, _txt, 0.6, 0.6, 0);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
