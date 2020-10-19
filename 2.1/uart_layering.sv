
class uart_layering extends uvm_subscriber #( uart_item );
  `uvm_component_utils( uart_layering )
    uvm_analysis_port #( uart_reg_item ) ap;
    uart_reg_sequencer reg_sequencer;
    uart_2_reg_monitor uart_to_reg_mon;
    uart_agent agent;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    reg_sequencer = uart_reg_sequencer::type_id::create("a_sequreg_sequencerencer",this);
    reg_monitor = uart_2_reg_monitor::type_id::create("reg_monitor",this);

    ap = new("ap" , this );
  endfunction

  function void connect_phase(uvm_phase phase);
    reg_monitor.ap.connect( ap );
  endfunction

  virtual task run_phase(uvm_phase phase);
     reg_2_uart_seq reg_to_uart_seq;

     reg_to_uart_seq = reg_2_uart_seq::type_id::create("reg_to_uart_seq");

    // connect translation sequences to their respective upstream sequencers
    reg_to_uart_seq.up_sequencer = reg_sequencer;

    // start the translation sequences
    fork
      reg_to_uart_seq.start(agent.sequencer);
    join_none
  endtask

  // this method connects the incoming C_items to the c2b monitor
  function void write( uart_item t );
    uart_to_reg_mon.write( t );
  endfunction

  // a convenience method to connect active and passive datapaths in one method
  function void connect_to_C_agent( uart_agent a );
    agent = a;
    agent.ap.connect( analysis_export );
  endfunction

endclass

