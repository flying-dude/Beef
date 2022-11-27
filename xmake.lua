-- required for compiler flag "-fms-extensions"
set_toolchains("clang")

set_languages("c++20")

add_includedirs("/usr/include/freetype2")
add_includedirs("/usr/lib/llvm13/include/")
add_includedirs("$(projectdir)")
add_includedirs("$(projectdir)/IDEHelper/")
add_includedirs("$(projectdir)/BeefySysLib/")
add_includedirs("$(projectdir)/BeefySysLib/util")
add_includedirs("$(projectdir)/BeefySysLib/platform/linux/")

-- makes a few minor adjustments in c++ files for the xmake build.
add_cxxflags("-DXMAKE_BUILD")

-- deactivate exceptions globally
-- (keeping 'em activated for now but plan is to remove completely eventually)
-- add_cxxflags("-fno-exceptions")

-- debug mode does not entail debug flag in xmake. so we need to set it here.
if is_mode("debug") then
  add_cxxflags("-g", "-DDEBUG")
end

target("BeefIDE")
  add_deps("BeefBuild")

  on_build(function (target)
    print("Building: BeefIDE")

    -- https://snippets.bentasker.co.uk/page-1705231409-Trim-whitespace-from-end-of-string-LUA.html
    function rstrip(s)
      return s:match'^(.*%S)%s*$'
    end

    -- Beef IDE on Windows uses "Segoe UI" font, which is often not available on Linux.
    -- It supports "NotoSans Regular" as a fallback, tho (see IDEApp.bf).
    -- print(os.iorun("fc-list NotoSans : file | grep NotoSans-Regular.ttf | cut -d: -f1"))
    local noto_fonts = rstrip(os.iorun("fc-list NotoSans : file"))

    -- https://stackoverflow.com/questions/32847099/split-a-string-by-n-or-r-using-string-gmatch
    for noto_font in noto_fonts:gmatch("[^\r\n]+") do
      noto_font = rstrip(noto_font) -- remove trailing newline
      noto_font = noto_font:sub(1, #noto_font - 1) -- remove trailing colon ":"

      -- find the font we need and symlink into IDE dist folder
      if string.find(noto_font, "Regular") then
        os.execv("ln", {"-sf", noto_font}, { curdir = "IDE/dist/fonts" })
      end
    end

    os.execv("IDE/dist/BeefBuild",
      {
        "-proddir=IDE",
        "-config=Release"
      })
  end)

  on_run(function (target)
    print("Running: BeefIDE")
    os.execv("IDE/dist/BeefIDE", {})
  end)

target("BeefBuild")
  add_deps("BeefBuild_boot")
  on_build(function (target)
    print("Building: BeefBuild")

    os.execv("IDE/dist/BeefBuild_boot",
      {
        "-proddir=BeefBuild",
        "-config=Release"
      })

    print("Testing: IDEHelper/Tests in BeefBuild")
    os.execv("IDE/dist/BeefBuild",
      {
        "-proddir=IDEHelper/Tests",
        "-test"
      })
  end)

target("BeefBuild_boot")
  add_deps("BeefBoot")
  on_build(function (target)
    print("Building: BeefBuild_boot")

    local LINKOPTS = "-ldl -lpthread -lLLVM-13 -Wl,-rpath -Wl,$ORIGIN"

    local IDEHelper_Libs
    if is_mode("debug") then
      IDEHelper_Libs = os.iorun("ldd build/linux/x86_64/debug/BeefBoot")
    else
      IDEHelper_Libs = os.iorun("ldd build/linux/x86_64/release/BeefBoot")
    end

    local file = io.open("IDE/dist/IDEHelper_libs.txt", "w")

    -- write shared libs to IDEHelper_libs.txt
    for lib_path in string.gmatch(IDEHelper_Libs, "=> [^%s]+") do
      local lib_path = string.sub(lib_path, 4)
      file:write(lib_path .. "\n")
      LINKOPTS = LINKOPTS .. " " .. lib_path
    end

    -- file will be empty unless we close it first
    file:close()

    if is_mode("debug") then
      os.exec("ln -sf ../../build/linux/x86_64/debug/libBeefRT.a IDE/dist/libBeefRT.a")
      os.exec("ln -sf ../../build/linux/x86_64/debug/libBeefySysLib.so IDE/dist/libBeefySysLib.so")
      os.exec("ln -sf ../../build/linux/x86_64/debug/libIDEHelper.so IDE/dist/libIDEHelper.so")

      os.exec("ln -sf ../../../build/linux/x86_64/debug/libBeefRT.a BeefLibs/Beefy2D/dist/libBeefRT.a")
      os.exec("ln -sf ../../../build/linux/x86_64/debug/libBeefySysLib.so BeefLibs/Beefy2D/dist/libBeefySysLib.so")
      os.exec("ln -sf ../../../build/linux/x86_64/debug/libIDEHelper.so BeefLibs/Beefy2D/dist/libIDEHelper.so")
    else
      os.exec("ln -sf ../../build/linux/x86_64/release/libBeefRT.a IDE/dist/libBeefRT.a")
      os.exec("ln -sf ../../build/linux/x86_64/release/libBeefySysLib.so IDE/dist/libBeefySysLib.so")
      os.exec("ln -sf ../../build/linux/x86_64/release/libIDEHelper.so IDE/dist/libIDEHelper.so")

      os.exec("ln -sf ../../../build/linux/x86_64/release/libBeefRT.a BeefLibs/Beefy2D/dist/libBeefRT.a")
      os.exec("ln -sf ../../../build/linux/x86_64/release/libBeefySysLib.so BeefLibs/Beefy2D/dist/libBeefySysLib.so")
      os.exec("ln -sf ../../../build/linux/x86_64/release/libIDEHelper.so BeefLibs/Beefy2D/dist/libIDEHelper.so")
    end

    local dist_dir = os.projectdir() .. "/IDE/dist/"
    local LINKPARAMS = dist_dir .. "libBeefRT.a " .. dist_dir .. "libIDEHelper.so " .. dist_dir .. "libBeefySysLib.so"
    LINKPARAMS = LINKPARAMS .. " " .. LINKOPTS

    local BeefBoot
    if is_mode("debug") then
      BeefBoot = "build/linux/x86_64/debug/BeefBoot"
    else
      BeefBoot = "build/linux/x86_64/release/BeefBoot"
    end

    os.execv(BeefBoot,
      {
        "--out=IDE/dist/BeefBuild_boot",
        "--src=IDE/src",
        "--src=BeefBuild/src",
        "--src=BeefLibs/corlib/src",
        "--src=BeefLibs/Beefy2D/src",
        "--define=CLI",
        "--startup=BeefBuild.Program",
        "--linkparams=\"" .. LINKPARAMS .. "\""
      })

  end)

target("BeefBoot")
  set_kind("binary")

  add_files("BeefBoot/**.cpp")
  add_deps("IDEHelper", "BeefySysLib", "BeefRT")

  on_load(function (target)
    target:add(find_packages("LLVM-13", "jpeg", "freetype2", "GL"))
  end)

target("BeefRT")
  set_kind("static")

  -- this flag will fix compile error when encountering unrecognized "__cdecl" in c++ files.
  -- needs llvm/clang toolchain (defined at top of file); seems like gcc doesn't support it?
  -- https://github.com/microsoft/vscode-cpptools/issues/3296
  -- https://docs.microsoft.com/en-us/cpp/cpp/cdecl
  add_cxxflags("-fms-extensions")

  add_cxxflags("-fPIC")

  -- taken from CMakeLists.txt for BeefRT
  -- (not sure if this is needed. could not get errors when removing these flags)
  add_cxxflags(
    "-DIDEHELPER_EXPORTS",
    "-DBFSYSLIB_DYNAMIC",
    "-DUNICODE",
    "-D_UNICODE",
    "-DBF_NO_FBX",
    "-DFT2_BUILD_LIBRARY",
    "-DBFSYSLIB_DYNAMIC",
    "-DBFRT_NODBGFLAGS",
    "-DBFRTMERGED")

  add_files("BeefRT/**.cpp")
  remove_files(
    "BeefRT/dbg/DbgThread.cpp",
    "BeefRT/MinRT/MinRT.cpp",
    "BeefRT/TCMalloc/TCMalloc.cpp",
    "BeefRT/JEMalloc/src/jemalloc_cpp.cpp"
  )

  add_files(
    "BeefySysLib/platform/linux/**.cpp",
    "BeefySysLib/Common.cpp",
    "BeefySysLib/util/BeefPerf.cpp",
    "BeefySysLib/util/String.cpp",
    "BeefySysLib/util/UTF8.cpp",
    "BeefySysLib/util/Hash.cpp",
    "BeefySysLib/third_party/utf8proc/utf8proc.c",
    "BeefySysLib/third_party/putty/wildcard.c")

  add_cxxflags("-DBF_DISABLE_FFI")
--[[
  add_deps("libffi")
  add_files("BeefySysLib/third_party/libffi/src/.libs/*.o")

  -- note: if building on non-x86 system is desired, then this line should
  --       be adjusted to pick the appropriate platform inside the "src" folder.
  add_files("BeefySysLib/third_party/libffi/src/x86/.libs/*.o")
--]]

target("BeefySysLib")
  set_kind("shared")

  -- taken from CMakeLists.txt for BeefySysLib
  add_cxxflags(
    "-DIDEHELPER_EXPORTS",
    "-DBFSYSLIB_DYNAMIC",
    "-DUNICODE",
    "-D_UNICODE",
    "-DBF_NO_FBX",
    "-DFT2_BUILD_LIBRARY",
    "-DBFSYSLIB_DYNAMIC",
    "-DBP_DYNAMIC")

  add_files("BeefySysLib/**.cpp|platform/**.cpp") -- add all cpp files except platform-specific ones
  add_files("BeefySysLib/platform/linux/**.cpp") -- add files for the linux platform
  add_files("BeefySysLib/platform/sdl/**.cpp") -- add sdl platform files for the gui/ide
  remove_files("BeefySysLib/FileHandleStream.cpp") -- remove a single windows-specific file from the above set

  add_files("BeefySysLib/third_party/utf8proc/utf8proc.c")
  add_files("BeefySysLib/third_party/miniz/miniz.c")

  on_load(function (target)
    target:add(find_packages("sdl2"))
  end)

target("IDEHelper")
  set_kind("shared")

  -- deactivates exceptions for the toml parser
  add_cxxflags("-DTOML_HAVE_FAILWITH_REPLACEMENT")

  add_files(
    "IDEHelper/BfDiff.cpp",
    "IDEHelper/Debugger.cpp",
    "IDEHelper/DebugManager.cpp",
    "IDEHelper/DebugVisualizers.cpp",
    "IDEHelper/NetManager.cpp",
    "IDEHelper/SpellChecker.cpp",
    "IDEHelper/Targets.cpp",

    -- deactivate the custom X86 backend, since it seems to require the LLVM sources.
    -- "IDEHelper/X64.cpp",
    -- "IDEHelper/X86.cpp",
    -- "IDEHelper/X86Target.cpp",
    "IDEHelper/X86XmmInfo.cpp",

    "IDEHelper/LinuxDebugger.cpp",

    "IDEHelper/Beef/BfCommon.cpp",
    "IDEHelper/Clang/CDepChecker.cpp",
    "IDEHelper/Clang/ClangHelper.cpp",
    "IDEHelper/Compiler/BfAst.cpp",
    "IDEHelper/Compiler/BfAstAllocator.cpp",
    "IDEHelper/Compiler/BfAutoComplete.cpp",
    "IDEHelper/Compiler/BfCodeGen.cpp",
    "IDEHelper/Compiler/BfCompiler.cpp",
    "IDEHelper/Compiler/BfConstResolver.cpp",
    "IDEHelper/Compiler/BfContext.cpp",
    "IDEHelper/Compiler/BfDefBuilder.cpp",
    "IDEHelper/Compiler/BfDeferEvalChecker.cpp",
    "IDEHelper/Compiler/BfDemangler.cpp",
    "IDEHelper/Compiler/BfElementVisitor.cpp",
    "IDEHelper/Compiler/BfNamespaceVisitor.cpp",
    "IDEHelper/Compiler/BfExprEvaluator.cpp",
    "IDEHelper/Compiler/BfIRBuilder.cpp",
    "IDEHelper/Compiler/BfIRCodeGen.cpp",
    "IDEHelper/Compiler/BfMangler.cpp",
    "IDEHelper/Compiler/BfModule.cpp",
    "IDEHelper/Compiler/BfModuleTypeUtils.cpp",
    "IDEHelper/Compiler/BfParser.cpp",
    "IDEHelper/Compiler/BfPrinter.cpp",
    "IDEHelper/Compiler/BfReducer.cpp",
    "IDEHelper/Compiler/BfResolvedTypeUtils.cpp",
    "IDEHelper/Compiler/BfResolvePass.cpp",
    "IDEHelper/Compiler/BfSource.cpp",
    "IDEHelper/Compiler/BfSourceClassifier.cpp",
    "IDEHelper/Compiler/BfSourcePositionFinder.cpp",
    "IDEHelper/Compiler/BfStmtEvaluator.cpp",
    "IDEHelper/Compiler/BfSystem.cpp",
    "IDEHelper/Compiler/BfUtil.cpp",
    "IDEHelper/Compiler/BfVarDeclChecker.cpp",
    "IDEHelper/Compiler/BfTargetTriple.cpp",
    "IDEHelper/Compiler/CeMachine.cpp",
    "IDEHelper/Compiler/CeDebugger.cpp",
    "IDEHelper/Compiler/MemReporter.cpp",

    "IDEHelper/Backend/BeContext.cpp",
    "IDEHelper/Backend/BeIRCodeGen.cpp",
    "IDEHelper/Backend/BeModule.cpp"
  )

  on_load(function (target)
    target:add(find_packages("LLVM-13", "hunspell"))
  end)

--[[
-- TODO xmake already has make-integration: https://xmake.io/#/package/local_3rd_source_library?id=integrated-makefile-source-library
--      this target works well but maybe it would still be easier to use the xmake-integrated facility
target("libffi")
  on_build(function (target)
    -- check if we got libffi already compiled
    if os.isfile("BeefySysLib/third_party/libffi/.libs/libffi.a") then
      do return nil end
    end

    print("Building: libffi")

    local logfile_path = os.projectdir() .. "/BeefySysLib/third_party/libffi/xmake_build.log"
    print("          build log: " .. logfile_path)
    local logfile = io.open(logfile_path, "w")

    print("          configure...")
    os.execv("./configure", {"--disable-builddir"}, { stdout=logfile, curdir="BeefySysLib/third_party/libffi" })

    print("          make...")
    os.execv("make",
      { "-C", "BeefySysLib/third_party/libffi" },
      { stdout=logfile })

    logfile:close()
  end)
--]]
