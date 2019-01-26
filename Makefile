dirs = opl3 opn2
paks = $(foreach dir,$(dirs),banks-$(dir).pak)

all: $(paks)

clean:
	rm -f $(paks)

banks-%.pak: pak-banks.sh
	./pak-banks.sh $* > banks-$*.pak
