TANGLE := tangle

.PHONY : all
all : patgen

patgen.ch patgen.web :
	curl -o $@ "https://raw.githubusercontent.com/mojca/xetex/2f43a4329b/TeX/texk/web2c/$(notdir $@)"

patgen.p : %.p : %.web
	$(TANGLE) $<

patgen.c.tmp : patgen.p p2c/p2c-2.01/install/usr/bin/p2c
	p2c/p2c-2.01/install/usr/bin/p2c $< -o $@

patgen.c : % : %.tmp %.patch
	patch -o $@ $^

patgen.o : %.o : %.c p2c/p2c-2.01/install/usr/include/p2c/p2c.h
	cc -o $@ -I./p2c/p2c-2.01/install/usr/include -c $<

patgen : patgen.o p2c/p2c-2.01/install/usr/lib/libp2c.a
	cc -o $@ -L./p2c/p2c-2.01/install/usr/lib $< -lp2c

.PHONY : check
check : patgen
	cd test && \
	bash ../patgen.sh dictionary \
	                  patterns \
	                  patout.1 \
	                  translate \
	                  1 1 1 1 15 1 100 1
	cd test && \
	bash ../patgen.sh pattmp.1 \
	                  patout.1 \
	                  patout.2 \
	                  translate \
	                  1 1 2 1 15 1 100 1
	diff test/patout.2 test/patout.expected && \
	! grep '\.[^0]\|-' test/pattmp.2;
	e=$$?; \
	rm test/patout.{1,2} test/pattmp.{1,2}; \
	exit $$e

.PHONY : clean
clean :
	rm -f patgen patgen.o patgen.c patgen.c.tmp patgen.p patgen.ch patgen.web

# --------------
# p2c
# --------------

p2c/p2c-2.01/install/usr/bin/p2c \
p2c/p2c-2.01/install/usr/include/p2c/p2c.h \
p2c/p2c-2.01/install/usr/lib/libp2c.a : | \
		p2c/p2c-2.01 \
		p2c/p2c-2.01/install/usr/lib/p2c \
		p2c/p2c-2.01/install/usr/include/p2c \
		p2c/p2c-2.01/install/usr/bin \
		p2c/p2c-2.01/install/usr/lib \
		p2c/p2c-2.01/install/usr/man/man1
	cd p2c/p2c-2.01/src && \
	make HOMEDIR=../install/usr/lib/p2c \
	     INCDIR=../install/usr/include/p2c \
	     BINDIR=../install/usr/bin \
	     LIBDIR=../install/usr/lib \
	     MANDIR=../install/usr/man/man1 \
	     MANFILE=p2c.man.inst \
	     install || \
	( rm -rf p2c/p2c-2.01/install && exit 1 )

p2c/p2c-2.01 : | p2c/p2c-2.01.tar.gz
	cd p2c && \
	gtar -xzvf p2c-2.01.tar.gz && \
	patch -p1 < p2c-2.01.patch

# see also https://github.com/FranklinChen/p2c
p2c/p2c-2.01.tar.gz :
	curl -L -o $@ "https://alum.mit.edu/www/toms/p2c/p2c-2.01.tar.gz"

p2c/p2c-2.01/install/usr/lib/p2c \
p2c/p2c-2.01/install/usr/include/p2c \
p2c/p2c-2.01/install/usr/bin \
p2c/p2c-2.01/install/usr/lib \
p2c/p2c-2.01/install/usr/man/man1 :
	mkdir -p $@

clean : clean-p2c
.PHONY : clean-p2c
clean-p2c :
	rm -rf p2c/p2c-2.01/install
	if [ -e p2c/p2c-2.01 ]; then \
		cd p2c/p2c-2.01/src && \
		make clean; \
	fi
