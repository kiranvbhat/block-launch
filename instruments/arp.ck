@import "../instrument.ck";

public class Arp extends Instrument {
    FrencHrn arp => NRev rev => outlet;
    rev.mix(0.1);

    // scales
    [0, 2, 4, 5, 7, 9, 11] @=> static int MAJOR[];
    [0, 2, 3, 5, 7, 8, 10] @=> static int MINOR_NATURAL[];
    [0, 2, 3, 5, 7, 8, 10] @=> static int MINOR_HARMONIC[];
    [0, 2, 4, 6, 7, 9, 11] @=> static int LYDIAN[];

    4 => int num_notes;
    54 => int start_note;
    dur arp_dur;
    LYDIAN @=> int scale[];

    fun void play(dur arp_dur, int note_index)
    {
        // ignore note_index, we don't need it for this instrument
        // <<< "arp.ck: playing arp, note index", note_index >>>;
        arp.noteOn(0.5);

        for (int i; i < num_notes; i++)
        {
            scale[Math.random2(0, scale.size()-1)] + 12*Math.random2(0, 1) => int offset;
            start_note + offset => int pitch;
            Std.mtof(pitch) => arp.freq;
            arp_dur/num_notes => now;
        }
        arp.noteOff(0.5);

    }

    fun string get_name()
    {
        return "FRENCH HORN";
    }
}

// testing
Arp a => dac;
repeat(50)
{
    spork ~ a.play(500::ms);
    1000::ms => now;
}