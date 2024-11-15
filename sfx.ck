public class SFX
{
    // set up sound bufs (for polyphonic sfx playback)
    3 => int NUM_BUFS;
    SndBuf bufs[NUM_BUFS];
    int buf_in_use[NUM_BUFS];

    for (int i; i < NUM_BUFS; i++) bufs[i] => dac;

    // set up file paths
    "sounds/sfx/" => string dir_path;
    [
        dir_path+"launch.wav", 
        dir_path+"contact_ground.wav"
    ] @=> string WAVS[];

    // SFX ids
    0 => static int LAUNCH;
    1 => static int CONTACT_GROUND;

    fun void play_sound(int sfx_id)
    {
        if (sfx_id < 0 || sfx_id >= WAVS.size())
        {
            <<< "sfx.ck: requested to play invalid sfx" >>>;
            return;
        }

        // get a free buf to play our sound effect
        get_free_buf_idx() => int free_buf_idx;
        if (free_buf_idx == -1) 0 => free_buf_idx;

        // play our sound effect
        bufs[free_buf_idx].read(WAVS[sfx_id]);
        bufs[free_buf_idx].length() => now;

        // once sound effect is finished, mark it's buf as free
        false => buf_in_use[free_buf_idx];
    }

    fun int get_free_buf_idx()
    {
        for (int i; i < bufs.size(); i++)
        {
            if (!buf_in_use[i])
            {
                true => buf_in_use[i];
                return i;
            }
        }
        return -1;
    }
}