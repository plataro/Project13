var _on = place_meeting(x, y, obj_player_ss) || place_meeting(x, y, obj_crate_ss);
pressed = _on || (latch && pressed);
image_blend = pressed ? c_lime : c_gray;