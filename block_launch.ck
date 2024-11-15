@import {"gmenu.ck", "gplayer.ck", "gpad.ck", "gplatform.ck", "gstar.ck", "gplanet.ck"};
@import {"instrument.ck", "instruments/drum.ck", "instruments/arp.ck"};
@import {"keyboard.ck", "mouse.ck"};
@import "constants.ck";

// ================== constants defined by game designer ==================
Constants c;

// ================== variables that represent state of game ==================

// game state
-1 => int current_platform;     // the platform the player is currently standing on (-1 if player isn't on any platform)

// scroll params
-1 => int NONE_PARAM;
0 => int INSTRUMENT_PARAM;
1 => int TEMPO_PARAM;       // local tempo (playback rate)
2 => int BPM_PARAM;         // global bpm
3 => int NUM_PADS_PARAM;
4 => int GRAVITY_PARAM;
5 => int LAUNCH_PARAM;
6 => int CHESS_MODE_PARAM;

NONE_PARAM => int current_param;

// scroll param values
c.DEFAULT_TEMPO => float tempo;
// bpm handled for individual platforms
// num_pads handled for individual platforms
c.STARTING_GRAVITY_IDX => int gravity_idx;
// launch_force handled by accessing player member

// game modes
false => int chess_mode;
Envelope chess_mode_env => blackhole;
2::second => chess_mode_env.duration;

// ================== setting up scene ==================

@(0.0, 0.0, 0.0) => vec3 STARTING_PLAYER_POS;
20 => float PLATFORM_VERTICAL_SPACING;
30 => float PLATFORM_HORIZONTAL_SPACING;

GPlatform platforms[c.NUM_PLATFORMS];
Instrument instruments[c.NUM_PLATFORMS];

// Testing out the player class
GWindow.title("BLOCK LAUNCH");
Keyboard keyboard();
Mouse mouse(0);
spork ~ keyboard.self_update();
spork ~ mouse.self_update();

GMenu menu --> GG.scene();

GPlayer player(keyboard, mouse) --> GG.scene();
player.pos(STARTING_PLAYER_POS);


fun void create_instruments()
{
   
    1 => int drum_platform_idx;
    3 => int num_drum_platforms;

    for (drum_platform_idx => int i; i < drum_platform_idx + num_drum_platforms; i++)
    {
        Drum drum(i-drum_platform_idx) => dac;
        drum @=> instruments[i];
    }

    // Drum drum(4) => dac;
    // drum @=> instruments[3];

    Arp arp => dac;
    arp @=> instruments[0];
}


fun void setup_lighting()
{
    GG.scene().light().intensity(2);
}


fun void place_platforms()
{
    for (int i; i < c.NUM_PLATFORMS; i++)
    {
        GPlatform platform(player, instruments[i], c.STARTING_NUM_PADS[i]) --> GG.scene();
        platform.pos(@(0, PLATFORM_VERTICAL_SPACING*i, -PLATFORM_HORIZONTAL_SPACING*i));
        tempo => platform.bpm;
        platform @=> platforms[i];
    }
}

// gets the point at the center of all the platforms
fun vec3 get_center_pos()
{
    0 => float x;
    (PLATFORM_VERTICAL_SPACING * c.NUM_PLATFORMS-1)/2 => float y;
    -(PLATFORM_HORIZONTAL_SPACING * c.NUM_PLATFORMS-1)/2 => float z;
    return @(x, y, z);
}

fun void place_stars()
{
    140 => float x_range;
    x_range => float y_range;
    x_range => float z_range;

    get_center_pos() => vec3 offset;
    for (int i; i < c.NUM_STARS; i++)
    {
        Math.random2f(-x_range, x_range) => float x;
        Math.random2f(-y_range, y_range) => float y;
        Math.random2f(-z_range, z_range) => float z;
        @(x, y, z) => vec3 star_pos;
        
        GStar star() --> GG.scene();
        star.pos(star_pos + offset);
    }
}


GPlanet planet;
fun void place_planets()
{
    planet --> GG.scene();
    get_center_pos() => vec3 offset;
    offset.x - 250 => offset.x;
    planet.pos(offset);
}


fun void update_player_normal_force()
{
    true => int disable_player_normal_force;
    for (int i; i < c.NUM_PLATFORMS; i++)
    {
        // if floor i is directly under the player
        if (platforms[i].floor_under_player)
        {
            false => disable_player_normal_force;        // we don't want to turn off normal force
            i => current_platform;                       // we are currently on platform i
            break;                                       // break, since player can only be on platform i (can't be on multiple platforms)
        }
    }

    // if none of the floors are directly under the player
    if (disable_player_normal_force)
    {
        player.set_normal_force(false);     // turn off the normal force
        -1 => current_platform;             // we aren't currently on any platform
    }
}







