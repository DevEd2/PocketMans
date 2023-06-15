PROJECTNAME=mans_cgb

$(PROJECTNAME).gbc: gfx
	rgbasm -H -o $(PROJECTNAME).obj -p 255 Main.asm
	rgblink -p 255 -o $(PROJECTNAME).gbc -n $(PROJECTNAME).sym $(PROJECTNAME).obj
	rgbfix -v -p 255 $(PROJECTNAME).gbc
	md5sum $(PROJECTNAME).gbc

clean:
	find . -type f -name "*.gbc" -delete
	find . -type f -name "*.sym" -delete
	find . -type f -name "*.obj" -delete
	find GFX/Mans/Front/ -type f -name "*.png.wle" -delete
	find GFX/Mans/Back/ -type f -name "*.png.wle" -delete
	
gfx:
	./convertsprites.sh