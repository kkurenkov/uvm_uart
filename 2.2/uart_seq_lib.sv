`ifndef INC_UART_SEQ_LIB
`define INC_UART_SEQ_LIB

class uart_base_seq extends uvm_sequence #(high_reg_item);
  `uvm_object_utils(uart_base_seq)
  int        number_transaction;

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name ="uart_base_seq");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // task pre_body
  // ----------------------------------------------------------------------------

  task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
  endtask

  // ----------------------------------------------------------------------------
  // task post_body
  // ----------------------------------------------------------------------------

  task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass


class uart_high_seq extends uart_base_seq;
  `uvm_object_utils(uart_high_seq)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name ="uart_high_seq");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // task body
  // ----------------------------------------------------------------------------

  task body();
    `uvm_info(get_type_name(), $sformatf("Start sequence"), UVM_MEDIUM)

    repeat (number_transaction) begin
      `uvm_create(req)

      randomization_is_successfull: assert(req.randomize()
      with { 
        req.kind == 1;
        req.addr inside {0,1};
        // req.data == 2;
      })
      else `uvm_fatal(get_full_name(), "Randomization failed!")
  
      `uvm_send(req)
    end
      `uvm_info(get_type_name(), $sformatf("End sequence"), UVM_MEDIUM)
  endtask

endclass

`endif