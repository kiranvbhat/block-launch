@import {"keyboard.ck", "mouse.ck", "physics_object.ck"};

public class GPlayer extends GGen
{
    // ----- initialize mesh -----
    0.4 => float foot_separation;
    @(0.2, 0.4, 0.5) => vec3 foot_scale;

    GSphere left_foot --> this;
    left_foot.sca(foot_scale);
    left_foot.color(Color.BLACK);
    left_foot.pos(@(-foot_separation, 0.2, 0.5));

    GSphere right_foot --> this;
    right_foot.sca(foot_scale);
    right_foot.color(Color.BLACK);
    right_foot.pos(@(foot_separation, 0.2, 0.5));

    // ----- set up camera (the player's eye) -----
    // camera
    GG.scene().camera() @=> GCamera @ eye;

    // camera constants
    @(0.0, 1.8, 0.0) => vec3 STARTING_EYES_POS;     // where the player's eyes are (relative to the player's position)
    eye.clipFar() + 100 => float FIRST_PERSON_CLIP_FAR;
    eye.fov() + 0.6 => float FIRST_PERSON_FOV;
    eye.fov() + 1 => float JUMP_FOV;

    // camera initial settings
    eye.pos(STARTING_EYES_POS);   // relative position to overall GPlayer
    eye.clip(eye.clipNear(), FIRST_PERSON_CLIP_FAR);
    eye.fov(FIRST_PERSON_FOV);
    eye --> this;

    // ----- set up FOV/position envelopes for eye -----
    Envelope fov_env => blackhole;
    500::ms => dur FOV_ON_DUR;
    100::ms => dur FOV_OFF_DUR;
    FIRST_PERSON_FOV => fov_env.value;

    // ----- keep track of camera mode -----
    0 => static int FIRST_PERSON;
    1 => static int THIRD_PERSON;
    FIRST_PERSON => int camera_mode;

    // ----- set up crosshair -----
    GCircle crosshair;

    0.005 => static float NEUTRAL_CROSSHAIR_SCA;
    0.02 => static float HOVER_CROSSHAIR_SCA;
    0.003 => static float CLICK_CROSSHAIR_SCA;
    
    @(0, 0, -0.4) => crosshair.pos;   // relative position to eye
    NEUTRAL_CROSSHAIR_SCA => crosshair.sca;
    Color.WHITE => crosshair.color;
    crosshair --> eye;

    GWindow.mouseMode(GWindow.MouseMode_Disabled);        // hide the mouse, since we have a crosshair
    // GWindow.fullscreen();

    // ----- reference to keyboard and mouse -----
    Keyboard @ keyboard;
    Mouse @ mouse;

    // ----- create a physics object for handling physics of player -----
    PhysicsObject physics_object;

    // ----- some constants to control gameplay -----
    
    40 => float PLAYER_SPEED;      // how much force is applied to player when running
    450 => float JUMP_FORCE;
    2000 => float LAUNCH_FORCE;
    true => int ALLOW_MIDAIR_JUMP;

    // ----- state of player -----
    float rot_y;        // we must keep track of our own roty, since this.rotY() doesn't accurately reflect the rotation

    // ----- input types -----
    0 => static int MOVE_FORWARD;
    1 => static int MOVE_BACKWARD;
    2 => static int MOVE_LEFT;
    3 => static int MOVE_RIGHT;
    4 => static int JUMP;
    5 => static int MOUSE_UPDATE;


    fun GPlayer(Keyboard @ k, Mouse @ m)
    {
        
        
        
        k @=> this.keyboard;
        m @=> this.mouse;

        // create physics object, handles physics computations for updating player position
        1 => float mass;
        PhysicsObject.EARTH_G => float gravity;
        2 => float mu_k;
        PhysicsObject.AIR_DENSITY => float fluid_density;
        PhysicsObject.CUBE_DRAG_COEFFICIENT => float c_d;
        0.01 => float surface_area;
        new PhysicsObject(mass, gravity, mu_k, fluid_density, c_d, surface_area) @=> physics_object;

        true => physics_object.normal_force_on;     // TEMPORARY, FOR TESTING PURPOSES. SHOULD ONLY COME ON WHEN ON A PLATFORM!
    }


    float single_frame_force;
    fun void poll_movement()
    {
        // compute single frame force for movement
        (keyboard.move_forward + keyboard.move_backward + keyboard.move_left + keyboard.move_right) => int num_directions;
        if (num_directions % 2 == 1) PLAYER_SPEED => single_frame_force;
        else PLAYER_SPEED / 2 => single_frame_force;    // to make sure we don't double force when moving diagonally

        if (keyboard.move_forward) handle_input(MOVE_FORWARD);
        if (keyboard.move_backward) handle_input(MOVE_BACKWARD);
        if (keyboard.move_left) handle_input(MOVE_LEFT);
        if (keyboard.move_right) handle_input(MOVE_RIGHT);
        if (keyboard.jump) handle_input(JUMP);
        
        handle_input(MOUSE_UPDATE);
    }

