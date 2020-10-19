`ifndef INC_UART_SEQ_LIB
`define INC_UART_SEQ_LIB

// ----------------------------------------------------------------------------
// class uart_base_seq
// ----------------------------------------------------------------------------

class uart_base_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_base_seq)
  int        number_transaction;
  bit        start_bit;
  bit        parity_bit;
  bit        end_bit;
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
  uvm_phase phase;

  phase = get_starting_phase();

  if(phase != null)
    phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
endtask

// ----------------------------------------------------------------------------
// task post_body
// ----------------------------------------------------------------------------
task post_body();
  uvm_phase phase;

  phase = get_starting_phase();

  if(phase != null)
    phase.drop_objection(this);
endtask
endclass // uart_base_seq


// ----------------------------------------------------------------------------
// class uart_true_seq
// ----------------------------------------------------------------------------
class uart_true_seq extends uart_base_seq;
  `uvm_object_utils(uart_true_seq)

// ----------------------------------------------------------------------------
// function new
// ----------------------------------------------------------------------------
  function new(string name ="uart_true_seq");
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
          req.start_bit==0;
          //req.data=='hFF;
          req.end_bit==1;
          }
        )
        else
          `uvm_fatal(get_full_name(), "Randomization failed!")

        req.parity_bit = ^req.data;
          
       `uvm_send(req)
        get_response(rsp);
    end
      `uvm_info(get_type_name(), $sformatf("End sequence"), UVM_MEDIUM)
  endtask

endclass // uart_true_seq

// ----------------------------------------------------------------------------
// class uart_error_seq
// ----------------------------------------------------------------------------
class uart_error_seq extends uart_base_seq;
  `uvm_object_utils(uart_error_seq)

// ----------------------------------------------------------------------------
// function new
// ----------------------------------------------------------------------------
  function new(string name ="uart_error_seq");
    super.new(name);
  endfunction

// ----------------------------------------------------------------------------
// task body
// ----------------------------------------------------------------------------
  task body();
    repeat (number_transaction) begin
    `uvm_create(req)
      randomization_with_err_success: assert(req.randomize()
         with {
          // req.start_bit==1;
          // req.data=='hFF;
          // req.parity_bit == 1;
          // req.end_bit==1;
        })
        else
          `uvm_fatal(get_full_name(), "Randomization failed!")

   `uvm_send(req)
    get_response(rsp);
  end
  endtask
  endclass // uart_error_seq
`endif