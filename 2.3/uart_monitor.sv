`ifndef INC_UART_MONITOR
`define INC_UART_MONITOR

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if vif;

  protected uart_agent_cfg cfg;
  protected int time_bit;
  protected process mon_tx_thread;
  protected process mon_rx_thread;
  uvm_analysis_port #(uart_item) item_collected_port;
  uart_item bus_item_rx;
  uart_item bus_item_tx;

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
          fork
          begin
            mon_tx_thread = process::self();
            mon_tx_item();
          end

          begin
            mon_rx_thread = process::self();
            mon_rx_item();
          end
          join_none
      @(posedge vif.rst); begin
        mon_tx_thread.kill();
        mon_rx_thread.kill();
        `uvm_info(get_full_name(), "kill process", UVM_MEDIUM)
        do_reset();
      end
    end
  endtask

  // ----------------------------------------------------------------------------
  // task mon_tx_item
  // ----------------------------------------------------------------------------

  task mon_tx_item();
    forever begin  
      #time_bit;
      if(vif.tx == 0) begin // catch start bit
        bus_item_tx = uart_item::type_id::create("bus_item_tx");
        bus_item_tx.start_bit = vif.tx;
        
        for (int i = 0; i < 8; i++) begin
          #time_bit;
          bus_item_tx.data[i] = vif.tx;
        end

        #time_bit;
        bus_item_tx.parity_bit = vif.tx;

        #time_bit;
        bus_item_tx.end_bit = vif.tx;

        bus_item_tx.direction = 1;  //  TX ---> direction == 1;
        // `uvm_info("MON tx", $sformatf("\n%s", bus_item_tx.sprint()), UVM_MEDIUM)
        item_collected_port.write(bus_item_tx);
      end
    end
  endtask

  // ----------------------------------------------------------------------------
  // task mon_rx_item
  // ----------------------------------------------------------------------------

  task mon_rx_item();
    forever begin  
      #time_bit;
      if(vif.rx == 0) begin // catch start bit
        bus_item_rx = uart_item::type_id::create("bus_item_rx");
        bus_item_rx.start_bit = vif.rx;
        
        for (int i = 0; i < 8; i++) begin
          #time_bit;
          bus_item_rx.data[i] = vif.rx;
        end

        #time_bit;
        bus_item_rx.parity_bit = vif.rx;

        #time_bit;
        bus_item_rx.end_bit = vif.rx;

        bus_item_rx.direction = 0;  //  RX ---> direction == 0;

        // `uvm_info("MON rx", $sformatf("\n%s", bus_item_rx.sprint()), UVM_MEDIUM)
        item_collected_port.write(bus_item_rx);
      end
    end
  endtask

  // ----------------------------------------------------------------------------
  // task do_reset
  // ----------------------------------------------------------------------------

  task do_reset();
    bus_item_rx = uart_item::type_id::create("bus_item_rx");
    bus_item_tx = uart_item::type_id::create("bus_item_tx");
  endtask

endclass // uart_monitor

`endif