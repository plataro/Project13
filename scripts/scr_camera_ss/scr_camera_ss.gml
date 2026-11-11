function scr_camera_ss(_tx, _ty, _face) {
    var _cam = view_camera[0];
    var _cw = camera_get_view_width(_cam);
    var _ch = camera_get_view_height(_cam);

    var _gx = _tx - _cw / 2 + _face * 60;   // มองนำไปทางที่หัน
    var _gy = _ty - _ch / 2;

    if (!global.ss_cam_ready) {
        global.ss_cam_x = _gx;
        global.ss_cam_y = _gy;
        global.ss_cam_ready = true;
    } else {
        global.ss_cam_x = lerp(global.ss_cam_x, _gx, 0.12);
        global.ss_cam_y = lerp(global.ss_cam_y, _gy, 0.12);
    }

    var _cx = clamp(floor(global.ss_cam_x), 0, max(0, room_width - _cw));
    var _cy = clamp(floor(global.ss_cam_y), 0, max(0, room_height - _ch));
    camera_set_view_pos(_cam, _cx, _cy);
}