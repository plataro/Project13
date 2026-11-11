if (story_key == "" || instance_exists(obj_dialogue) || instance_exists(obj_fade)) exit;

if (variable_struct_exists(global.story_seen, story_key)) {
    instance_destroy();
    exit;
}

if (auto_start || place_meeting(x, y, obj_player) || place_meeting(x, y, obj_player_ss)) {
    global.story_seen[$ story_key] = true;
    dialogue_start(story_lines(story_key));
}