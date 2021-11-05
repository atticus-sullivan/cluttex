all: bin/cluttex bin/cluttex.bat

.PHONY: all archive

sources= \
 src/texrunner/pathutil.lua \
 src/texrunner/pathutil_unix.lua \
 src/texrunner/pathutil_windows.lua \
 src/texrunner/shellutil.lua \
 src/texrunner/shellutil_unix.lua \
 src/texrunner/shellutil_windows.lua \
 src/texrunner/fsutil.lua \
 src/texrunner/option.lua \
 src/texrunner/tex_engine.lua \
 src/texrunner/reruncheck.lua \
 src/texrunner/auxfile.lua \
 src/texrunner/luatexinit.lua \
 src/texrunner/recovery.lua \
 src/texrunner/handleoption.lua \
 src/texrunner/isatty.lua \
 src/texrunner/message.lua \
 src/texrunner/fswatcher_windows.lua \
 src/texrunner/safename.lua \
 src/texrunner/checkdriver.lua \
 src/cluttex.lua

bin/cluttex: $(sources) build.lua
	@mkdir -p bin
	lua build.lua --unix-shellscript $@
	lua checkglobal.lua $@
	chmod +x $@

bin/cluttex.bat: $(sources) build.lua
	@mkdir -p bin
	lua build.lua --windows-batchfile $@
	lua checkglobal.lua $@

archive: all
	git archive --format=tar --prefix=cluttex/ -o cluttex.tar HEAD
	gzip -k9 cluttex.tar
