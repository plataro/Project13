// เลื่อนเข้า/จางเข้าของรูปตัวละคร
var _sides = ["left", "right"];
for (var _i = 0; _i < 2; _i++) {
    var _s = slots[$ _sides[_i]];
    _s.ax = lerp(_s.ax, 0, 0.2);
    _s.alpha = lerp(_s.alpha, (_s.who != "") ? 1 : 0, 0.2);
}

var _next = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"));

if (chars < total) {
    chars += type_speed;
    if (_next) chars = total;
} else if (_next) {
    index++;
    if (index >= array_length(lines)) instance_destroy();
    else load_line();
}