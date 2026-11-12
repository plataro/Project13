switch (kind) {
    // ===== วิหาร (ทางออกจากฉาก sanctuary สู่ป่า) จุด (x, y) = ธรณีประตู =====
    case "sanctuary": {
        var _w = 300;
        var _h = 230;
        var _l = x - _w / 2;
        var _t = y - _h;
        var _stone = make_color_rgb(150, 145, 135);
        var _dark = make_color_rgb(95, 92, 88);
        // เงา
        draw_set_alpha(0.3);
        draw_set_color(c_black);
        draw_ellipse(_l - 10, y - 14, _l + _w + 10, y + 18, false);
        draw_set_alpha(1);
        // ตัวอาคาร
        draw_set_color(_dark);
        draw_rectangle(_l, _t, _l + _w, y, false);
        draw_set_color(_stone);
        draw_rectangle(_l + 6, _t + 6, _l + _w - 6, y - 4, false);
        // หลังคาจั่ว
        draw_set_color(make_color_rgb(120, 80, 60));
        draw_triangle(_l - 24, _t + 10, _l + _w + 24, _t + 10, x, _t - 80, false);
        draw_set_color(make_color_rgb(150, 105, 75));
        draw_triangle(_l - 6, _t + 4, _l + _w + 6, _t + 4, x, _t - 62, false);
        // เสา 4 ต้น
        draw_set_color(make_color_rgb(200, 195, 185));
        for (var _i = 0; _i < 4; _i++) {
            var _px = _l + 24 + _i * ((_w - 48) / 3);
            draw_rectangle(_px - 11, _t + 24, _px + 11, y - 10, false);
            draw_rectangle(_px - 16, _t + 16, _px + 16, _t + 26, false);
        }
        // ประตูโค้งมืด (ที่ผู้เล่นเพิ่งเดินออกมา)
        draw_set_color(make_color_rgb(25, 22, 30));
        draw_rectangle(x - 34, y - 110, x + 34, y - 6, false);
        draw_circle(x, y - 110, 34, false);
        // แสงเรืองจากข้างใน
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.25 + 0.1 * sin(current_time / 300));
        draw_set_color(make_color_rgb(255, 210, 120));
        draw_circle(x, y - 60, 30, false);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        // บันไดหน้าประตู
        draw_set_color(make_color_rgb(175, 170, 160));
        draw_rectangle(x - 60, y - 6, x + 60, y + 4, false);
        draw_rectangle(x - 76, y + 4, x + 76, y + 14, false);
        break;
    }

    // ===== ป้ายไม้ =====
    case "sign": {
        draw_set_color(make_color_rgb(110, 75, 40));
        draw_rectangle(x - 3, y - 40, x + 3, y, false);
        draw_set_color(make_color_rgb(160, 115, 65));
        draw_rectangle(x - 26, y - 56, x + 26, y - 34, false);
        break;
    }
}
draw_set_color(c_white);
