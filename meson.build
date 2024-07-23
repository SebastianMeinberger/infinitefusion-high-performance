project('infinitefusion-e18')

## Benchmarks
# prepare mkxp-z

if get_option('extern_mkxp-z_path') == ''
  debug('subproj mkxp-z not yet implemented')
  mkxpz = find_program('')
else
  mkxpz = find_program('/home/seb/Packages/mkxp-z/builddir/mkxp-z.x86_64', required: true)
endif

ruby = find_program('ruby', required: true)
timestamp_wrapper = find_program('Tests/Create_Timestamp.rb', required: true)

metrics_to_timestamp = []
foreach metric : get_option('metrics')
  metrics_to_timestamp += '--metric'
  metrics_to_timestamp += metric
endforeach

add_test_setup('Performance_Measures', exe_wrapper: [ruby, timestamp_wrapper, metrics_to_timestamp]  )

benchmark_env = ['GALLIUM_HUD=frametime,requested-VRAM', 'GALLIUM_HUD_PERIOD=0', ''.join(['GALLIUM_HUD_DUMP_DIR=',meson.current_build_dir(), '/Raw_Measurments'])]

benchmark('Pallettown_Tile_Load_Freezes', mkxpz, env: benchmark_env, timeout: 10, workdir: meson.current_build_dir())
