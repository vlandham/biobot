output = _output
rnwfile = Sweave_coverage
backup = _backup
distribute_prefix = interval

all:clean build output tex distribute

build: 
	R CMD Sweave $(rnwfile).Rnw

output:
	-mkdir $(output)
	-cp *.sty $(output)
	-mv *.tex *.pdf *.eps $(output)

tex:
	cd $(output); rubber --pdf $(rnwfile).tex

distribute:
	cp $(output)/${rnwfile}.pdf ../$(distribute_prefix)_coverage_report.pdf

clean:
	-rm $(output)/*
	
backup:
	-mkdir $(backup)
	cp 	$(output)/$(rnwfile).pdf $(backup)/$(rnwfile).pdf 
