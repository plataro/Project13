// ===== หมอกมืดนอกสายตา (วาดหลังฉากทั้งหมด ก่อน GUI) =====
// เปิดเฉพาะด่านที่มีกำแพงบังสายตา
if (room != rm_level_1_the_forest && room != rm_level_2_the_abandoned_mine && room != rm_level_3_the_castle) exit;
if (!variable_global_exists("fog_surf")) global.fog_surf = -1;

var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

if (!surface_exists(global.fog_surf) || surface_get_width(global.fog_surf) != _vw || surface_get_height(global.fog_surf) != _vh) {
    if (surface_exists(global.fog_surf)) surface_free(global.fog_surf);
    global.fog_surf = surface_create(_vw, _vh);
}

var _fog_dark = 0.88;     // ★ ความมืดของโซนที่มองไม่เห็น (0-1)
var _rays = 160;          // ★ จำนวนเรย์ (มาก = ขอบเนียนแต่หนัก)
var _radius = 720;        // ★ ระยะมองไกลสุด

var _px = x;
var _py = y - 32;

surface_set_target(global.fog_surf);
draw_clear_alpha(c_black, _fog_dark);
gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);   // โหมด "ลบความมืด" ตามค่า alpha ของจุด

// คำนวณจุดปลายของแต่ละเรย์ครั้งเดียว
var _ex = array_create(_rays + 1);
var _ey = array_create(_rays + 1);
var _ed = array_create(_rays + 1);
for (var _i = 0; _i <= _rays; _i++) {
    var _a = (_i / _rays) * 360;
    var _tx = _px + lengthdir_x(_radius, _a);
    var _ty = _py + lengthdir_y(_radius, _a);
    var _h = collision_line_point(_px, _py, _tx, _ty, obj_wall, false, true);
    if (_h.id != noone) {
        _ex[_i] = _h.x;
        _ey[_i] = _h.y;
        _ed[_i] = point_distance(_px, _py, _h.x, _h.y);
    } else {
        _ex[_i] = _tx;
        _ey[_i] = _ty;
        _ed[_i] = _radius;
    }
}

// ชั้นนอก: ขอบนุ่ม (ยื่นออกไปอีกนิด สว่างครึ่งเดียว)
// ชั้นใน: พื้นที่เห็นจริง สว่างเต็มที่ ค่อย ๆ มืดลงตามระยะ
for (var _pass = 0; _pass < 2; _pass++) {
    var _ext = (_pass == 0) ? 22 : 4;
    var _mul = (_pass == 0) ? 0.5 : 1;
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_px - _vx, _py - _vy, c_white, _mul);
    for (var _i = 0; _i <= _rays; _i++) {
        var _a2 = (_i / _rays) * 360;
        var _d = _ed[_i];
        var _dx = _ex[_i] + lengthdir_x(_ext, _a2);
        var _dy = _ey[_i] + lengthdir_y(_ext, _a2);
        var _t = _d / _radius;
        var _al = (1 - 0.9 * _t * _t) * _mul;
        draw_vertex_color(_dx - _vx, _dy - _vy, c_white, _al);
    }
    draw_primitive_end();
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(global.fog_surf, _vx, _vy);
