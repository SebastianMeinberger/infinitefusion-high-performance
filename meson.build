project('infinitefusion-e18')

## Prepare Game


## Benchmarks
# prepare mkxp-z

extern_mkxpz_path = get_option('extern_mkxp-z_path')
mkxpz_arguments = []

if extern_mkxpz_path == ''
  debug('subproj mkxp-z not yet implemented')
  mkxpz = find_program('')
else
  mkxpz = find_program(extern_mkxpz_path, required: true)
  if(extern_mkxpz_path.endswith('wine'))
      mkxpz_arguments += '../Game.exe' 
  endif
endif

mkxpz_arguments += meson.current_build_dir()

ruby = find_program('ruby', required: true)
timestamp_wrapper = find_program('Tests/Create_Timestamp.rb', required: true)

metrics_to_timestamp = []
foreach metric : get_option('metrics')
  metrics_to_timestamp += ['--metric', metric]
endforeach

metrics_to_timestamp += ['--name', 'og_exe_fix_graphics']

add_test_setup('Performance_Measures', exe_wrapper: [ruby, timestamp_wrapper, metrics_to_timestamp])

benchmark_env = ['GALLIUM_HUD=frametime,requested-VRAM', 'GALLIUM_HUD_PERIOD=0', ''.join(['GALLIUM_HUD_DUMP_DIR=',meson.current_build_dir(), '/Raw_Measurments'])]



benchmark('Pallettown_Tile_Load_Freezes', mkxpz, args: mkxpz_arguments, env: benchmark_env, timeout: 20, workdir: meson.current_build_dir())
