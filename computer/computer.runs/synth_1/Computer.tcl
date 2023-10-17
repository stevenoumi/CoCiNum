# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param chipscope.maxJobs 1
set_msg_config  -id {Common 17-55}  -new_severity {WARNING} 
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/ing-angers/ndenoust/CoCiNum/CoCiNum/vivado/computer/computer.cache/wt [current_project]
set_property parent.project_path /home/ing-angers/ndenoust/CoCiNum/CoCiNum/vivado/computer/computer.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/ing-angers/ndenoust/CoCiNum/CoCiNum/vivado/computer/computer.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Virgule/Virgule_pkg.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Computer/Loader_pkg.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Computer/Computer_pkg.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Virgule/Virgule-precompiled.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Virgule/VMemory.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/InputSynchronizer/InputSynchronizer.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/UART/SerialReceiver.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/UART/SerialTransmitter.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/UART/UART.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Virgule/VInterruptController.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Timer/Timer.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/I2C/I2CMaster-precompiled.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/SPI/SPIMaster-precompiled.vhd
  /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Computer/Computer.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Buttons.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Buttons.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Clock.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Clock.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_LEDs.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_LEDs.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Switches.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_Switches.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_UART.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_UART.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_PmodA.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_PmodA.xdc]

read_xdc /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_PmodB.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/CoCiNum/src/vhdl/Basys3/Basys3_PmodB.xdc]

read_xdc /home/ing-angers/ndenoust/Téléchargements/Basys3_PmodC.xdc
set_property used_in_implementation false [get_files /home/ing-angers/ndenoust/Téléchargements/Basys3_PmodC.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top Computer -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef Computer.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file Computer_utilization_synth.rpt -pb Computer_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]