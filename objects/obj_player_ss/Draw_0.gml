var _a = (respawn_timer > 0 && (respawn_timer mod 8 < 4)) ? 0.35 : 1;
draw_sprite_ext(sprite_index, image_index, round(x), round(y), face * sc, sc, 0, c_white, _a);

// กด F1 ค้างเพื่อดูกล่องชน
if (keyboard_check(vk_f1)) {
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}