// scroll parameters (changed with keypress+scroll)
// - T: tempo (bpm for all platforms)
// - B: bpm (for current platform)
// - N: num_pads (for current platform)
// - G: gravity (for player)
// - L: launch force
// float prev_scroll_delta;
fun void scroll_parameters()
{
    // select current parameter we would like to change
    if (keyboard.instrument_param) INSTRUMENT_PARAM => current_param;
    else if (keyboard.tempo_param) TEMPO_PARAM => current_param;
    else if (keyboard.bpm_param) BPM_PARAM => current_param;
    else if (keyboard.num_pads_param) NUM_PADS_PARAM => current_param;
    else if (keyboard.gravity_param) GRAVITY_PARAM => current_param;
    else if (keyboard.launch_param) LAUNCH_PARAM => current_param;

    // -------------- keyboard arrow controlls --------------

    0 => int direction;
    if (keyboard.increase_param) {
        1 => direction;
        false => keyboard.increase_param;
    }
    else if (keyboard.decrease_param) {
        -1 => direction;
        false => keyboard.decrease_param;
    }
    if (!direction) return;     // exit if we don't have a direction

    if (current_param == INSTRUMENT_PARAM)
    {
        <<< "Not implemented" >>>;
        // update_menu(INSTRUMENT_PARAM, 0);
    }
    else if (current_param == TEMPO_PARAM)
    {
        tempo + direction*c.TEMPO_PARAM_STEP => float new_tempo;
        Math.max(c.MIN_BPM, new_tempo) => new_tempo;
        Math.min(c.MAX_BPM, new_tempo) => tempo;
        planet.update_rotation_speed(tempo);
        sync_tempo();
        
        <<< "synced tempo to:", tempo >>>;
    }
    else if (current_param == BPM_PARAM)
    {
        if (current_platform != -1)
        {
            platforms[current_platform].bpm + direction*c.BPM_PARAM_STEP => float new_bpm;
            Math.max(c.MIN_BPM, new_bpm) => new_bpm;
            Math.min(c.MAX_BPM, new_bpm) => platforms[current_platform].bpm;
            <<< "set bpm to:", platforms[current_platform].bpm >>>;
        }
        
    }
    else if (current_param == NUM_PADS_PARAM)
    {
        if (current_platform != -1)
        {
            platforms[current_platform].num_pads + direction*c.NUM_PADS_PARAM_STEP => int new_num_pads;
            platforms[current_platform].update_num_pads(new_num_pads);
            <<< "set num pads to:", platforms[current_platform].num_pads >>>;
        }
    }
    else if (current_param == GRAVITY_PARAM)
    {
        (gravity_idx + direction) % c.GRAVITY_VALS.size() => gravity_idx;
        player.physics_object.set_gravity(c.GRAVITY_VALS[gravity_idx]);
        <<< "set gravity to:", c.GRAVITY_NAMES[gravity_idx] >>>;
    }
    else if (current_param == LAUNCH_PARAM)
    {
        player.launch_force + direction*c.LAUNCH_PARAM_STEP => float new_launch_force;
        Math.max(c.MIN_LAUNCH_FORCE, new_launch_force) => new_launch_force;
        Math.min(c.MAX_LAUNCH_FORCE, new_launch_force) => player.launch_force;
        <<< "set launch force to:", player.launch_force >>>;
    }

    if (direction != 0) // if we updated a parameter
    {
        spork ~ display_menu_action(current_param, direction);
    }
}


// updates all platforms to the current tempo (global bpm)
fun void sync_tempo()
{
    for (int i; i < c.NUM_PLATFORMS; i++)
    {
        tempo => platforms[i].bpm;
    }
}


// keyboard toggles
// - R: resync platforms (start at beat 0)
// - C: toggle chess mode
// - E: toggle menu (shows status / scroll parameters)
fun void keyboard_toggles()
{
    if (keyboard.toggle_resync) spork ~ toggle_resync();
    if (keyboard.toggle_chess_mode) spork ~ toggle_chess_mode();
    if (keyboard.toggle_menu) spork ~ toggle_menu();

    // future idea: add toggles (number keys 1-4) for teleporting to each platform
}


