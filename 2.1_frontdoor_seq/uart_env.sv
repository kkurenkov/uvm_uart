`ifndef INC_UART_ENV
`define INC_UART_ENV

class uart_env extends uvm_env;
  uart_env_cfg cfg;
  uart_agent agent;
  uart_reg_adapter reg_adapter;
  uart_reg_predictor reg_predictor;

  `uvm_component_utils(uart_env)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    cfg_is_not_null: assert(uvm_config_db#(uart_env_cfg)::get(this, "", "cfg", cfg))
    else `uvm_fatal(get_full_name(), $sformatf("cfg is null: %s.cfg", get_full_name()))

    agent = uart_agent::type_id::create("agent", this);
    agent.set_cfg(cfg.uart_ag_cfg);

    reg_predictor = uart_reg_predictor::type_id::create(.name("reg_predictor"), .parent(this));
    reg_adapter = uart_reg_adapter::type_id::create(.name("reg_adapter")); 
  endfunction

  // ----------------------------------------------------------------------------
  // function void connect_phase
  // ----------------------------------------------------------------------------

  function void connect_phase(uvm_phase phase);
    cfg.reg_model.map.set_sequencer( .sequencer(agent.sequencer), .adapter( reg_adapter ) );
    reg_predictor.map = cfg.reg_model.default_map;
    reg_predictor.adapter = reg_adapter;
    agent.monitor.item_collected_port.connect(reg_predictor.bus_in);
  endfunction

endclass

`endif
