if (spr < 0) exit;
var _n = sprite_get_number(spr);
var _f = min(floor(t * anim_fps / 60), _n - 1);
draw_sprite_ext(spr, _f, round(x), round(y), dscale, dscale, 0, col, alpha);
