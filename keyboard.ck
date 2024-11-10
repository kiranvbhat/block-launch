// 26 => W;
// 4 => A;
// 22 => S;
// 7 => D;

public class Keyboard
{
    int move_forward;
    int move_backward;
    int move_left;
    int move_right;

    int jump;

    int tempo_param;
    int bpm_param;
    int num_pads_param;

    int resync;
    int chess_mode;

    fun void self_update()
    {
        while (true)
        {
            GG.nextFrame() => now;

            (UI.isKeyDown(UI_Key.W)) => move_forward;
            (UI.isKeyDown(UI_Key.A)) => move_left;
            (UI.isKeyDown(UI_Key.S)) => move_backward;
            (UI.isKeyDown(UI_Key.D)) => move_right;

            if (UI.isKeyPressed(UI_Key.Space, false))
            {
                true => jump;
            }

            (UI.isKeyDown(UI_Key.T)) => tempo_param;       // T: tempo
            (UI.isKeyDown(UI_Key.B)) => bpm_param;         // B: bpm
            (UI.isKeyDown(UI_Key.N)) => num_pads_param;         // N: num pads

            if (UI.isKeyPressed(UI_Key.R, false))
            {
                true => resync;
            }
            if (UI.isKeyPressed(UI_Key.C, false))
            {
                true => chess_mode;
            }
            
        }
    }
}

// test out keyboard
Keyboard k;
k.self_update();
