`ifndef INC_UART_DRIVER
`define INC_UART_DRIVER

class uart_driver extends uvm_driver #(uart_item);
  protected virtual uart_if vif;
  protected uart_agent_cfg cfg;
  protected process drive_item_thread;
  protected int time_bit;
  `uvm_component_utils(uart_driver)

  function new(string name = "uart_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function set_cfg
  // ----------------------------------------------------------------------------

  function void set_cfg(uart_agent_cfg _cfg);
    passed_arg_is_not_null: assert(_cfg != null)
    else `uvm_fatal(get_full_name(), $sformatf("arg ref passed to %s is null", get_full_name()))
    cfg = _cfg;
  endfunction

  // ----------------------------------------------------------------------------
  // function build_phase
  // ----------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    vif = cfg.vif;
  endfunction

  // ----------------------------------------------------------------------------
  // task run_phase
  // ----------------------------------------------------------------------------

  task run_phase(uvm_phase phase);
    time_bit = 1_000_000 / cfg.uart_ratio;

    #time_bit;
    forever begin
      @(negedge vif.rst);
        `uvm_info(get_full_name(), "end reset", UVM_MEDIUM)
        fork
          begin
            drive_item_thread = process::self();
            drive_item();
          end
        join_none
      @(posedge vif.rst);
        drive_item_thread.kill();
        `uvm_info(get_full_name(), "start reset", UVM_MEDIUM)
        do_reset();
    end

  endtask

  // ----------------------------------------------------------------------------
  // task do_reset
  // ----------------------------------------------------------------------------

  task do_reset();
    vif.tx = 1;
  endtask

  // ----------------------------------------------------------------------------
  // task drive_item
  // ----------------------------------------------------------------------------

  task drive_item();
    forever begin
      seq_item_port.get_next_item(req);
      vif.tx = req.start_bit;

      for (int i = 0; i < 8; i++) begin
        #time_bit;
        vif.tx = req.data[i];
      end

      #time_bit;
      vif.tx = req.parity_bit;
      
      #time_bit;
      vif.tx = req.end_bit;

      seq_item_port.item_done();
      seq_item_port.put_response(req);
      #time_bit;
    end
  endtask
endclass // uart_driver

`endif