// perform resync of beats across all platforms
fun toggle_resync()
{
    for (int i; i < c.NUM_PLATFORMS; i++)
    {
        if (platforms[i].beat_is_active)
        {
            platforms[i].pads[platforms[i].current_beat].stop(50::ms);
            false => platforms[i].beat_is_active;
        }
        platforms[i].num_pads => platforms[i].current_beat;         // resets current beat to 0 for all platforms (since for loop exits) :)))
        <<< "toggling resync" >>>;
    }
    false => keyboard.toggle_resync;

    // displays action to player
    "resynced!" => menu.most_recent_action;
    menu.display_action();
}


// switch in or out of chess mode
fun void toggle_chess_mode()
{
    false => keyboard.toggle_chess_mode;
    if (!chess_mode) Math.PI/4 => chess_mode_env.target;
    else 0 => chess_mode_env.target;
    !chess_mode => chess_mode;      // flip our gamemode

    // <<< "current rotation target:", chess_mode_env.target() >>>;

    while (chess_mode_env.target() != chess_mode_env.value())
    {
        for (int i; i < c.NUM_PLATFORMS; i++)
        {
            for (int j; j < platforms[i].num_pads; j++)
            {
                platforms[i].pads[j].rotY(chess_mode_env.value());
            }
        }
        10::ms => now;
    }
    // display_menu_action(CHESS_MODE_PARAM, 0);        // don't display action, looks better imo
}


fun void toggle_menu()
{
    false => keyboard.toggle_menu;
    menu.toggle_status();
    <<< "menu toggled" >>>;

    // "toggled status display" => menu.most_recent_action;
    // menu.display_action();
}


// loops over all statuses and gets latest info for menu
fun void update_menu_status()
{
    for (int param; param < c.NUM_STATUS_PARAMS; param++)
    {
        get_status_string(param) => menu.status_strs[param];
    }
    menu.refresh_status();
}


// sends a new action string to the menu (pops up on screen)
fun void display_menu_action(int param, int direction)
{
    // 1. direction string
    "updated " => string direction_str;
    if (direction == -1) "decreased " => direction_str;
    if (direction == 1) "increased " => direction_str;

    // 2. get status string (current value for status of given param)
    get_status_string(param) => string status_str;

    // 3. set full most_recent_action string
    c.STATUS_PREFIX[param] + status_str => menu.most_recent_action;     // not including direction for now

    // 4. refresh action
    menu.display_action();
}


// given a parameter enum, returns the associated status string 
// - e.g. given GRAVITY_PARAM, returns "EARTH", if we are currently using earth gravity
fun string get_status_string(int param)
{
    string status_str;
    if (param == INSTRUMENT_PARAM)
    {
        if (current_platform == -1) c.UNKNOWN_STR => status_str;
        else {
            platforms[current_platform].instrument.get_name() => status_str;
        }
    }
    else if (param == TEMPO_PARAM) Std.itoa(tempo $ int) => status_str;
    else if (param == BPM_PARAM)
    {
        if (current_platform == -1) c.UNKNOWN_STR => status_str;
        else {
            Std.itoa(platforms[current_platform].bpm $ int) => status_str;
        }
    }
    else if (param == NUM_PADS_PARAM)
    {
        if (current_platform == -1) c.UNKNOWN_STR => status_str;
        else {
            Std.itoa(platforms[current_platform].num_pads $ int) => status_str;
        }
    }
    else if (param == GRAVITY_PARAM) c.GRAVITY_NAMES[gravity_idx] => status_str;
    else if (param == LAUNCH_PARAM) Std.itoa(player.launch_force $ int) => status_str;
    else if (param == CHESS_MODE_PARAM)
    {
        "ON" => status_str;
        if (!chess_mode) "OFF" => status_str;
    }

    return status_str;
}




fun void update_state()
{
    update_player_normal_force();
    scroll_parameters();
    keyboard_toggles();
    
}



fun void play_background_music()
{
    "sounds/background/background.wav" => string BACKGROUND_MUSIC_WAV;
    SndBuf background_music => dac;
    true => background_music.loop;
    5 => background_music.gain;
    background_music.read(BACKGROUND_MUSIC_WAV);
    while (true)
    {
        background_music.length() => now;
    }
}


fun void setup()
{
    // set up instruments
    create_instruments();

    // set up scene
    setup_lighting();
    place_platforms();
    place_stars();
    place_planets();
}



setup();
spork ~ play_background_music();
while(true)
{
    // next graphics frame
    GG.nextFrame() => now;

    update_state();
    update_menu_status();       // update menu to reflect our changes to the state
}
