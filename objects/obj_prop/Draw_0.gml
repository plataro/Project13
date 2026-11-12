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

    // =================================================================
    // ★ ของตกแต่งฉาก side-scroll (วาดหลังฉาก ตั้ง depth = 100 ใน Creation Code)
    // (x, y) = จุดฐานบนพื้น ยกเว้นหน้าต่าง/ธง/โซ่ = จุดบน
    // =================================================================
    case "column": {   // เสาหินสูง h
        var _cw = 46;
        draw_set_color(make_color_rgb(72, 68, 76));
        draw_rectangle(x - _cw / 2, y - h, x + _cw / 2, y, false);
        draw_set_color(make_color_rgb(92, 88, 98));
        draw_rectangle(x - _cw / 2 + 6, y - h, x - _cw / 2 + 14, y, false);
        draw_set_color(make_color_rgb(60, 56, 64));
        draw_rectangle(x - _cw / 2 - 10, y - h, x + _cw / 2 + 10, y - h + 22, false);   // หัวเสา
        draw_rectangle(x - _cw / 2 - 8, y - 18, x + _cw / 2 + 8, y, false);            // ฐาน
        break;
    }
    case "window": {   // หน้าต่างโค้ง + ลำแสงส่องลงพื้น
        var _ww = 70;
        var _wh = 150;
        draw_set_color(make_color_rgb(50, 46, 56));
        draw_rectangle(x - _ww / 2 - 8, y, x + _ww / 2 + 8, y + _wh + 8, false);
        draw_circle(x, y, _ww / 2 + 8, false);
        draw_set_color(make_color_rgb(120, 150, 190));
        draw_rectangle(x - _ww / 2, y, x + _ww / 2, y + _wh, false);
        draw_circle(x, y, _ww / 2, false);
        draw_set_color(make_color_rgb(50, 46, 56));
        draw_rectangle(x - 3, y - _ww / 2, x + 3, y + _wh, false);
        draw_rectangle(x - _ww / 2, y + _wh * 0.45, x + _ww / 2, y + _wh * 0.45 + 5, false);
        // ลำแสง
        gpu_set_blendmode(bm_add);
        var _la = 0.07 + 0.02 * sin(current_time / 900 + seed);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(x - _ww / 2, y + _wh, make_color_rgb(255, 230, 170), _la);
        draw_vertex_color(x + _ww / 2, y + _wh, make_color_rgb(255, 230, 170), _la);
        draw_vertex_color(x - _ww / 2 + 120, y + _wh + h, make_color_rgb(255, 230, 170), 0);
        draw_vertex_color(x + _ww / 2 + 220, y + _wh + h, make_color_rgb(255, 230, 170), 0);
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        break;
    }
    case "torch": {    // คบเพลิงติดผนัง ไฟกะพริบ
        draw_set_color(make_color_rgb(70, 50, 35));
        draw_rectangle(x - 4, y - 30, x + 4, y, false);
        draw_rectangle(x - 10, y - 34, x + 10, y - 28, false);
        var _fl = 1 + 0.15 * sin(current_time / 70 + seed) + 0.1 * sin(current_time / 33 + seed);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.18);
        draw_set_color(make_color_rgb(255, 150, 60));
        draw_circle(x, y - 44, 70 * _fl, false);
        draw_set_alpha(0.9);
        draw_set_color(make_color_rgb(255, 140, 40));
        draw_ellipse(x - 9 * _fl, y - 62 * _fl, x + 9 * _fl, y - 32, false);
        draw_set_color(make_color_rgb(255, 230, 140));
        draw_ellipse(x - 4, y - 50 * _fl, x + 4, y - 34, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        break;
    }
    case "banner": {   // ธงแขวน แกว่งเบา ๆ
        var _bw = 54;
        var _bh = 170;
        var _sway = sin(current_time / 800 + seed) * 6;
        var _bc = (tint == c_white) ? make_color_rgb(130, 30, 35) : tint;
        draw_set_color(make_color_rgb(90, 70, 40));
        draw_rectangle(x - _bw / 2 - 8, y - 4, x + _bw / 2 + 8, y + 4, false);
        draw_set_color(_bc);
        draw_triangle(x - _bw / 2, y, x + _bw / 2, y, x - _bw / 2 + _sway, y + _bh, false);
        draw_triangle(x + _bw / 2, y, x + _bw / 2 + _sway, y + _bh, x - _bw / 2 + _sway, y + _bh, false);
        draw_set_color(make_color_rgb(200, 160, 70));
        draw_circle(x + _sway * 0.5, y + _bh * 0.4, 10, false);
        break;
    }
    case "statue": {   // รูปปั้นนักรบบนแท่น
        draw_set_color(make_color_rgb(70, 66, 74));
        draw_rectangle(x - 34, y - 40, x + 34, y, false);
        draw_set_color(make_color_rgb(110, 106, 112));
        draw_rectangle(x - 16, y - 150, x + 16, y - 40, false);   // ลำตัว
        draw_circle(x, y - 165, 15, false);                       // หัว
        draw_rectangle(x + 16, y - 140, x + 24, y - 80, false);   // แขน
        draw_set_color(make_color_rgb(140, 136, 140));
        draw_rectangle(x + 22, y - 200, x + 27, y - 70, false);   // ดาบชี้ขึ้น
        break;
    }
    case "altar": {    // แท่นวางดาบ
        draw_set_color(make_color_rgb(95, 90, 100));
        draw_rectangle(x - 44, y - 24, x + 44, y, false);
        draw_set_color(make_color_rgb(130, 125, 135));
        draw_rectangle(x - 52, y - 32, x + 52, y - 24, false);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.15 + 0.08 * sin(current_time / 400));
        draw_set_color(make_color_rgb(150, 200, 255));
        draw_circle(x, y - 60, 60, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        break;
    }
    case "chain": {    // โซ่ห้อยจากเพดาน ยาว h
        draw_set_color(make_color_rgb(80, 80, 88));
        for (var _cy = 0; _cy < h; _cy += 14) {
            draw_ellipse(x - 4 + sin(current_time / 1000 + seed + _cy) * 1.5, y + _cy, x + 4, y + _cy + 12, true);
        }
        break;
    }
    case "rubble": {   // กองหินพัง
        draw_set_color(make_color_rgb(75, 70, 72));
        draw_ellipse(x - 40, y - 22, x + 10, y, false);
        draw_ellipse(x - 10, y - 30, x + 40, y, false);
        draw_set_color(make_color_rgb(95, 90, 92));
        draw_ellipse(x - 20, y - 40, x + 12, y - 14, false);
        break;
    }
    case "railing": {  // ราวกั้นขอบชั้นบน (กำแพงจริงเป็น obj_ground_ss ที่ซ่อนไว้)
        draw_set_color(make_color_rgb(100, 90, 80));
        draw_rectangle(x, y - 70, x + 32, y - 62, false);
        for (var _rx = x + 4; _rx < x + 32; _rx += 10) draw_rectangle(_rx, y - 62, _rx + 3, y, false);
        break;
    }

    // ===== ★ ของในร้าน (side-scroll) =====
    case "shelf": {    // ชั้นวางของติดผนัง (x, y) = ฐาน
        draw_set_color(make_color_rgb(90, 60, 38));
        draw_rectangle(x - 90, y - 220, x + 90, y, false);
        draw_set_color(make_color_rgb(60, 40, 26));
        draw_rectangle(x - 82, y - 212, x + 82, y - 8, false);
        for (var _sh = 0; _sh < 3; _sh++) {
            var _sy = y - 70 - _sh * 66;
            draw_set_color(make_color_rgb(120, 85, 52));
            draw_rectangle(x - 86, _sy, x + 86, _sy + 8, false);
            // ของบนชั้น (ขวด / กล่อง) สีสุ่มตาม seed
            for (var _it = 0; _it < 5; _it++) {
                var _ix = x - 66 + _it * 33;
                var _c = make_color_hsv((seed * 37 + _sh * 50 + _it * 23) mod 255, 140, 200);
                draw_set_color(_c);
                if ((_it + _sh + seed) mod 2 == 0) { draw_rectangle(_ix - 7, _sy - 26, _ix + 7, _sy, false); draw_rectangle(_ix - 3, _sy - 32, _ix + 3, _sy - 26, false); }
                else draw_rectangle(_ix - 11, _sy - 18, _ix + 11, _sy, false);
            }
        }
        break;
    }
    case "counter": {  // เคาน์เตอร์ร้าน กว้าง h (ใช้ h เป็นความกว้าง)
        var _cw2 = h;
        draw_set_color(make_color_rgb(110, 75, 45));
        draw_rectangle(x - _cw2 / 2, y - 80, x + _cw2 / 2, y, false);
        draw_set_color(make_color_rgb(145, 100, 60));
        draw_rectangle(x - _cw2 / 2 - 10, y - 90, x + _cw2 / 2 + 10, y - 78, false);
        draw_set_color(make_color_rgb(90, 60, 36));
        for (var _pl = x - _cw2 / 2 + 30; _pl < x + _cw2 / 2; _pl += 60) draw_rectangle(_pl, y - 70, _pl + 4, y - 6, false);
        break;
    }
    case "lamp": {     // โคมแขวน (x, y) = จุดแขวนบนเพดาน
        draw_set_color(make_color_rgb(70, 60, 50));
        draw_line_width(x, y, x, y + 60, 2);
        draw_set_color(make_color_rgb(120, 90, 50));
        draw_rectangle(x - 14, y + 60, x + 14, y + 84, false);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.2 + 0.05 * sin(current_time / 200 + seed));
        draw_set_color(make_color_rgb(255, 190, 110));
        draw_circle(x, y + 74, 90, false);
        draw_set_alpha(0.9);
        draw_set_color(make_color_rgb(255, 220, 140));
        draw_rectangle(x - 9, y + 64, x + 9, y + 80, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
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
