`ifndef INC_UART_AGENT
`define INC_UART_AGENT


class uart_agent extends uvm_agent;
  uart_agent_cfg cfg;
  uart_driver driver;
  uart_monitor monitor;
  uart_sequencer sequencer;
  `uvm_component_utils(uart_agent)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void set_cfg
  // ----------------------------------------------------------------------------

  function void set_cfg(uart_agent_cfg _cfg);
    passed_arg_is_not_null: assert(_cfg != null)
    else
      `uvm_fatal(get_full_name(), $sformatf("arg ref passed to %s via 'set_cfg' is null", get_full_name()))
    cfg = _cfg;
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    if(cfg == null && !uvm_config_db #(uart_agent_cfg)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_full_name(), $sformatf("cfg is null: %s.cfg", get_full_name()))

    if(cfg.vif == null) begin
      vif_is_not_null: assert(uvm_config_db#(virtual uart_if)::get(this, "", "cfg.vif", cfg.vif))
      else `uvm_fatal(get_full_name(), $sformatf("vif is null: %s.vif", get_full_name()))
    end

    monitor = uart_monitor::type_id::create("monitor", this);
    monitor.set_cfg(cfg);

    if(cfg.is_active) begin
      driver = uart_driver::type_id::create("driver", this);
      driver.set_cfg(cfg);
      sequencer = uart_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  // ----------------------------------------------------------------------------
  // function void connect_phase
  // ----------------------------------------------------------------------------

  function void connect_phase(uvm_phase phase);
    if(cfg.is_active)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

`endif