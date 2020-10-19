
`ifndef INC_UART_ITEM
`define INC_UART_ITEM


class uart_item extends uvm_sequence_item;
  function new(string name = "uart_item");
    super.new(name);
  endfunction

  rand bit        start_bit;
  rand bit [7:0]  data;
  rand bit        parity_bit;
  rand bit        end_bit;

  `uvm_object_utils_begin(uart_item)
    `uvm_field_int (start_bit, UVM_DEFAULT)
    `uvm_field_int (data,  UVM_DEFAULT)
    `uvm_field_int (parity_bit, UVM_DEFAULT)
    `uvm_field_int (end_bit, UVM_DEFAULT)
  `uvm_object_utils_end
endclass


`endif