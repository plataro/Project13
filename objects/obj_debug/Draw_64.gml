if (!show) exit;

draw_set_font(fnt_dialog);
draw_set_color(c_lime);
var _s = "DEBUG  Z:heal  X:god(" + (global.god ? "ON" : "OFF") + ")  C:kill all  V/B:room  N:menu  H:hide";
draw_text_transformed(10, 512, _s, 0.6, 0.6, 0);
draw_set_color(c_white);