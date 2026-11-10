if (phase == 0) {
    alpha += 0.05;
    if (alpha >= 1) {
        alpha = 1;
        room_goto(target_room);
        phase = 1;
    }
} else {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}