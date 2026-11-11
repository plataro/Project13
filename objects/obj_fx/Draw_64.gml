// วาบแดงที่ขอบจอตอนผู้เล่นโดนตี
if (global.hurt_flash > 0.01) {
    var _a = global.hurt_flash * 0.55;
    var _w = 120;
    var _c = make_color_rgb(220, 20, 20);
    draw_primitive_begin(pr_trianglestrip);   // บน
    draw_vertex_color(0, 0, _c, _a); draw_vertex_color(960, 0, _c, _a);
    draw_vertex_color(0, _w, _c, 0); draw_vertex_color(960, _w, _c, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // ล่าง
    draw_vertex_color(0, 540, _c, _a); draw_vertex_color(960, 540, _c, _a);
    draw_vertex_color(0, 540 - _w, _c, 0); draw_vertex_color(960, 540 - _w, _c, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // ซ้าย
    draw_vertex_color(0, 0, _c, _a); draw_vertex_color(0, 540, _c, _a);
    draw_vertex_color(_w, 0, _c, 0); draw_vertex_color(_w, 540, _c, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // ขวา
    draw_vertex_color(960, 0, _c, _a); draw_vertex_color(960, 540, _c, _a);
    draw_vertex_color(960 - _w, 0, _c, 0); draw_vertex_color(960 - _w, 540, _c, 0);
    draw_primitive_end();
}