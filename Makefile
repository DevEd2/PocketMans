PROJECTNAME=mans_cgb

%.asm: ;
%.inc: ;
%.bin: ;
$(PROJECTNAME).gbc: %.asm %.inc %.bin
	rgbasm -o $(PROJECTNAME).obj -p 255 Main.asm
	rgblink -p 255 -o $(PROJECTNAME).gbc -n $(PROJECTNAME).sym $(PROJECTNAME).obj
	rgbfix -v -p 255 $(PROJECTNAME).gbc
	md5sum $(PROJECTNAME).gbc

clean:
	find . -type f -name "*.gbc" -delete
	find . -type f -name "*.sym" -delete
	find . -type f -name "*.obj" -delete
	