DEST=/usr/local/bin/tos

install:
	mkdir -p $(dir $(DEST))
	cp ./tos.sh $(DEST)

unstall:
	rm -f $(DEST)

.PHONY: install unstall
