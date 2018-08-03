// GSD data cleaner-upper using diffs
// no measurements here this uses running median of s frames
//   this one also subtracts the previous processed image once background is removed
// this adds a blur per slice prior to median subtraction to reduce noise a bit more
// and uses 3d gaussian blur at end to decr noise and improve fitting certainty
//V Bindokas, Univ. of Chicago, JULY 2014
 
 s=300;		//median size, 50 seems to work very well
 rr=300;	//refresh rate for median, in frames
 psf=3;	//FWHM of expected PSF, change as desired. DoG high-blur term. 0.5 is low blur term
ti=getTitle();
ns=nSlices();

getDimensions(width, height, channels, slices, frames);

run("Set Measurements...", "area mean min limit redirect=None decimal=3");
newImage("dif", "16-bit black", width, height, ns);
setBatchMode(true);
selectWindow(ti);

run("Z Project...", "start=1 stop=&s projection=Median");
rename("mdn");
i=1;
b=i+rr;

setPasteMode("Subtract");
for (i=1; i<=ns; i++){
  selectWindow(ti);
  setSlice(i);
  run("Duplicate...", "title=a");
  if(i==b){
  	if (isOpen("mdn")){
  		selectWindow("mdn");
  	  	close();}
  	selectWindow(ti);
  	p=i+s;
  	run("Z Project...", "start=&i stop=&p projection=Median");
  	rename("mdn");
  	b=i+rr;
   }
  selectWindow("mdn");
  run("Copy");
  selectWindow("a");
  run("Gaussian Blur...", "radius=0.5 slice");
  setPasteMode("Subtract");
  run("Paste");
  if (i>1){
  	selectWindow("dif");
  	setSlice(i-1); 					//this section subtracts previous events from current image
  	run("Duplicate...", "title=z");	//....because it seemed just copying the frame didn't really work
  	//? use lower radius?
  	run("Gaussian Blur...", "sigma=&psf");   //spot filter using PSF defined above
  	run("Select All");
  	run("Copy");
  	selectWindow("a");
  	run("Paste"); 	
  	selectWindow("z");
    close();
  	   }
  selectWindow("a");
  setPasteMode("Copy");
  run("Select All");
  run("Copy");
  selectWindow("dif");
  setSlice(i);
  run("Paste");
  
  run("Gaussian Blur...", "radius=0.5 slice");		// DENOISE a bit!
  selectWindow("a");
  close();
  }
selectWindow("dif");
rename("dif MDNv8 "+s+"per"+rr+"-"+ti);
//run("Gaussian Blur...", "sigma=0.5 stack");
run("Gaussian Blur 3D...", "x=0.5 y=0.5 z=0.5");
run("Gaussian Blur 3D...", "x=0.5 y=0.5 z=0.5");	//two times... [add 8/10/16]