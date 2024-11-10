@import {"gpad.ck", "gplayer.ck", "raycaster.ck", "instrument.ck"}

public class GPlatform extends GGen
{
    // constants for platform layout
    0.7 => float PAD_SIZE;      // must be within [0, 1]
    7 => float PLATFORM_PADDING;        // the padding between the edge of the platform and the pads
    4 => int MAX_PADS_IN_ROW;
    16 => int STARTING_NUM_PADS;
    16 => int MAX_NUM_PADS;

    // floor
    GPlane floor --> this;
    floor.rotateX(Math.PI/2);
    floor.color(@(0.1, 0.1, 0.1));
    floor.sca(20);
    // floor.scaY(20);

    // pads
    0 => int num_pads;
    GPad pads[MAX_NUM_PADS];
    int pad_in_use[MAX_NUM_PADS];     // 1 if pad is in use, 0 otherwise

    // player and raycaster
    GPlayer @ player;
    RayCaster @ rc;
    Instrument @ instrument;

    // state of platform
    int floor_under_player;
    80 => float bpm;
    false => int sequence_running;
    0 => int current_beat;              // keep track of beat so we can maintain beat while changing number of pads!

    fun GPlatform(GPlayer @ gp, Instrument @ i)
    {
        gp @=> player;
        i @=> instrument;

        new RayCaster(player) @=> rc;

        place_pads(0, STARTING_NUM_PADS);
        start_beat();
    }


    fun void update_num_pads(int new_num_pads)
    {
        if (new_num_pads < 0) 0 => new_num_pads;        // floor of 0

        // stop_beat();

        if (new_num_pads < num_pads)
        {
            remove_pads(new_num_pads, num_pads);
        }
        else if (new_num_pads > num_pads)
        {
            place_pads(num_pads, new_num_pads);
        }
        
        // new_num_pads => num_pads;
        // start_beat();
    }

    fun void remove_pads(int start, int end)
    {
        for (start => int i; i < end; i++)
        {
            if (pad_in_use[i])      // make sure we're not removing a pad that has already been removed/isn't in use. This makes remove_pads() idempotent!!
            {
                pads[i] --< this;
                num_pads - 1 => num_pads;
                false => pad_in_use[i];
            }
        }
    }

    fun void place_pads(int start, int end)     // include start, exclude end
    {
        
        floor.sca().x - PLATFORM_PADDING => float floor_scale;
        (floor_scale / (MAX_PADS_IN_ROW-1)) * PAD_SIZE => float pad_scale;
        (floor_scale / (MAX_PADS_IN_ROW-1)) * (1 - PAD_SIZE) => float pad_spacing;
        @(-floor_scale/2, 0, -floor_scale/2) => vec3 pad_start_pos;

        for (start => int i; i < end; i++)
        {
            if (!pad_in_use[i])
            {
                true => pad_in_use[i];
                i % MAX_PADS_IN_ROW => int col;
                i / MAX_PADS_IN_ROW  => int row;
                pad_start_pos.x + (pad_scale * col) + (pad_spacing * col) => float x;
                pad_start_pos.z + (pad_scale * row) + (pad_spacing * row) => float z;

                GPad new_pad(player) --> this;
                new_pad.pos(@(x, 0, z));
                new_pad.sca(@(pad_scale, 1, pad_scale));

                // state of platform
                new_pad @=> pads[i];
                num_pads + 1 => num_pads;
            }
        }
    }

    fun void start_beat()
    {
        true => sequence_running;
        spork ~ sequence_beat();
    }

    fun void stop_beat()
    {
        false => sequence_running;
    }

    fun void sequence_beat()
    {
        60::second / bpm => dur beat_dur;
        while (sequence_running)
        {
            if (current_beat > num_pads-1) 0 => current_beat;           // edge case, could occur if we decrease the number of pads (e.g. current_beat=6, but we decreased num_pads to 4)
            for (current_beat; current_beat < num_pads; current_beat++)
            {
                if (pads[current_beat].active())
                {
                    spork ~ instrument.play();
                }
                pads[current_beat].play(beat_dur/8);    // start animation
                beat_dur => now;
                pads[current_beat].stop(beat_dur/1);    // stop animation
            }
            0 => current_beat;

            if (num_pads == 0) beat_dur => now;     // edge case: if there are 0 pads, this prevents looping super fast
        }
    }

    fun void update_floor_under_player()
    {
        // check if the floor is under the player using our raycaster
        rc.under_player(floor, this.rotY()) => floor_under_player;
        if (floor_under_player) player.set_normal_force(true);      // update this as soon as we detect it!!! prevents clipping through floor
    }

    fun void update(float dt)
    {
        update_floor_under_player();
    }
    
}