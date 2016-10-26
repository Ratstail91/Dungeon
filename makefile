#Windows 7:
#RM=del /y

#Windows 8.1, Windows 10:
RM=del /S

OUTDIR=out
BINDIR=bin

all: $(OUTDIR) binary
	$(MAKE) -C TurtleGUI
	$(MAKE) -C TurtleMap
	$(MAKE) -C src

debug: export CXXFLAGS+=-g
debug: clean all

release: export CXXFLAGS+=-static-libgcc -static-libstdc++
release: clean all package

#For use on my machine ONLY
package:
ifeq ($(OS),Windows_NT)
	rar a -r -ep Dungeon-win.rar $(OUTDIR)/*.exe  $(BINDIR)/*.dll
	rar a -r Dungeon-win.rar rsc/* copyright.txt instructions.txt
else ifeq ($(shell uname), Linux)
	tar -C $(OUTDIR) -zcvf Dungeon-linux.tar dungeon ../rsc ../copyright.txt ../instructions.txt
endif

binary: $(OUTDIR)
ifeq ($(OS),Windows_NT)
	xcopy /Y $(BINDIR)\\*.dll $(OUTDIR)
endif

$(OUTDIR):
	mkdir $(OUTDIR)

clean:
ifeq ($(OS),Windows_NT)
	$(RM) *.o *.a *.exe $(OUTDIR)\*.dll
#	rmdir /S /Q $(OUTDIR)
else ifeq ($(shell uname), Linux)
	find . -type f -name '*.o' -exec rm -f -r -v {} \;
	find . -type f -name '*.a' -exec rm -f -r -v {} \;
#	rm $(OUTDIR)/* -f
	find . -empty -type d -delete
endif

rebuild: clean all
