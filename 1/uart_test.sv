
`ifndef INC_UART_TEST
`define INC_UART_TEST

class uart_base_test extends uvm_test;
  uart_agent_cfg cfg;
  uart_agent agent;
  `uvm_component_utils(uart_base_test)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------
  function new(string name = "uart_base_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = uart_agent::type_id::create("agent", this);

    // Set up UART agent configuration, assign virtual interface handle and set in config_db
    cfg = uart_agent_cfg::type_id::create("cfg");

    // Get virtual interface from tb_top
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", cfg.vif))
        `uvm_fatal(get_type_name(), $sformatf("[CFG] Did not find uart_if in config_db"))
    cfg.is_active = 1;
    cfg.set_uart_ratio(19200); // 19200 bit/sec;
    // cfg.uart_ratio = 115200; // 115200 bit/sec;

    uvm_config_db#(uart_agent_cfg)::set(this, "agent", "cfg", cfg);
  endfunction

  // ----------------------------------------------------------------------------
  // virtual task  main_phase
  // ----------------------------------------------------------------------------
  task main_phase(uvm_phase phase);
      super.main_phase(phase);
  endtask

  // ----------------------------------------------------------------------------
  // function void end_of_elaboration_phase
  // ----------------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Hierarchy of the test environment: \n%s", this.sprint()), UVM_MEDIUM)
  endfunction

endclass // uart_base_test

class uart_run_test extends uart_base_test;
  uart_true_seq seq_true; 
  uart_error_seq seq_error;
  `uvm_component_utils(uart_run_test)

// ----------------------------------------------------------------------------
// function new
// ----------------------------------------------------------------------------
function new(string name = "uart_run_test", uvm_component parent = null);
  super.new(name,parent);
endfunction

// ----------------------------------------------------------------------------
// function void build_phase
// ----------------------------------------------------------------------------
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  seq_true = uart_true_seq::type_id::create("seq_true");
  seq_true.number_transaction=10;

  seq_error = uart_error_seq::type_id::create("seq_error");
  seq_error.number_transaction=10;
endfunction


// ----------------------------------------------------------------------------
// virtual task  main_phase
// ----------------------------------------------------------------------------
task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
      #100;
      cfg.vif.rst = 0;
      #100
      cfg.vif.rst = 1;
      #100
      cfg.vif.rst = 0;

      seq_true.start(agent.sequencer);
      #100;
      
      seq_error.start(agent.sequencer);
      #100;
    phase.drop_objection(this);
  endtask

// ----------------------------------------------------------------------------
// function void end_of_elaboration_phase
// ----------------------------------------------------------------------------
function void end_of_elaboration_phase(uvm_phase phase);
  if ($test$plusargs("print_env_hier"))
    `uvm_info(get_type_name(), $sformatf("Hierarchy of the test environment: \n%s", this.sprint()), UVM_MEDIUM)
endfunction

endclass // uart_run_test
`endif