// ★ เคยเปิดแล้ว (จำไว้ในเซฟ) = ไม่ต้องทำปริศนาซ้ำ
var _gkey = "gate_" + room_get_name(room) + "_" + string(channel);
if (!checked) {
    checked = true;
    if (variable_struct_exists(global.story_seen, _gkey)) {
        var _ch0 = channel;
        with (obj_target) if (channel == _ch0) { hit = true; locked_open = true; }
        global.fog_room = -1;
        instance_destroy();
        exit;
    }
}
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
        sfx_at("gate", x + sprite_width / 2, y);
        global.story_seen[$ _gkey] = true;   // ★ จำว่าเปิดแล้ว (เซฟอัตโนมัติผ่าน obj_tutorial)
        var _ch1 = channel;
        with (obj_target) if (channel == _ch1) locked_open = true;
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
