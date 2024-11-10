@import {"gplayer.ck", "raycaster.ck"}

// class structure adapted from Andrew Zhu Azaday's drum_machine.ck
public class GPad extends GGen
{
    // initialize mesh
    GCube pad --> this;
    PhongMaterial mat;
    pad.mat(mat);

    // height scaling
    0.1 => static float NEUTRAL_SCA;
    0.5 => static float HOVER_SCA;
    9 => static float PLAYING_SCA;
    pad.scaY(NEUTRAL_SCA);
    Envelope pad_sca_env => blackhole;
    NEUTRAL_SCA => pad_sca_env.value;

    // crosshair scaling
    Envelope crosshair_sca_env => blackhole;
    GPlayer.NEUTRAL_CROSSHAIR_SCA => crosshair_sca_env.value;

    // reference to player
    GPlayer @ player;
    RayCaster @ rc;

    // reference to a camera (should be the player's eyes)
    GG.scene().camera() @=> GCamera @ cam;

    // states
    0 => static int NONE;
    1 => static int HOVERED;
    2 => static int ACTIVE;
    3 => static int PLAYING;
    NONE => int state;     // current state
    NONE => int last_state;

    // player state
    NONE => int player_state;


    // input types
    0 => static int MOUSE_HOVER;
    1 => static int MOUSE_EXIT;
    2 => static int MOUSE_CLICK;
    3 => static int NOTE_ON;
    4 => static int NOTE_OFF;
    5 => static int PLAYER_HOVER;
    6 => static int PLAYER_EXIT;

    // other constants
    12 => float CLICK_RANGE;      // the range from which a player can click a pad (i.e. how long is the ray we cast from the camera)

    // false => int enabled;
    // int track_num;
    // int step_num;

    // color map
    [
        Color.WHITE,            // NONE
        @(0.5, 0.5, 0.5),    // HOVERED
        // Color.WHITE,
        @(0, 0.9, 0),           // ACTIVE
        @(1, 0, 0),             // PLAYING
    ] @=> vec3 color_map[];

    // @(0, 0.9, 0) => vec3 PLAYER_HOVER_COLOR;
    @(0.5, 0.5, 0.5) => vec3 PLAYER_HOVER_COLOR;
    @(1, 0.3, 0) => vec3 PLAYER_LAUNCH_COLOR;

    // constructor
    fun GPad(GPlayer @ gp)
    {
        if (player != null) return;      // if this GPad already has a player, reject trying to overwrite it
        gp @=> this.player;
        new RayCaster(player) @=> rc;

        spork ~ this.click_listener();
    }

    // check if state is active (i.e. should play sound)
    fun int active()
    {
        return state == ACTIVE;
    }

    // set color
    fun void color(vec3 c)
    {
        mat.color(c);
    }

    fun int is_hovered()
    {
        return rc.in_vision_center(pad, this.rotY(), CLICK_RANGE);               // use ray casting to determine if the player is looking at pad (max distance of CLICK_RANGE)
    }

    // true if the pad under the player (at the appropriate height)
    fun int is_under_player()
    {
        return rc.under_player(pad, this.rotY());
    }

    // poll for hover events
    fun void poll_hover()
    {
        if (is_hovered())
        {
            handle_input(MOUSE_HOVER);
            if (state != PLAYING) do_animation(MOUSE_HOVER, 100::ms);
            
        }
        else
        {
            if (state == HOVERED || state == ACTIVE)
            {
                handle_input(MOUSE_EXIT);
                do_animation(MOUSE_EXIT, 100::ms);
            }

        }        
    }

    // poll for player hover (standing on pad)
    fun void poll_player_hover()
    {
        if (is_under_player())
        {
            handle_input(PLAYER_HOVER);
            // if (state != PLAYING) do_animation(PLAYER_HOVER, 100::ms);
        }
        else
        {
            if (player_state == HOVERED)
            {
                handle_input(PLAYER_EXIT);
                // do_animation(PLAYER_EXIT, 100::ms);
            }
        }
    }

    

    // handle mouse clicks
    fun void click_listener()
    {
        while (true) {
            GG.nextFrame() => now;
            if (GWindow.mouseLeftDown() && is_hovered()) {
                handle_input(MOUSE_CLICK);
            }
        }
    }

