import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import controlP5.*;

Capture video;
OpenCV opencv;
ArrayList<Contour> contours;
Contour contour;
PImage original, outImage;
PImage hitEffect;
ControlP5 slider, slider2, button;
int W=640;
int H=480;
int Hue_MinValue=5;
int Hue_MaxValue=20;
int isFlip=1;

Mogura[] moguras =new Mogura[5];
int score=0;
int timer, startTime;
int timerflag=0;
int time=60;
int isGameStart=0;

void setup(){
  String[] cams = Capture.list();
  video = new Capture(this, W, H, cams[0]);
  video.start();
  opencv = new OpenCV(this, video.width, video.height);
  size(960, 480);
  int x=20;
  for(int i=0; i<5; i++){
       moguras[i]=new Mogura(x, 400);
       x+=120;
  }
  hitEffect = loadImage("hit.png");
  frameRate(120);
  slider = new ControlP5(this);
  slider.addSlider("Hue_MinValue",0,180,Hue_MinValue,650,120,200,20);
  slider2 = new ControlP5(this);
  slider2.addSlider("Hue_MaxValue",0,180,Hue_MaxValue,650,150,200,20);
  button = new ControlP5(this);
  button.addButton("flip").setPosition(700, 200);  //call flip() function when button down
}

void draw(){
  background(color(0,0,0));
  if (video.available()) {
    video.read();
  }
  opencv.loadImage(video);
  opencv.useColor();
  if(isFlip==1)opencv.flip(1);
  original = opencv.getSnapshot();
  image(original, 0, 0);
  
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(Hue_MinValue, Hue_MaxValue);
  outImage = opencv.getSnapshot();
  //image(outImage, W, 0);
  opencv.loadImage(outImage);
  
  
  contours=opencv.findContours(false,true);  
  if(isGameStart==0 || contour==null){
    strokeWeight(2); 
    noFill();                                      
    stroke(255,0,0);
    for (int i=0; i<contours.size(); i++) {
      contours.get(i).draw();
    }
  }
  else if(isGameStart==1){
    if(contour != null){
      float a=100000000.0;
      Contour cc=null;
      for (int i=0; i<contours.size(); i++) {        
          Contour c=contours.get(i);  
          Rectangle b=c.getBoundingBox();
          Rectangle box=contour.getBoundingBox();
          if(a>dist(b.x,b.y,box.x,box.y) && c.area()>1000){
               cc=c;
               a=dist(b.x,b.y,box.x,box.y);
          }
      }
      if(cc != null){
          contour=cc;
          println("not null");
          strokeWeight(2); 
          noFill();                                      
          stroke(0,0,255);
          contour.draw();
      }
      else {contour=null;println("null");}
    }
    else{println("null");}
  }
  
  for(int i=0; i<5; i++){
       moguras[i].anim();   
       if(moguras[i].hitCheeck(contour)==1 && moguras[i].hit==0){
           score+=1;
           moguras[i].hit+=1;
       }
       if(moguras[i].hit>0 && moguras[i].hit<=5){
         moguras[i].hit+=1;
         image(hitEffect, moguras[i].xpos, moguras[i].ypos-50, 100, 100);
       }
  }
  fill(255,0,0);
  textSize(30);
  if(timerflag==1)timer = millis();
  text("TIME: ",650,50);
  if((timer-startTime)/1000>time)text(0,770,50);
  else text(time-(timer-startTime)/1000,770,50);
  text("SCORE: ",650,100);
  text(score,770,100);
  fill(0, 255,0);
  if(timerflag==1 && (timer-startTime)/1000<=2){text("START!",W/2-30,50);}
  else if(timerflag==1 && (timer-startTime)/1000>time){text("FINISH!",W/2-40,50);}
}

void flip(){
  if(isFlip==1){isFlip=0;}
  else isFlip=1;
}

void mousePressed(){  
    for (int i=0; i<contours.size(); i++) { 
        Contour c=contours.get(i); 
        if(c.containsPoint(mouseX, mouseY)){
             contour=c;
             if(timerflag==0){startTime = millis(); timerflag=1; isGameStart=1;}
             break ;
        }
    }
}

class Mogura{
     PImage img=loadImage("mogura.png");
     PImage img2=loadImage("moguraHit.png");
     int xpos, ypos, xp, yp;
     float interbaltime;
     float apperTime=2.0*1000;
     int t;
     int hit=0;//hit<0 -> lock, hit==0 -> noHit, hit>0 -> hit
     
     Mogura(int x, int y){
          xpos=x;
          ypos=y;
          xp=x;
          yp=y;
          interbaltime=random(2.0, 5.0)*1000;
          float tt=apperTime+interbaltime+1000;
          t=(int)tt;
     }
     
     void anim(){
         int timer = millis();
        
         //hided
         if(timer%t>=0 && timer%t<interbaltime){
           ypos=yp; hit=-1;
         }
         //appering
         else if(timer%t>=interbaltime && timer%t<interbaltime+500){
           ypos-=8; 
           if(hit<=0)hit=0;
         }
         //appered
         else if(timer%t>=interbaltime+500 && timer%t<interbaltime+500+apperTime){
           ypos=yp-80; 
           if(hit<=0)hit=0;
         }
         //hiding
         else if(timer%t>=interbaltime+500+apperTime){
           ypos+=8; 
           if(hit<=0)hit=0;
         }
         if(hit<=0)image(img,xpos,ypos,100,100);
         else image(img2,xpos-15,ypos,130,100);
         fill(111,51,16);
         noStroke();
         rect(xp, yp+20, 100, 80);
     }
     
     int hitCheeck(Contour c){
         if((timer-startTime)/1000>time){return 0;}
          if(c!=null && c.containsPoint(xpos+50,ypos)){
               return 1;   
          }
          else return 0;
     }
}
