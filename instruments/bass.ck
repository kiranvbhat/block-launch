@import "../instrument.ck";

public class Bass extends Instrument {
    SawOsc bass => ADSR e => outlet;

    // scales

    4 => int num_notes;
    54 => int start_note;
    dur arp_dur;
    LYDIAN @=> int scale[];

    fun void play(dur note_duration, int note_index)
    {
        bass
        for (int i; i < num_notes; i++)
        {
            scale[Math.random2(0, scale.size()-1)] + 12*Math.random2(0, 1) => int offset;
            start_note + offset => int pitch;
            Std.mtof(pitch) => arp.freq;
            arp_dur/num_notes => now;
        }
        arp.noteOff(0.5);

    }
}

// testing
Arp a => dac;
repeat(50)
{
    spork ~ a.play(500::ms);
    1000::ms => now;
}