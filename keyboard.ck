public class Keyboard
{
    int move_forward;
    int move_backward;
    int move_left;
    int move_right;
    int move_down;

    int jump;

    int instrument_param;
    int tempo_param;
    int bpm_param;
    int num_pads_param;
    int gravity_param;
    int launch_param;

    int increase_param;
    int decrease_param;

    int toggle_resync;
    int toggle_chess_mode;
    int toggle_menu;

    fun void self_update()
    {
        while (true)
        {
            GG.nextFrame() => now;

            (UI.isKeyDown(UI_Key.W)) => move_forward;
            (UI.isKeyDown(UI_Key.A)) => move_left;
            (UI.isKeyDown(UI_Key.S)) => move_backward;
            (UI.isKeyDown(UI_Key.D)) => move_right;
            (UI.isKeyDown(UI_Key.LeftShift)) => move_down;

            if (UI.isKeyPressed(UI_Key.Space, false))
            {
                true => jump;
            }

            (UI.isKeyDown(UI_Key.I)) => instrument_param;  // I: instrument
            (UI.isKeyDown(UI_Key.T)) => tempo_param;       // T: tempo
            (UI.isKeyDown(UI_Key.B)) => bpm_param;         // B: bpm
            (UI.isKeyDown(UI_Key.N)) => num_pads_param;    // N: num pads
            (UI.isKeyDown(UI_Key.G)) => gravity_param;     // G: gravity
            (UI.isKeyDown(UI_Key.L)) => launch_param;      // L: launch

            if (UI.isKeyPressed(UI_Key.UpArrow, false))
            {
                true => increase_param;
            }
            if (UI.isKeyPressed(UI_Key.DownArrow, false))
            {
                true => decrease_param;
            }

            if (UI.isKeyPressed(UI_Key.R, false))
            {
                true => toggle_resync;
            }
            if (UI.isKeyPressed(UI_Key.C, false))
            {
                true => toggle_chess_mode;
            }
            if (UI.isKeyPressed(UI_Key.E, false))
            {
                true => toggle_menu;
            }
            
        }
    }
}

// test out keyboard
Keyboard k;
k.self_update();
