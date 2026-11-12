draw_shadow(x, y, 22, 8);

var _body = make_color_rgb(110, 70, 140);
if (shop_type == "smith") _body = make_color_rgb(190, 100, 40);
if (shop_type == "buyer") _body = make_color_rgb(60, 150, 100);
if (shop_type == "jeweler") _body = make_color_rgb(60, 160, 190);
if (shop_type == "alchemist") _body = make_color_rgb(150, 60, 160);
draw_set_color(_body);
draw_rectangle(round(x) - 18, round(y) - 70, round(x) + 18, round(y) - 6, false);
draw_set_color(make_color_rgb(235, 200, 160));
draw_circle(round(x), round(y) - 82, 14, false);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(round(x), round(y) - 112, shop_name, 0.6, 0.6, 0);
if (!variable_instance_exists(id, "pr_a")) pr_a = 0;
pr_a = lerp(pr_a, (near && !instance_exists(obj_shop)) ? 1 : 0, 0.2);
ui_prompt(round(x), round(y) - 124, "E", (room == rm_shop_ss) ? "ซื้อขาย" : "เข้าร้าน", pr_a);

draw_set_halign(fa_left);
draw_set_color(c_white);