    fun void handle_input(int input)
    {
        // handle keyboard movement (running, jumping)
        single_frame_force * Math.sin(-rot_y) => float forward_x_offset;
        -single_frame_force * Math.cos(-rot_y) => float forward_z_offset;
        vec3 movement_force;
        if (input == MOVE_FORWARD)
        {
            forward_x_offset => float x_offset;
            forward_z_offset => float z_offset;
            @(x_offset, 0, z_offset) => movement_force;
        }
        else if (input == MOVE_BACKWARD)
        {
            -forward_x_offset => float x_offset;
            -forward_z_offset => float z_offset;
            @(x_offset, 0, z_offset) => movement_force;
        }
        else if (input == MOVE_LEFT)
        {
            forward_z_offset => float x_offset;
            -forward_x_offset => float z_offset;
            @(x_offset, 0, z_offset) => movement_force;
        }
        else if (input == MOVE_RIGHT)
        {
            -forward_z_offset => float x_offset;
            forward_x_offset => float z_offset;
            @(x_offset, 0, z_offset) => movement_force;
        }
        else if (input == JUMP && (physics_object.normal_force_on || ALLOW_MIDAIR_JUMP))           // normal force is on if the player on the ground. Only allow mid-air jumping if enabled
        {
            @(0, JUMP_FORCE, 0) => movement_force;
            false => keyboard.jump;     // only apply the jump force for a single frame
        }
        physics_object.apply_external_force(movement_force);
        

        // update position of camera
        // if (input == SWITCH_PERSPECTIVE)
        // {

        // }


        if (input == MOUSE_UPDATE)
        {
            mouse.deltas() => vec3 mouse_deltas;
            -(mouse_deltas.x * mouse.sensitivity) => float rotate_horizontal;        // delta angle to look left/right
            -(mouse_deltas.y * mouse.sensitivity) => float rotate_vertical;          // delta angle to look up/down

            // look left/right
            this.rotateY(rotate_horizontal);
            rot_y + rotate_horizontal => rot_y;     // update the player's roty (since we are manually tracking this)

            // look up/down
            this.eye.rotX() + rotate_vertical => float new_rotX;
            if (new_rotX < Math.PI/2 && new_rotX > -Math.PI/2)     // limit how far we can look up/down
            {
                this.eye.rotateX(rotate_vertical);
            }
        }
    }


    fun void update_position(float dt)
    {
        physics_object.update_position(dt);
        physics_object.position => this.pos;
        physics_object.set_external_force(@(0, 0, 0));      // reset external force each time we update position
    }


    fun void update_fov()
    {
        Math.PI/1.2 => float MAX_FOV;
        MAX_FOV - FIRST_PERSON_FOV => float MAX_FOV_INCREASE;
        // 55 => float peak_speed;      // my estimate for peak velocity magnitude
        40 => float peak_speed;
        if (camera_mode == FIRST_PERSON)
        {
            if (physics_object.normal_force_on)
            {
                FOV_OFF_DUR => fov_env.duration;
                FIRST_PERSON_FOV => fov_env.target;
            }
            else
            {
                FOV_ON_DUR => fov_env.duration;
                (physics_object.velocity.magnitude() / peak_speed) => float speed_factor;    // should be in range [0, 1], where 1 is fastest and 0 is slowest (not moving)
                FIRST_PERSON_FOV + (speed_factor * MAX_FOV_INCREASE) => fov_env.target;
            }
        }
        // if (camera_mode == FIRST_PERSON)
        // {
        //     if (physics_object.normal_force_on)
        //     {
        //         FOV_OFF_DUR => fov_env.duration;
        //         FIRST_PERSON_FOV => fov_env.target;
        //     }
        //     else
        //     {
        //         FOV_ON_DUR => fov_env.duration;
        //         JUMP_FOV => fov_env.target;
        //     }
        // }
        
        // else if (camera_mode == THIRD_PERSON)
        // {
        //     <<<"in third person">>>;
        // }

        fov_env.value() => eye.fov;

        
    }

    // override ggen update
    fun void update(float dt)
    {
        poll_movement();
        update_position(dt);
        update_fov();
        // now update normal 
    }



    // -------------- called by outside classes --------------------
    fun void set_crosshair_sca(float crosshair_sca)
    {
        <<< "new crosshair scale:", crosshair_sca >>>;
        crosshair_sca => crosshair.sca;
    }

    fun void set_normal_force(int normal_force_on_new)
    {
        physics_object.set_normal_force_on(normal_force_on_new);
    }

    fun void launch()
    {
        physics_object.apply_external_force(@(0, LAUNCH_FORCE, 0));
    }
}



// Testing out the player class
GWindow.title( "DANCE MONKEY" );
Keyboard k();
Mouse m();
spork ~ k.self_update();
spork ~ m.self_update();

GPlayer player(k, m) --> GG.scene();

<<< GG.scene().camera() >>>;
<<< player.eye >>>;

// fovs
player.eye.fov() => float STARTING_FOV;
player.eye.fov(STARTING_FOV);

// position
@(0.0, 0.0, 8.0) => vec3 STARTING_PLAYER_POS;
player.pos(STARTING_PLAYER_POS);

//add the suzanne
@(1, 0, 0) => vec3 MONKEY_COLOR;       // Red
GSuzanne monkey --> GG.scene();
monkey.sca(1.5);
monkey.color(MONKEY_COLOR);


while(true)
{
    // next graphics frame
    GG.nextFrame() => now;
}