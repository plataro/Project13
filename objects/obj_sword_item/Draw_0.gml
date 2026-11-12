if (picked) {
    if (prompt_a > 0.02) prompt_a = 0;
    exit;
}

var _bob = sin(t / 25) * 4;
var _spr = asset_get_index("spr_sword_item");
if (_spr != -1 && sprite_exists(_spr)) {
    draw_sprite(_spr, 0, x, y + _bob);
} else {
    // placeholder: ดาบปักอยู่กับพื้น มีแสงเรือง
    var _g = 0.25 + 0.15 * sin(t / 12);
    draw_set_alpha(_g);
    draw_set_color(c_aqua);
    draw_circle(x, y - 40 + _bob, 46, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_line_width(x, y - 6 + _bob, x, y - 66 + _bob, 6);      // ใบดาบ
    draw_set_color(make_color_rgb(200, 160, 60));
    draw_line_width(x - 14, y - 16 + _bob, x + 14, y - 16 + _bob, 5);   // ด้ามกั้น
    draw_set_color(make_color_rgb(110, 70, 40));
    draw_line_width(x, y - 4 + _bob, x, y + 8, 5);               // ด้าม
    draw_set_color(c_white);
}

ui_prompt(x, y - 92, "E", L("หยิบดาบ", "Take sword"), prompt_a);
