// Original idea by Milan Karakaš, 2016, https://wildlab.org
// https://wildlab.org/index.php/arduino-ulstrasonic-radar/
// Revision 0.99 - sorry, but not yet cleaned for not used parts
// some old stuff remained, because had hard time to figure out
// how to work in Processing. Many notes are in Croatian.
// Thanks for understanding.

import processing.serial.*;

int SIDE_LENGTH = 1000;
int ANGLE_BOUNDS = 80;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 10;
int POINTS_HISTORY_SIZE = 500;
int MAX_DISTANCE = 100;

int angle;
int distance;
int[] echoes = new int[40]; //možda array treba samo "int[] echoes"??? 
//Echo[] echoes; //možda bi ovo bio pravilniji array?! treba samo dodati to u class dolje

int radius;
float x, y;
float leftAngleRad, rightAngleRad;

float[] historyX, historyY;
Point[] points; //ovo je primjer više točaka, no samo jedna je "prošla" kroz funkciju (angle, ->distance)

int centerX, centerY;

String comPortString;
Serial myPort;

void setup() {
  size(1024, 600, P2D);
  noStroke();
  //smooth();
  rectMode(CENTER);
background(0);
  radius = SIDE_LENGTH / 2;
  centerX = width / 2;
  centerY = height;
  angle = 0;
  leftAngleRad = radians(-ANGLE_BOUNDS) - HALF_PI;
  rightAngleRad = radians(ANGLE_BOUNDS) - HALF_PI;

  historyX = new float[HISTORY_SIZE];
  historyY = new float[HISTORY_SIZE];
  points = new Point[POINTS_HISTORY_SIZE];

  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.bufferUntil('\n'); // Trigger a SerialEvent on new line
}


void draw() //ovo je totalno okay, ne diraj
{
  //background(0);
//  drawRadar(); //ovo ispisuje radarski ekran (mrežu), ali ne i točke
  drawFoundObjects(angle, echoes); //bilo je: drawFoundObjects(angle, distance);
//  drawRadarLine(angle); //mislim da je ovo nepromijenjeno, no... dali to briše stare točke?
}

void drawRadarLine(int angle) //ovo radi dobro i trebat će donekle
{
  float radian = radians(angle);
  x = radius * sin(radian);
  y = radius * cos(radian);
  float px = centerX + x;
  float py = centerY - y;
  historyX[0] = px;
  historyY[0] = py;
  for (int i=0; i<HISTORY_SIZE; i++) 
  {
    stroke(50, 150, 50, 255 - (25*i));
    line(centerX, centerY, historyX[i], historyY[i]);
  }
  shiftHistoryArray();
}

void drawFoundObjects(int angle, int echoes[]) //bilo je: void drawFoundObjects(int angle, int distance) 
{
  int n;
//   int distance =500; // mimicking, imitiram kao da je odjek na "200" nečega
//ovdje je bila formula za test, maknuo dolje jer je nestala ako je broj veći od 0
for ( n=1;n<40;n++)
{
float distance = n*12.5; 
  if (distance > 0) 
  {
    float radian = radians(angle);
    x = distance * sin(radian);
    y = distance * cos(radian);
    int px = (int)(centerX + x);
    int py = (int)(centerY - y);
    points[0] = new Point(px, py); //bilo je: points[0] = new Point(px, py);
  } else 
  {
    points[0] = new Point(0, 0);
  }
    for (int i=0; i<POINTS_HISTORY_SIZE; i++) //mislim da je ovo definitivno jeba koja briše stare točke
  {
    Point point = points[i];//bilo je: Point point = points[i];
    if (point != null) 
    {
      int x = point.x;
      int y = point.y;  
      if (x==0 && y==0) continue;
      //int colorAlfa = (int)map(i, 0, POINTS_HISTORY_SIZE, 20, 0); //ovo je izgleda dio koji "briše" stare točke, treba maknuti
      
     //  int size = (int)map(i, 0, POINTS_HISTORY_SIZE, 30, 5);
      fill(echoes[n]); //ovdje bi trebao "sjesti" paremetar o jačini odjeka umjesto "255, ->15": fill(50, 150, 50, colorAlfa);
      //ali colorAlfa "pojačava" stari trag. Ako se to ne želi, onda treba raditi bez alfe i "modulirati" prvi broj
      noStroke();
      ellipse(x, y, 15, 15); //maknuti smanjivanje točaka: ellipse(x, y, size, size);
      /* temporary comfirmation that "echoes[]" are passing through void. YES!!!! SUCCESS!!!
     for (int n=1; n<40; n++)
      {
        text("brojevi: " +  echoes[n],10,17*n);
        println("br: " + echoes[n]); //ovo radi, samo sada treba "vratiti" vrijednosti za iscrtavanje točaka
        //ispisivalo je dolje korektne vrijednosti, samo da nađem ...
      } */
    }
 }

  // shiftPointsArray();
}}

void drawRadar() //ovo je izgleda ok, za sada ne diraj
{
  stroke(100);
  noFill();

  // part of the circle distance from the center
  for (int i = 0; i <= (SIDE_LENGTH / 100); i++) {
    arc(centerX, centerY, 100 * i, 100 * i, leftAngleRad, rightAngleRad);
  }

  // angle indicators
  for (int i = 0; i <= (ANGLE_BOUNDS*2/20); i++) {
    float angle = -ANGLE_BOUNDS + i * 20;
    float radAngle = radians(angle);
    line(centerX, centerY, centerX + radius*sin(radAngle), centerY - radius*cos(radAngle));
  }
}

void shiftHistoryArray() {

  for (int i = HISTORY_SIZE; i > 1; i--) {

    historyX[i-1] = historyX[i-2];
    historyY[i-1] = historyY[i-2];
  }
}

void shiftPointsArray(){}//ovo treba izbaciti ZAUVIJEK!!!
/*{
  for (int i = POINTS_HISTORY_SIZE; i > 1; i--) {

    Point oldPoint = points[i-2];
    if (oldPoint != null) {

      Point point = new Point(oldPoint.x, oldPoint.y);
      points[i-1] = point; //ovo nedostaje gore?
    }
  }
}*/

void serialEvent(Serial cPort) 
{

  comPortString = cPort.readString();
  if (comPortString != null) 
  {

    comPortString=trim(comPortString);
    String[] values = split(comPortString, ',');
    try 
    {
      angle = Integer.parseInt(values[0]); //ovo razjebati
      //distance = int(map(Integer.parseInt(values[1]), 1, MAX_DISTANCE, 1, radius)); //ovo treba razjebati i preopraviti
      //ovdje ću početi razjebavati
      //println("brojevi su:");
      
      for (int n=1; n<40; n++) //nikako "0", jer je to kut - sve ostalo su analogne vrijednosti od 0-255
      {
        echoes[n]= Integer.parseInt(values[n]);
        //textSize(12);
        //fill(255);
        //text("brojevi: " +  echoes[n],10,17*n);
        //println("br: " + echoes[n]); //ovo radi, samo sada treba "vratiti" vrijednosti za iscrtavanje točaka
        //ispisivalo je dolje korektne vrijednosti, samo da nađem ...
      }
    } 
    catch (Exception e) {}
  }

}

class Point {
  int x, y;

  Point(int xPos, int yPos) {
    x = xPos;
    y = yPos;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }
}
