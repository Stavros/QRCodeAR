import processing.video.*;
import com.google.zxing.*;
import java.awt.image.BufferedImage;

/*
 QRcode reader and AR
 
 Augment real time video from a camera with generated images based on a QRcode recognition
 
 Created on Oct 2012 by Stavros Kalapothas (stavros@ubinet.gr)
 */
 
Capture cam; //Set up the camera
com.google.zxing.Reader reader = new com.google.zxing.qrcode.QRCodeReader();

int WIDTH = 1280;
int HEIGHT = 720;

PImage cover;  //This will have the cover image
String lastISBNAcquired = "";  //This is the last ISBN we acquired

// Grabs the image file    

void setup() {
  size(1280, 720);
    PFont metaBold;
  // The font "Meta-Bold.vlw" must be located in the 
  // current sketch's "data" directory to load successfully
  metaBold = loadFont("SansSerif-48.vlw");
  textFont(metaBold, 36); 

  cam = new Capture(this, WIDTH, HEIGHT);
}
 

void draw() {
  if (cam.available() == true) {
    cam.read();    
    image(cam, 0,0);
    try {
       // Now test to see if it has a QR code embedded in it
       LuminanceSource source = new BufferedImageLuminanceSource((BufferedImage)cam.getImage());
       BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));       
       Result result = reader.decode(bitmap); 
       //Once we get the results, we can do some display
       if (result.getText() != null) { 
          println(result.getText());
          ResultPoint[] points = result.getResultPoints();
          //Draw some ellipses on at the control points
          for (int i = 0; i < points.length; i++) {
            fill(#ff8c00);
            ellipse(points[i].getX(), points[i].getY(), 20,20);
            fill(#ff0000);
            text(i, points[i].getX(), points[i].getY());
          }
          //Now fetch the book cover, if it is found
          if (!result.getText().equals(lastISBNAcquired)) {
             String url = "http://www.plaisio.gr/ProductImages/250x250/" + result.getText() + ".jpg"; 
             try {
                cover = loadImage(url,"gif");
                lastISBNAcquired = result.getText();
             } catch (Exception e) {
               cover = null;
             }
          }
          //Superimpose the cover on the image
          if (cover != null) {
            image(cover, points[1].getX(), points[1].getY());
          }
       }
    } catch (Exception e) {
//         println(e.toString()); 
    }
  }
}