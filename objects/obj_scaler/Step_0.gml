if (os_browser == browser_not_a_browser) exit;   // ทำเฉพาะตอนรันในเบราว์เซอร์

if (browser_width != last_bw || browser_height != last_bh) {
    last_bw = browser_width;
    last_bh = browser_height;

    var _aspect = base_w / base_h;
    var _w = last_bw;
    var _h = last_bh;
    if (_w / _h > _aspect) _w = _h * _aspect;
    else _h = _w / _aspect;

    window_set_size(max(320, floor(_w)), max(180, floor(_h)));
    window_center();
}
