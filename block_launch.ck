
@import {"keyboard.ck", "mouse.ck", "gplayer.ck", "gpad.ck", "gplatform.ck", "instrument.ck", "gstar.ck"}

// ================== constants defined by game designer ==================

4 => int NUM_PLATFORMS;   // number of tracks/individual step sequencers
400 => int NUM_STARS;

2::second => dur CAMERA_MODE_SWITCH_DUR;


// ================== variables that represent state of game ==================

// camera mode
Envelope camera_mode => blackhole;
CAMERA_MODE_SWITCH_DUR => camera_mode.duration;
0 => camera_mode.value;
0.0 => float FIRST_PERSON;
1.0 => float THIRD_PERSON;

120 => int bpm;
-1 => int current_platform;

// scroll params
0 => int NONE_PARAM;
1 => int TEMPO_PARAM;       // global bpm
2 => int BPM_PARAM;         // local bpm
3 => int NUM_PADS_PARAM;

NONE_PARAM => int current_param;

// game modes
false => int chess_mode;
Envelope chess_mode_env => blackhole;
2::second => chess_mode_env.duration;

// ================== setting up scene ==================

@(0.0, 0.0, 0.0) => vec3 STARTING_PLAYER_POS;
20 => float PLATFORM_VERTICAL_SPACING;
30 => float PLATFORM_HORIZONTAL_SPACING;

GPlatform platforms[NUM_PLATFORMS];
Instrument instruments[NUM_PLATFORMS];

// Testing out the player class
GWindow.title("BLOCK LAUNCH");
Keyboard keyboard();
Mouse mouse(0);
spork ~ keyboard.self_update();
spork ~ mouse.self_update();

GPlayer player(keyboard, mouse) --> GG.scene();
player.pos(STARTING_PLAYER_POS);


// thanks Tristan
class Snare extends Instrument {  
    inlet => Noise n => BPF f => ADSR e => outlet;
    440 => f.freq;
    15. => f.Q;
    15 => f.gain;
    e.set(5::ms, 50::ms, 0.1, 50::ms);

    fun void play() {
        e.keyOn();
        // <<< "PLAYING NOTE" >>>;
        50::ms => now;
        e.keyOff();
        e.releaseTime() => now;
    }
}

class Kick extends Instrument { 
    inlet => Noise n => LPF f => ADSR e => outlet;
    110 => f.freq;
    40 => f.gain;
    e.set(5::ms, 50::ms, 0.1, 100::ms);

    fun void play() {
        e.keyOn();
        50::ms => now;
        e.keyOff();
        e.releaseTime() => now;
    }
}


fun void create_instruments()
{
    Kick kick => dac;
    kick @=> instruments[0];

    Snare snare => dac;
    snare @=> instruments[1];

}


fun void place_platforms()
{
    for (int i; i < NUM_PLATFORMS; i++)
    {
        GPlatform platform(player, instruments[i]) --> GG.scene();
        platform.pos(@(0, PLATFORM_VERTICAL_SPACING*i, -PLATFORM_HORIZONTAL_SPACING*i));
        bpm => platform.bpm;
        platform @=> platforms[i];
    }
}


fun void place_stars()
{
    // 2 => float expand;
    // (PLATFORM_VERTICAL_SPACING * NUM_PLATFORMS) * expand => float y_range;
    // (PLATFORM_HORIZONTAL_SPACING * NUM_PLATFORMS) * expand => float z_range;
    // z_range => float x_range;

    140 => float x_range;
    x_range => float y_range;
    x_range => float z_range;


    0 => float x_offset;
    (PLATFORM_VERTICAL_SPACING * NUM_PLATFORMS)/2 => float y_offset;
    -(PLATFORM_HORIZONTAL_SPACING * NUM_PLATFORMS)/2 => float z_offset;

    
    for (int i; i < NUM_STARS; i++)
    {
        Math.random2f(-x_range, x_range) => float x;
        Math.random2f(-y_range, y_range) => float y;
        Math.random2f(-z_range, z_range) => float z;
        @(x, y, z) => vec3 star_pos;
        @(x_offset, y_offset, z_offset) => vec3 offset;

        GStar star --> GG.scene();
        star.pos(star_pos + offset);

        <<< "placed star at", star_pos + offset >>>;
    }
}


