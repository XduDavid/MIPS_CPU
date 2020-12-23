update_compile_order -fileset sources_1
upgrade_ip [get_ips]

reset_run impl_1
reset_run synth_1

launch_runs -quiet impl_1 -jobs 8
wait_on_run impl_1

exit
