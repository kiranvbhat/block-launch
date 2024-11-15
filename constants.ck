// gameplay constants (for initial game state, some of these values may change)
public class Constants
{
    // --------------------- physics_object.ck ---------------------
    // different gravities for fun
    9.80665 => float EARTH_G;
    1.625 => float MOON_G;
    0 => float ZERO_G;
    24.79 => float JUPITER_G;

    // different fluid densities
    0.1225 => float AIR_DENSITY;

    // different drag coefficients
    0.5 => float SPHERE_DRAG_COEFFICIENT;
    0.8 => float CUBE_DRAG_COEFFICIENT;


    // --------------------- block_launch.ck ---------------------
    // platforms
    4 => int NUM_PLATFORMS;   // number of tracks/individual step sequencers
    [16, 16, 16, 16] @=> int STARTING_NUM_PADS[];    // starting number of pads on each platform (for initializing platforms)

    // stars
    400 => int NUM_STARS;

    // scroll param limits
    5 => float MIN_BPM;
    2000 => float MAX_BPM;

    [EARTH_G, MOON_G, ZERO_G, JUPITER_G] @=> float GRAVITY_VALS[];
    ["EARTH", "MOON", "ZERO G", "JUPITER"] @=> string GRAVITY_NAMES[];

    2000 => float MIN_LAUNCH_FORCE;
    17000 => float MAX_LAUNCH_FORCE;

    // scroll param step sizes
    5 => float TEMPO_PARAM_STEP;
    5 => float BPM_PARAM_STEP;
    1 => int NUM_PADS_PARAM_STEP;       // must be integer (can't increase num_pads by half a pad..)
    1000 => float LAUNCH_PARAM_STEP;

    // starting scroll param vals
    120 => float DEFAULT_TEMPO;
    0 => int STARTING_GRAVITY_IDX;


    // --------------------- gplayer.ck ---------------------
    // player movement
    40 => float PLAYER_SPEED;      // how much force is applied to player when running
    450 => float JUMP_FORCE;
    true => int ALLOW_MIDAIR_JUMP;
    MIN_LAUNCH_FORCE => float STARTING_LAUNCH_FORCE;

    // eyes
    @(0.0, 1.8, 0.0) => vec3 STARTING_EYES_POS;     // where the player's eyes are (relative to the player's position)
    100 + 100 => float FIRST_PERSON_CLIP_FAR;
    0.785398 + 0.6 => float FIRST_PERSON_FOV;
    Math.PI/1.2 => float MAX_FOV;
    2::second => dur CAMERA_MODE_SWITCH_DUR;

    // crosshair
    @(0, 0, -0.4) => vec3 STARTING_CROSSHAIR_POS;
    0.005 => float NEUTRAL_CROSSHAIR_SCA;
    0.02 => float HOVER_CROSSHAIR_SCA;
    0.003 => float CLICK_CROSSHAIR_SCA;
    
    // physics
    1 => float MASS;
    EARTH_G => float GRAVITY;
    2 => float MU_K;
    AIR_DENSITY => float FLUID_DENSITY;
    CUBE_DRAG_COEFFICIENT => float C_D;
    0.01 => float SURFACE_AREA;


    // --------------------- gplatform.ck ---------------------

    // constants for platform layout
    0.7 => float PAD_SIZE;      // must be within [0, 1]
    8 => float PLATFORM_PADDING;        // the padding between the edge of the platform and the pads
    4 => int MAX_PADS_IN_ROW;
    16 => int MAX_NUM_PADS;

    20 => int PLATFORM_SCALE;
    @(0.1, 0.1, 0.1) => vec3 PLATFORM_COLOR;

    20::ms => dur TICK_DUR;     // notes are played tick by tick to check for interruptions (e.g. a resync)


    // --------------------- gpad.ck ---------------------
    // hopefully this doesn't cause performance issues (since each pad now has constants object)

    0.1 => float NEUTRAL_PAD_SCA;
    0.5 => float HOVER_PAD_SCA;
    9 => float PLAYING_PAD_SCA;

    // other constants
    12 => float CLICK_RANGE;      // the range from which a player can click a pad (i.e. how long is the ray we cast from the camera)

    // color maps
    [
        Color.WHITE,            // NONE
        @(0.5, 0.5, 0.5),       // HOVERED
        @(0, 0.9, 0),           // ACTIVE
        @(1, 0, 0),             // PLAYING
    ] @=> vec3 PAD_STATE_COLOR_MAP[];                          // color of pad when state is [STATE]

    [
        @(0.5, 0.5, 0.5),       // NONE
        @(0.5, 0.5, 0.5),       // HOVERED
        @(1, 0.3, 0),           // ACTIVE (launch warning color)
        @(1, 0, 0),             // PLAYING
    ] @=> vec3 PLAYER_HOVER_COLOR_MAP[];                        // color of pad when player is hovering and state is [STATE]


    // --------------------- gmenu.ck ---------------------
    
    // status
    7 => int NUM_STATUS_PARAMS;
    0.27 => float STATUS_POS_X;       // pos for fullscreen
    0.17 => float STATUS_POS_Y;       // pos for fullscreen
    0.016 => float STATUS_SCALE;
    1 => float STATUS_SPACING;        // vertical text spacing
    
    "(I) instrument: " => string INSTRUMENT_PREFIX;
    "(T) tempo: " => string TEMPO_PREFIX;
    "(B) bpm: " => string BPM_PREFIX;
    "(N) number of pads: " => string NUM_PADS_PREFIX;
    "(G) gravity: " => string GRAVITY_PREFIX;
    "(L) launch force: " => string LAUNCH_FORCE_PREFIX;
    "(C) chess mode: " => string CHESS_MODE_PREFIX;
    [INSTRUMENT_PREFIX, TEMPO_PREFIX, BPM_PREFIX, NUM_PADS_PREFIX, GRAVITY_PREFIX, LAUNCH_FORCE_PREFIX, CHESS_MODE_PREFIX] @=> string STATUS_PREFIX[];

    "(E) status display" => string STATUS_DISPLAY_PREFIX;

    // action
    0.05 => float ACTION_SCALE;
    2::second => dur ACTION_LIFESPAN;

    // overall menu
    -0.3 => float MENU_POS_Z;
    1792 => float FULLSCREEN_WIDTH;
    1120 => float FULLSCREEN_HEIGHT;
    3000::ms => dur TITLE_ENV_DUR;
    300::ms => dur TEXT_ENV_DUR;
    "???" => string UNKNOWN_STR;


    // --------------------- gplanet.ck ---------------------

    @(0, 1, 0.4) => vec3 PLANET_ROTATION_AXIS;
    0.0005 => float PLANET_ROTATE_AMOUNT;       // how many radians the planet rotates around axis in a frame
    4 => float PLANET_ROTATION_EXP;      // exponent in exponential growth of rotation speed with tempo
    200 => float PLANET_SCALE;


    // --------------------- gstar.ck ---------------------
    // wastes memory (since each star would now have constants object), so I'm leaving constants within the file


    // --------------------- mouse.ck ---------------------
    0 => int MOUSE_DEVICE;
    0.002 => float MOUSE_SENSITIVITY;

}