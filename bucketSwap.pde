import processing.sound.*;
import java.util.*;


PImage img;
PImage img2;
int bands = 40;
int num_images = 10;
PImage[] img_array = new PImage[num_images];
PImage[] img_array2 = new PImage[num_images];
Waveform waveform;
AudioIn in;
float[] spectrum = new float[bands];

int[][] colors = new int[bands * bands][3]; 
Vector<Vector<Vector<int[]>>> bucket_sets = new Vector<Vector<Vector<int[]>>>();


void setup() {
  in = new AudioIn(this, 0);
  in.start();
  waveform = new Waveform(this, bands);
  waveform.input(in);
  
  size(displayWidth, displayHeight);
  for (int i = 0; i < bands * bands; i++) {
    int r = floor(random(255));
    int g = floor(random(255));
    int b = floor(random(255));
    int[] col = {r, g, b};
    colors[i] = col;
  }
  for (int a = 0; a < num_images; a++) {
    img_array[a] = loadImage("data2/frame"+a+".jpg");
    //img_array[a] = loadImage("hominid.jpeg");
    img_array[a].resize(displayWidth, displayHeight);
    img_array2[a] = loadImage("data2/frame"+a+".jpg");
    //img_array2[a] = loadImage("hominid.jpeg");
    img_array2[a].resize(displayWidth, displayHeight);
    
    Vector<Vector<int[]>> buckets = new Vector<Vector<int[]>>();
    for (int i = 0; i < bands * bands; i++) {
      Vector<int[]> bucket = new Vector<int[]>();
      buckets.add(bucket); 
    }
    bucket_sets.add(buckets);
  }
  for (int a = 0; a < num_images; a++) {
    for (int x = 0; x < img_array[a].width; x++) {
      for (int y = 0; y < img_array[a].height; y++) {
        float min = 5000;
        int red = int(red(img_array[a].get(x, y)));
        int green = int(green(img_array[a].get(x, y)));
        int blue = int(blue(img_array[a].get(x, y)));
        int index = 0;
        for (int z = 0; z < bands * bands; z++) {
          float d = dist(colors[z][0], colors[z][1], colors[z][2], red, green, blue);
          if (d < min) {
            min = d;
            index = z;
          }
        }
        int[] coord = {x, y};
        bucket_sets.get(a).get(index).add(coord);
      }
    }
  }
}

void draw() {
  frameRate(10);
  waveform.analyze();
  background(0);
  int FC = frameCount % num_images;
  for (int i = 0; i < bands; i++) {
    for (int j = 0; j < bands; j++) {
      float t1 = map(waveform.data[i], -1, 1, -1, 1);
      float t2 = map(waveform.data[j], -1, 1, -1, 1);
      //sensitivity adjustments
      float m = map(t1*t2, -0.1, 0.1, 0, 2*PI);
      float mr = map(log(m), -2000, log(2*PI), 0, 1);
      float mg = map(sin(m), -0.1, 0.1, 0, 1);
      float mb = map(cos(m)*sin(m), -0.1, 0.1, 0, 1);
      
      for (int k = 0; k < bucket_sets.get(FC).get(i + j * bands).size(); k++) {
        int x = bucket_sets.get(FC).get(i + j * bands).get(k)[0];
        int y = bucket_sets.get(FC).get(i + j * bands).get(k)[1];
        color c = img_array2[FC].get(x, y);
        img_array[FC].set(x, y, color(int(mr*red(c)), int(mg*green(c)), int(mb*blue(c))));
      }
    }
  }
  image(img_array[FC], 0, 0);
}
