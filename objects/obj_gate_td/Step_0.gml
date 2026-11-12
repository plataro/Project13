if (!opening) {
    var _total = 0;
    var _hit = 0;
    var _ch = channel;
    with (obj_target) {
        if (channel == _ch) {
            _total++;
            if (hit) _hit++;
        }
    }
    if (_total > 0 && _hit >= _total) {
        opening = true;
        float_text(x + sprite_width / 2, y - 20, L("ทางเปิดแล้ว!", "The way is open!"), make_color_rgb(150, 255, 150), 1.2);
        fx_shake(3);
    }
} else {
    open_t++;
    if (open_t >= 30) {
        global.fog_room = -1;   // ให้หมอกคำนวณกำแพงใหม่
        instance_destroy();
    }
}
