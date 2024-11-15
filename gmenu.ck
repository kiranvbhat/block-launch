@import "constants.ck";

public class GMenu extends GGen
{
    Constants c;

    GG.scene().camera() @=> GCamera @ eye;

    GText status --> eye;

    status.text("starting text");
    status.pos(@(0, 0, c.MENU_POS_Z));
    status.sca(c.STATUS_SCALE);
    status.spacing(c.STATUS_SPACING);
    
    string status_strs[c.NUM_STATUS_PARAMS];      // [instrument, tempo, bpm, num_pads, gravity, launch_force, chess_mode]

    Envelope status_env => blackhole;
    c.TEXT_ENV_DUR => status_env.duration;
    0 => status_env.value;

    false => int status_displaying;

    GText action --> eye;      // text displaying the most recent action
    action.text("BLOCK LAUNCH");
    action.pos(@(0, 0, c.MENU_POS_Z));
    action.sca(0);

    "BLOCK LAUNCH" => string most_recent_action;
    
    Envelope action_env => blackhole;
    c.TITLE_ENV_DUR => action_env.duration;
    false => int title_already_displayed;
    // c.ACTION_SCALE => action_env.value;

    fun GMenu()
    {
        refresh_status();
        spork ~ display_action();
        refresh_layout();
    }

    fun void refresh_status()
    {
        // refresh status

        string new_status_str;
        for (int s; s < status_strs.size(); s++)
        {
            new_status_str + c.STATUS_PREFIX[s] + status_strs[s] + "\n" => new_status_str;
            // if (s != status_strs.size()-1) new_status_str + "\n" => new_status_str;
        }
        new_status_str + c.STATUS_DISPLAY_PREFIX => new_status_str;
        status.text(new_status_str);
    }

    fun void refresh_layout()
    {
        // refresh positions
        GWindow.windowSize().x => float current_width;
        GWindow.windowSize().y => float current_height;

        current_width / c.FULLSCREEN_WIDTH => float width_ratio;
        current_height / c.FULLSCREEN_HEIGHT => float height_ratio;

        @(c.STATUS_POS_X * width_ratio, c.STATUS_POS_Y * height_ratio, c.MENU_POS_Z) => vec3 new_status_pos;                        // local pos
        status.pos(new_status_pos);

        action.pos(@(0, 0, c.MENU_POS_Z));
    }

    fun void toggle_status()
    {
        if (status_displaying) hide_status();
        else show_status();
    }

    fun void show_status()
    {
        c.STATUS_SCALE => status_env.target;
        true => status_displaying;
    }

    fun void hide_status()
    {
        0 => status_env.target;
        false => status_displaying;
        <<< "HIDING STATUS!" >>>;
    }

    fun void display_action()
    {
        if (title_already_displayed)
        {
            most_recent_action => string new_action_str;
            <<< "Displaying action", new_action_str >>>;
            action.text(new_action_str);
        }
        
        if (!title_already_displayed)
        {
            5::second => now;      // delay title for filming
            c.ACTION_SCALE => action_env.target;
            c.TITLE_ENV_DUR => now;
            c.ACTION_LIFESPAN => now;
        }
        else
        {
            c.ACTION_SCALE => action_env.target;
            c.ACTION_LIFESPAN => now;
        }
        0 => action_env.target;
        if (!title_already_displayed)
        {
            c.TITLE_ENV_DUR => now;
            true => title_already_displayed;
            toggle_status();
        }
        c.TEXT_ENV_DUR => action_env.duration;
    }

    fun void update(float dt)
    {
        status_env.value() => status.sca;
        action_env.value() => action.sca;
        refresh_layout();
    }
}

GMenu menu --> GG.scene();
GG.scene().camera().pos(@(0,0,0));

while (true)
{
    GG.nextFrame() => now;
}