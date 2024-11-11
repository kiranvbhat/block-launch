@import "../instrument.ck";

public class Arp extends Instrument {
    VoicForm arp => outlet;
    
    // phonemes
    ["eee", "ihh", "ehh", "aaa", "ahh", "aww", "ohh", "uhh", "uuu", "ooo", "rrr", "lll", "mmm", "nnn", "nng", "ngg", "fff", "sss", "thh", "shh", "xxx", "hee", "hoo", "hah", "bbb", "ddd", "jjj", "ggg", "vvv", "zzz", "thz", 
    "zhh"] @=> string phonemes[];

    // scales
    [0, 2, 4, 5, 7, 9, 11] @=> static int MAJOR[];
    [0, 2, 3, 5, 7, 8, 10] @=> static int MINOR_NATURAL[];
    [0, 2, 3, 5, 7, 8, 10] @=> static int MINOR_HARMONIC[];
    [0, 2, 4, 6, 7, 9, 11] @=> static int LYDIAN[];

    // [-1, 0, 4, 6, 11] @=> static int LYDIAN[];

    10 => int num_notes;
    54 => int start_note;
    dur arp_dur;
    LYDIAN @=> int scale[];

    fun void play(dur arp_dur, int index)
    {
        arp.noteOn(0.5);
        for (int i; i < num_notes; i++)
        {
            scale[Math.random2(0, scale.size()-1)] + 12*Math.random2(0, 1) => int offset;
            start_note + offset => int pitch;
            Std.mtof(pitch) => arp.freq;
            arp.phoneme(phonemes[Math.random2(0, phonemes.size()-1)]);
            arp_dur/num_notes => now;
        }
        arp.noteOff(1);

    }
}

// testing
Arp a => dac;
repeat(50)
{
    spork ~ a.play(2000::ms);
    2000::ms => now;
}