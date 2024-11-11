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
    0 => float MIN_BPM;
    2000 => float MAX_BPM;

    [EARTH_G, MOON_G, ZERO_G, JUPITER_G] @=> float GRAVITY_VALS[];
    ["EARTH", "MOON", "ZERO G", "JUPITER"] @=> string GRAVITY_NAMES[];

    2000 => float MIN_LAUNCH_FORCE;
    8000 => float MAX_LAUNCH_FORCE;

    // scroll param step sizes
    5 => float TEMPO_PARAM_STEP;
    5 => float BPM_PARAM_STEP;
    1 => int NUM_PADS_PARAM_STEP;       // must be integer (can't increase num_pads by half a pad..)
    500 => float LAUNCH_PARAM_STEP;


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
    // TODO: migrate constants

    // --------------------- gpad.ck ---------------------
    // TODO: migrate constants, as long as this doesn't cause performance issues (each pad would have constants object.. might not be a big deal though..)

}