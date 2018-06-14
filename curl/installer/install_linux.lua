local t = ...
local strDistId, strDistVersion, strCpuArch = t:get_platform()
local tResult

if strDistId=='@JONCHKI_PLATFORM_DIST_ID@' and strDistVersion=='@JONCHKI_PLATFORM_DIST_VERSION@' and strCpuArch=='@JONCHKI_PLATFORM_CPU_ARCH@' then
  t:install_dev('include',  '${install_dev_include}/')
  t:install_dev('lib',      '${install_dev_lib}/')
  t:install_dev('cmake',    '${install_dev_cmake}/')
  tResult = true
end

return tResult