    // animation when playing
    // set juice = true to animate
    fun void play(dur animation_dur)
    {
        handle_input(NOTE_ON);
        if (last_state == ACTIVE)
        {
            do_animation(NOTE_ON, animation_dur);
            // <<< "Player state:", player_state >>>;
            if (player_state == HOVERED)
            {
                player.launch();
                <<< "LAUNCH!!" >>>;
            }

        }
        
        // r_env.target;
        // g_env.target;
        // b_env.target;
    }

    // stop play animation (called by sequencer on note off)
    fun void stop(dur animation_dur)
    {
        handle_input(NOTE_OFF);
        do_animation(NOTE_OFF, animation_dur);
        // animation_dur => pad_sca_env.duration;
        // NEUTRAL_SCA => pad_sca_env.target;
        
    }

    // activate pad, meaning it should be played when the sequencer hits it
    fun void activate()
    {
        enter(ACTIVE);
    }


    // enter state, remember last state
    fun void enter(int s)
    {
        state => last_state;
        s => state;
        // uncomment to randomize color when playing
        // if (state == PLAYING) Color.random() => colorMap[PLAYING];
    }

    fun void do_animation(int input, dur animation_dur)
    {
        if (input == NOTE_ON)
        {
            animation_dur => pad_sca_env.duration;
            PLAYING_SCA => pad_sca_env.target;
        }
        if (input == NOTE_OFF)
        {
            animation_dur => pad_sca_env.duration;
            NEUTRAL_SCA => pad_sca_env.target;
        }
        if (input == MOUSE_HOVER)
        {
            animation_dur => pad_sca_env.duration;
            HOVER_SCA => pad_sca_env.target;

            animation_dur => crosshair_sca_env.duration;
            GPlayer.HOVER_CROSSHAIR_SCA => crosshair_sca_env.target;
        }
        if (input == MOUSE_EXIT)
        {
            animation_dur => pad_sca_env.duration;
            NEUTRAL_SCA => pad_sca_env.target;

            animation_dur => crosshair_sca_env.duration;
            GPlayer.NEUTRAL_CROSSHAIR_SCA => crosshair_sca_env.target;
        }
        if (input == PLAYER_HOVER)
        {
            animation_dur => pad_sca_env.duration;
            HOVER_SCA => pad_sca_env.target;
        }
        if (input == PLAYER_EXIT)
        {
            animation_dur => pad_sca_env.duration;
            NEUTRAL_SCA => pad_sca_env.target;
        }
    }

    // basic state machine for handling input
    fun void handle_input(int input)
    {
        // ---- update pad state ----
        if (input == NOTE_ON) {
            enter(PLAYING);
            return;
        }

        if (input == NOTE_OFF) {
            enter(last_state);
            return;
        }

        if (state == NONE) {
            if (input == MOUSE_HOVER)      enter(HOVERED);
            // else if (input == MOUSE_CLICK) enter(ACTIVE);
        } else if (state == HOVERED) {
            if (input == MOUSE_EXIT)       enter(NONE);
            else if (input == MOUSE_CLICK) enter(ACTIVE);
        } else if (state == ACTIVE) {
            if (input == MOUSE_CLICK)      enter(NONE);
        } else if (state == PLAYING) {
            // if (input == MOUSE_CLICK && last_state == NONE)      enter(ACTIVE);
            if (input == MOUSE_CLICK) enter(NONE);
            if (input == NOTE_OFF)         enter(ACTIVE);
        }


        // ---- update player state ----
        if (player_state == NONE) {
            if (input == PLAYER_HOVER) HOVERED => player_state;
        }
        else if (player_state == HOVERED) {
            if (input == PLAYER_EXIT) NONE => player_state;
        }
    }

    // override ggen update
    // "very few get to project their complexity onto works of art as signifant [as Liget]" from 
    fun void update(float dt) {
        // check if hovered
        poll_hover();

        // check if player is standing on pad
        poll_player_hover();

        // update color of pad
        if (player_state == HOVERED)
        {
            if (state == ACTIVE) this.color(PLAYER_LAUNCH_COLOR);
            if (state == NONE || state == HOVERED) this.color(PLAYER_HOVER_COLOR);
        }
        else this.color(color_map[state]);

        // update scale of pad
        pad.scaY(pad_sca_env.value());
        
    }
}