fun void update_player_normal_force()
{
    true => int disable_player_normal_force;
    for (int i; i < NUM_PLATFORMS; i++)
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





fun void update_bpm()
{
    for (int i; i < NUM_PLATFORMS; i++)
    {
        bpm => platforms[i].bpm;
    }
}

// scroll parameters (changed with keypress+scroll)
// - T: tempo (bpm for all platforms)
// - B: bpm (for current platform)
// - N: num_pads (for current platform)
// - G: gravity (for player)
// - L: launch force
fun void scroll_parameters()
{
    // select current parameter we would like to change
    if (keyboard.bpm_param) BPM_PARAM => current_param;
    else if (keyboard.num_pads_param) NUM_PADS_PARAM => current_param;


    // update the selected parameter if scroll is detected
    mouse.scrollDelta() => float scroll_delta;
    // <<< "scroll delta:", scroll_delta >>>;
    if (scroll_delta)
    {
        if (current_param == BPM_PARAM) bpm + 1 => bpm;
        else if (current_param == NUM_PADS_PARAM)
        {
            if (current_platform != -1)
            {
                1 +=> platforms[current_platform].num_pads;
            }
            
        }
        
        // platforms[current_platform]
    }
}


fun void keyboard_toggles()
{
    if (keyboard.resync) spork ~ resync_platforms();
    if (keyboard.chess_mode) spork ~ toggle_chess_mode();
}


// perform resync of beats
fun resync_platforms()
{
    for (int i; i < NUM_PLATFORMS; i++)
    {
        // platforms[i].pads[platforms[i].current_beat].play(50::ms);
        platforms[i].pads[platforms[i].current_beat].stop(50::ms);
        0 => platforms[i].current_beat;         // set current beat to 0 for all platforms :)))
    }
    false => keyboard.resync;
}


// switch in or out of chess mode
fun void toggle_chess_mode()
{
    false => keyboard.chess_mode;
    if (!chess_mode) Math.PI/4 => chess_mode_env.target;
    else 0 => chess_mode_env.target;
    !chess_mode => chess_mode;      // flip our gamemode

    
    <<< "current rotation target:", chess_mode_env.target() >>>;

    while (chess_mode_env.target() != chess_mode_env.value())
    {
        for (int i; i < NUM_PLATFORMS; i++)
        {
            for (int j; j < platforms[i].num_pads; j++)
            {
                platforms[i].pads[j].rotY(chess_mode_env.value());
            }
        }
        10::ms => now;
    }

}



fun void update_state()
{
    update_player_normal_force();
    scroll_parameters();
    keyboard_toggles();
}

fun void update_text()
{
    // update global bpm
    // update local bpm text
}


//add the suzanne
// @(1, 0, 0) => vec3 MONKEY_COLOR;       // Red
// GSuzanne monkey --> GG.scene();
// monkey.sca(1.5);
// monkey.color(MONKEY_COLOR);


fun void setup()
{
    GG.scene().light().intensity(2);
    create_instruments();
    place_platforms();
    place_stars();
}


// for testing purposes
fun void decrease_pads()
{
    while (true)
    {
        if (current_platform != -1)
        {
            platforms[current_platform].num_pads - 1 => int new_num_pads;
            <<< "decreasing to", new_num_pads, " pads" >>>;
            platforms[current_platform].update_num_pads(new_num_pads);
        }
        5::second => now;
    }
}
// spork ~ decrease_pads();



setup();
while(true)
{
    // next graphics frame
    GG.nextFrame() => now;

    update_state();
    update_text();
    // <<< "current_platform:", current_platform >>>;
    
    // <<< "world scale:", monkey.scaWorld() >>>;
    // <<< "local scale:", monkey.sca() >>>;
    // <<< "eye pos:", player.eye.pos() >>>;
    // <<< "crosshair pos:", player.crosshair.pos() >>>;
}
