`include "defines.svh"

class ram_environment;

    //==================================================
    // Virtual Interfaces
    //==================================================

    virtual ram_if.DRV    drv_vif;
    virtual ram_if.MON    mon_vif;
    virtual ram_if.REF_SB ref_vif;

    //==================================================
    // Mailboxes
    //==================================================

    // Generator -> Driver
    mailbox #(ram_transaction) mbx_gd;

    // Driver -> Reference Model
    mailbox #(ram_transaction) mbx_dr;

    // Reference Model -> Scoreboard
    mailbox #(ram_transaction) mbx_rs;

    // Monitor -> Scoreboard
    mailbox #(ram_transaction) mbx_ms;

    //==================================================
    // Component Handles
    //==================================================

    ram_generator        gen;
    ram_driver           drv;
    ram_monitor          mon;
    ram_reference_model  ref_sb;
    ram_scoreboard       scb;

    //==================================================
    // Constructor
    //==================================================

    function new(virtual ram_if.DRV drv_vif,
                 virtual ram_if.MON mon_vif,
                 virtual ram_if.REF_SB ref_vif);

        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.ref_vif = ref_vif;

    endfunction

    //==================================================
    // Build
    //==================================================

    task build();

        //------------------------------
        // Create Mailboxes
        //------------------------------
        mbx_gd = new();
        mbx_dr = new();
        mbx_rs = new();
        mbx_ms = new();

        //------------------------------
        // Create Components
        //------------------------------
        gen    = new(mbx_gd);

        drv    = new(mbx_gd,
                     mbx_dr,
                     drv_vif);

        mon    = new(mon_vif,
                     mbx_ms);

        ref_sb = new(mbx_dr,
                     mbx_rs,
                     ref_vif);

        scb    = new(mbx_rs,
                     mbx_ms);

    endtask

    //==================================================
    // Start
    //==================================================

    task start();

        fork

            gen.start();

            drv.start();

            mon.start();

            ref_sb.start();

            scb.start();

        join

    endtask

endclass
