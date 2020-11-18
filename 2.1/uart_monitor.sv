`ifndef INC_UART_MONITOR
`define INC_UART_MONITOR

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if vif;

  protected uart_agent_cfg cfg;
  protected int time_bit;
  protected process mon_item_thread;
  uvm_analysis_port #(uart_item) item_collected_port;
  uart_item bus_item;

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  // ----------------------------------------------------------------------------
  // function set_cfg
  // ----------------------------------------------------------------------------

  function void set_cfg(uart_agent_cfg _cfg);
    passed_arg_is_not_null: assert(_cfg != null)
    else
      `uvm_fatal(get_full_name(), $sformatf("arg ref passed to %s is null", get_full_name()))
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
            mon_item_thread = process::self();
            mon_item();
          end
        join_none
      @(posedge vif.rst);
        mon_item_thread.kill();
        `uvm_info(get_full_name(), "start reset", UVM_MEDIUM)
        do_reset();
    end
  endtask

  // ----------------------------------------------------------------------------
  // task mon_item
  // ----------------------------------------------------------------------------

  task mon_item();
    forever begin  
      #time_bit;
      if(vif.tx == 0) begin // catch start bit
        bus_item = uart_item::type_id::create("bus_item");
        bus_item.start_bit = vif.tx;
        
        for (int i = 0; i < 8; i++) begin
          #time_bit;
          bus_item.data[i] = vif.tx;
        end

        #time_bit;
        bus_item.parity_bit = vif.tx;

        #time_bit;
        bus_item.end_bit = vif.tx;

        `uvm_info("MON", $sformatf("bus_item MON:\n%s", bus_item.sprint()), UVM_MEDIUM)
        item_collected_port.write(bus_item);
      end
    end
  endtask

  // ----------------------------------------------------------------------------
  // task do_reset
  // ----------------------------------------------------------------------------

  task do_reset();
    bus_item = uart_item::type_id::create("bus_item");
  endtask

endclass // uart_monitor

`endif