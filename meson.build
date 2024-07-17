project('infinitefusion-e18')

## Benchmarks
# prepare mkxp-z

if get_option('extern_mkxp-z_path') == ''
  debug('subproj mkxp-z not yet implemented')
else
  debug('hoe')
  mkxpz = find_program('/home/seb/Downloads/mkxp-z-2.4.2/build/mkxp-z.x86_64', required: true)
endif

benchmark_env = ['GALLIUM_HUD=frametime,requested-VRAM', 'GALLIUM_HUD_PERIOD=0', 'GALLIUM_HUD_DUMP_DIR=.']

benchmark('Performance Measures', mkxpz, env: benchmark_env, timeout: 60, workdir: meson.current_build_dir())
