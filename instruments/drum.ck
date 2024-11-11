@import "../instrument.ck";

public class Drum extends Instrument { 
    inlet => SndBuf drum => outlet;

    // set up file paths
    "sounds/drums/" => string dir_path;
    [
        dir_path+"kick.wav", 
        dir_path+"snare.wav",
        dir_path+"hihat.wav",
        dir_path+"crash_1_edge.wav",
        dir_path+"ride_bell.wav",
        dir_path+"ride_tip.wav"
    ] @=> string WAVS[];

    // drum types
    0 => static int KICK;
    1 => static int SNARE;
    2 => static int HIHAT;
    3 => static int CRASH;
    4 => static int RIDE;

    // keep track of drum type
    KICK => int drum_type;

    // constructor
    fun Drum(int type)
    {
        type => drum_type;
    }

    // setting drum type
    fun void set_drum_type(int type)
    {
        type => drum_type;
    }

    // playing a single drum sound
    fun void play(dur duration, int note_index) {
        // throw away duration and note index, not needed
        drum.read(WAVS[drum_type]);
        drum.length() => now;
    }
}