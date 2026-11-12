t++;

if (shown_idx != idx && idx < array_length(slides)) {
    shown_idx = idx;
    wrapped = text_wrap_thai(slides[idx].text, 1150);
    chars = 0;
    total = string_length(wrapped);
    img_a = 0;
}

img_a = min(1, img_a + 0.03);

if (!closing) {
    black = max(0, black - 0.03);
    chars = min(total, chars + 0.7);

    var _ok = t > 25;   // กันกดค้างจากหน้าก่อนหน้า
    var _next = _ok && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left));
    if (_ok && keyboard_check_pressed(vk_escape)) closing = true;

    if (_next) {
        if (chars < total) chars = total;
        else {
            idx++;
            if (idx >= array_length(slides)) closing = true;
        }
    }
} else {
    black = min(1, black + 0.04);
    if (black >= 1) {
        var _cb = on_done;
        instance_destroy();
        if (is_callable(_cb)) _cb();
    }
}
