/* CSci-5609 Assignment 2: Visualization of Paafu Kinship Ties for the Islands of Micronesia //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
 */

// === GLOBAL DATA VARIABLES ===

// Raw data tables & objects
Table locationTable;
Table populationTable;
PaafuDirections paafuDirections;

// Derived data: kinships based on Paafu directions
KinshipTies kinshipTies;


// Derived data: mins and maxes for each data variable
float minLatitude, maxLatitude;
float minLongitude, maxLongitude;
float minPop1980, maxPop1980;
float minPop1994, maxPop1994;
float minPop2000, maxPop2000;
float minPop2010, maxPop2010;
float minArea, maxArea;

float minPopYear1980Den = 10000;
float minPopYear1994Den = 10000;
float minPopYear2000Den = 10000;
float minPopYear2010Den = 10000;
float maxPopYear1980Den = 0.0;
float maxPopYear1994Den = 0.0;
float maxPopYear2000Den = 0.0;
float maxPopYear2010Den = 0.0;

String selectedYear = "";
boolean showPopDen = false;

// Graphics and UI variables
PanZoomMap panZoomMap;
PFont labelFont;
String highlightedMunicipality = "";
String selectedMunicipality = "Romanum";
String islandInput1 = "";
String islandInput2 = "";

String selectedState = "all";

color chartColor1 = color(255);
color chartColor2 = color(255);

// for dropdown list
import controlP5.*;

// import required library
import java.util.Collections;
import java.util.Arrays;

//Table selectedInfoTable;
Textarea infoText;

ControlP5 controlP5;
DropdownList overview;
DropdownList stateDropdown;
DropdownList filter;

DropdownList inputDropdown1;
DropdownList inputDropdown2;

Chart compareChart;
Chart filterChart;

//Button showPopDenBtn = new Button();

// Button Status after click 'Filter'
boolean unclickFilterButtons = true;
boolean checkFilterResult = false;
boolean compareClicked = false;
Button[] buttons = new Button[4];
DropdownList[] dropdowns = new DropdownList[3];

String selectedmuniOption = "Romanum";
String selectedyearOption = "1980";
String selectedorderOption = "Ascending";

String[] items = {"YAP", "CHU", "KOS", "POH"};

String[] muniNames; 
ArrayList<Float>[] yearData; 

// 0 for button, 1 for dropdown list
int[] buttonOrDropList = new int[]{0, 1, 1, 0, 1};

String info = "";
float infoTableX = 0.0;
float infoTableY = 0.0;

float imgX = 0;
float imgY = 0;

PImage islandImg;
String imgPath = "micro.jpeg";
boolean showIslandImg = false;

// === PROCESSING BUILT-IN FUNCTIONS ===

void setup() {
  // size of the graphics window
  size(1400, 800); // 1600, 900

  // load data in from disk
  loadRawDataTables();
  paafuDirections = new PaafuDirections();

  // compute derived data
  // combine the location and direction data to identify Paafu-style kinship ties
  kinshipTies = new KinshipTies(paafuDirections, locationTable);

  // do any other data processing, e.g., finding mins and maxes for data variables
  computeDerivedData();

  // these coordinates define a rectangular region for the map that happens to be
  // centered around Micronesia
  panZoomMap = new PanZoomMap(5.2, 138, 10.0, 163.1);
  //panZoomMap = new PanZoomMap(1.2, 130, 10.0, 173.1);

  // these initial values provide a good view of Chuuk Lagoon, but you can
  // comment these out to start with all of the data on the screen
  //panZoomMap.scale = 87430.2;
  //panZoomMap.translateX = -47255.832;
  //panZoomMap.translateY = -43944.914;
  panZoomMap.translateX = 110;
  panZoomMap.translateY = 10;

  labelFont = loadFont("Futura-Medium-18.vlw");


  // set the dropdown lists
  frameRate(30);
  controlP5 = new ControlP5(this);

  controlP5.addButton("micronesianOverview")
    .setValue(0)
    .setPosition(50, 50)
    .setSize(120, 25)
    .activateBy(ControlP5.PRESSED);

  controlP5.addButton("Year1980")
    .setValue(0)
    .setPosition(310, 50)
    .setSize(60, 25);

  controlP5.addButton("Year1994")
    .setValue(0)
    .setPosition(380, 50)
    .setSize(60, 25);
  
  controlP5.addButton("Year2000")
    .setValue(0)
    .setPosition(450, 50)
    .setSize(60, 25);
  
  controlP5.addButton("Year2010")
    .setValue(0)
    .setPosition(520, 50)
    .setSize(60, 25);
    
  controlP5.addButton("ShowPopDensity")
      .setValue(0)
      .setPosition(310, 100)
      .setSize(150, 25)
      .setCaptionLabel("Show Population density");
      
    
  controlP5.addDropdownList("State")
     .setPosition(600, 50)
     .setSize(100, 190)
     .setBarHeight(25)
     .setItemHeight(25)
     .addItems(items)
     .setCaptionLabel("Select a state");
     
     
 controlP5.addButton("ClearState")
    .setValue(0)
    .setPosition(720, 50)
    .setSize(100, 25)
    .setCaptionLabel("Clear state selection");
    

  // set the table for selected municipality
  infoText = controlP5.addTextarea("txt")
    .setPosition(0, 0)
    .setSize(330, 170)
    .setLineHeight(14)
    .disableColorBackground()
  ;

  infoText.setText("");
  
  // set up the user inputs for comparing two islands, filter islands (1020, 10)
  
  inputDropdown1 = controlP5.addDropdownList("island1")
    .setPosition(1020, 55)
    .setSize(120, 200)
    .setBarHeight(30)
    .setItemHeight(25)
  ;

  inputDropdown2 = controlP5.addDropdownList("island2")
   .setPosition(1150, 55)
   .setSize(120, 200)
   .setBarHeight(30)
   .setItemHeight(25)
  ;
  
  for (int i=0; i<locationTable.getRowCount(); i++) {
      TableRow rowData = locationTable.getRow(i);
      String municipalityName = rowData.getString("Municipality");
      println(municipalityName);
      inputDropdown1.addItem(municipalityName, i);
      inputDropdown2.addItem(municipalityName, i);
  }
  
  
  controlP5.addButton("Compare")
    .setPosition(1290, 55)
    .setSize(80, 15)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
  ;
  
  controlP5.addButton("Clear")
    .setPosition(1290, 75)
    .setSize(80, 15)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
  ;



  
}

void draw() {
  // clear the screen
  background(230);
  PImage img;
  img = loadImage("micro.jpeg");
  img.resize(1400, 800);
  background(img);

  overviewUI(selectedYear, showPopDen);

  if(compareClicked){
    createPlots(islandInput1, islandInput2);
    }
  
  islandImg = loadImage(imgPath);
  if (showIslandImg)
    image(islandImg, imgX, imgY, 330, 100); //<>//
   
}


void island1(ControlEvent event) {
  String[] munData = getColumnData(populationTable, "Municipality");
  if (event.isFrom("island1")) {
    islandInput1 = munData[(int)event.getController().getValue()];
    println("Selected island1 input: " + munData[(int)event.getController().getValue()]);
  }
}


void island2(ControlEvent event) {
  String[] munData = getColumnData(populationTable, "Municipality");
  if (event.isFrom("island2")) {
    islandInput2 = munData[(int)event.getController().getValue()];
    println("Selected island2 input: " + munData[(int)event.getController().getValue()]);
  }
}

// get the state selected
void State(ControlEvent event) { //<>//
  String[] states = {"YAP", "CHU", "KOS", "POH"};
  
  if (event.isFrom("State")) {
    selectedState = states[(int)event.getController().getValue()];
    println("Selected State: " + selectedState);
  }
}

// event handler when clicking compare button
public void Compare(int theValue) {
  println("Compare button is clicked");
  // call functions to show compared results
  compareClicked =true;

  chartColor1 = color(255,0,0);
  chartColor2 = color(0,0,255);
}

// event handler when clicking clear button
public void Clear(int theValue) {
  println("clear button is clicked");
  compareChart.hide(); // hide the compare res chart
  islandInput1 = "";
  islandInput2 = "";


  chartColor1 = color(255);
  chartColor2 = color(255);
  compareClicked=false;
  //inputDropdown1.clear();
  //inputDropdown2.clear();
}

public void ClearState(int theValue) {
  selectedState = "all";
}

// event handler when clicking 1980 button
public void Year1980(int theValue) {
  println("1980 button is clicked");
  // call functions to show compared results
  selectedYear = "Population 1980 Census";
}

// event handler when clicking 1980 button
public void Year1994(int theValue) {
  println("1994 button is clicked");
  // call functions to show compared results
  selectedYear = "Population 1994 Census";
}

// event handler when clicking 1980 button
public void Year2000(int theValue) {
  println("2000 button is clicked");
  // call functions to show compared results
  selectedYear = "Population 2000 Census";
}

// event handler when clicking 1980 button
public void Year2010(int theValue) {
  println("2010 button is clicked");
  // call functions to show compared results
  selectedYear = "Population 2010 Census";
}

public void ShowPopDensity(int theValue) {
  //showPopDenBtn.show();
  showPopDen = true;
}


// comparison results of two islands - user inputs after clicking compare button
void showCompareRes(String island1, String island2) {
  //text("Compared results:", 1020, 100);
  compareChart.show();
  compareChart.addDataSet("world");
  compareChart.setColors("world", color(255,0,255),color(255,0,0));
  compareChart.setData("world", new float[4]);
  compareChart.setStrokeWeight(1.5);
}


// for customize the dropdown menu
void customizeDropdown(DropdownList ddl, String name) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(25);
  ddl.setBarHeight(25);

  if (name == "state") {
    ddl.addItem("YAP", 0);
    ddl.addItem("CHU", 1);
    ddl.addItem("KOS", 2);
    ddl.addItem("POH", 3);
  }

  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}



// function colorA will receive changes from
// controller with name Micronesian Overview
public void micronesianOverview(int theValue) {
  println("a button event from micronesianOverview: "+ theValue); // 0
}


void showMap(boolean showDen, String popYear, float minPopYear, float maxPopYear, color lowestPopulationColor, color highestPopulationColor, float minRadius, float maxRadius) {
  // Municipalities should highlight (i.e., change appearance in some way) whenever the mouse is hovering
  // over them so the user knows something will happen if they click.  If they do click while a municipality
  // is highlighted, then that municipality becomes the selectedMunicipality and the visualization should
  // update to show kinship relationships for it.
  highlightedMunicipality = getMunicipalityUnderMouse();

  // draw the bounds of the map
  fill(250);
  stroke(111, 87, 0);
  rectMode(CORNERS);
  float mapX1 = panZoomMap.longitudeToScreenX(138.0);
  float mapY1 = panZoomMap.latitudeToScreenY(5.2);
  float mapX2 = panZoomMap.longitudeToScreenX(163.1);
  float mapY2 = panZoomMap.latitudeToScreenY(10.0);
  rect(mapX1, mapY1, mapX2, mapY2);
  int rows = 0;
  int[] RowIndicesForState = TableUtils.findRowIndicesForState(populationTable, selectedState);
  
  if (selectedState=="all"){
    rows = locationTable.getRowCount();
  } else {
    rows = RowIndicesForState.length;
  }
  
  for (int i=0; i<rows; i++) {
    int idx = 0;
    if(selectedState=="all"){
      idx = i;
    } else {
      idx = RowIndicesForState[i];
    }
    TableRow rowData = locationTable.getRow(idx);
    String municipalityName = rowData.getString("Municipality");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);

    // lat,long code above is the same as part A.  if we also get the municipality name
    // for this row in the location table, then we can look up population data for the
    // municipality in the population table
    TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
    int popuYear = popRow.getInt(popYear);
    int area = popRow.getInt("Area");

    // normalize data values to a 0..1 range
    float popuYear_01;

    popuYear_01 = (popuYear - minPopYear) / (maxPopYear - minPopYear);
    
    // encode population density with color
    if (showDen) {
      // 
      //popuYear_01 = (popuYear - minPopYear) / (maxPopYear - minPopYear);
    }

    
    float area_01 = (area - minArea) / (maxArea - minArea);

    // two examples using lerp*() to map the data values to changes in visual attributes

    // 1. adjust the radius of the island in proportion to its area
    float radius = lerp(minRadius, maxRadius, area_01);

    // 2. adjust the fill color in proportion to the population
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, popuYear_01);
    fill(c);

    noStroke();
    ellipseMode(RADIUS);

    // highlight the circle if highlightedMunicipality == its name
    // also show detailed info of hovered municipality
    if (highlightedMunicipality == municipalityName) {
      fill(0, 0, 255);
      circle(screenX, screenY, radius);
      textAlign(LEFT, CENTER);
      float xTextOffset = radius + 4; // move the text to the right of the circle
      text(municipalityName, screenX + xTextOffset, screenY);
    } else {
      circle(screenX, screenY, radius);
      textAlign(LEFT, CENTER);
      float xTextOffset = radius + 4; // move the text to the right of the circle
      fill(111, 87, 0);
      text(municipalityName, screenX + xTextOffset, screenY);
    }
  }
}

// when user clicks "Micronesia overview button"
void overviewUI(String popYear, boolean showDen) {

  // defined in screen space, so the circles will be the same size regardless of zoom level
  float minRadius = 3;
  float maxRadius = 28;

  color lowestPopulationColor = color(255, 224, 121);
  color highestPopulationColor = color(232, 81, 21);
  
  float maxPopYear;
  float minPopYear;

  if (popYear == "Population 2010 Census") {
    maxPopYear = maxPop2010;
    minPopYear = minPop2010;
    lowestPopulationColor = color(255, 224, 121);
    highestPopulationColor = color(232, 81, 21);
  } else if (popYear == "Population 2000 Census") {
    maxPopYear = maxPop2000;
    minPopYear = minPop2000;
    lowestPopulationColor = color(0, 255, 0); // rgb
    highestPopulationColor = color(255, 0, 255);
  } else if (popYear == "Population 1980 Census") {
    maxPopYear = maxPop1980;
    minPopYear = minPop1980;
    lowestPopulationColor = color(255, 0, 0);
    highestPopulationColor = color(0, 255, 255);
  } else { // 1994
    maxPopYear = maxPop1994;
    minPopYear = minPop1994;
    lowestPopulationColor = color(0, 0, 255);
    highestPopulationColor = color(255, 255, 0);
  }

  // show the map on the left side
  showMap(showDen, popYear, minPopYear, maxPopYear, lowestPopulationColor, highestPopulationColor, minRadius, maxRadius);

  fill(250);
  stroke(111, 87, 0);
  rect(1400, -10, 1010, 810); // (x, y width, height)
  line(1010, 600, 1400, 600); // (x1, y1, x2, y2)

  showRes();
  
  // show the right side
  showLengends(popYear, minPopYear, maxPopYear, lowestPopulationColor, highestPopulationColor, minRadius, maxRadius);
}

void showRes() {
  fill(111, 87, 0);
  textSize(12);
  text("Filter Results", 1020, 10);
  textSize(13);
  text("> Start by choosing two municipalities to compare: \n", 1020, 46);
  rectMode(CORNER);
  fill(167, 50);
  rect(1010, 0, 90, 22);
}



void showLengends(String popYear, float minPopYear, float maxPopYear, color lowestPopulationColor, color highestPopulationColor, float minRadius, float maxRadius) {

  fill(111, 87, 0);
  textSize(12);
  text("Lengends", 1020, 610);
  rectMode(CORNER);
  fill(167, 50);
  rect(1010, 600, 70, 22);// , 28);

  fill(111, 87, 0);
  textSize(10);
  showPopLegend(popYear, minPopYear, maxPopYear, lowestPopulationColor, highestPopulationColor);
  showAreaLengend(minRadius, maxRadius);
}

void showAreaLengend(float minRadius, float maxRadius) {
  // circle size legend
  textAlign(CENTER, CENTER);
  text("Municipality Area", 1090, 710);

  noStroke();
  //textAlign(RIGHT, CENTER);
  int nExamples = 6;
  float x = 1090;
  for (int i=0; i<nExamples; i++) {
    float amt = 1.0 - (float)i/(nExamples - 1);
    float radius = lerp(minRadius, maxRadius, amt);

    ellipseMode(RADIUS);
    circle(x + radius - 40, 750, radius);
    int labelValue = (int)(minArea + amt*(maxArea - minArea));
    text(labelValue, x + radius - 40, 785);
    x += 2 * radius + 10;//maxIslandRadius;
  }
}

void showPopLegend(String popYear, float minPopYear, float maxPopYear, color lowestPopulationColor, color highestPopulationColor) {

  // colormap legend

  text(popYear, 1050, 635);
  textAlign(CENTER, CENTER);
  strokeWeight(1);
  //textAlign(RIGHT, CENTER);
  int gradientHeight = 20;
  int gradientWidth = 220;
  int labelStep = gradientWidth / 5;
  for (int x=0; x<gradientWidth; x++) {
    float amt = 1.0 - (float)x/(gradientWidth-1);
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, amt);
    stroke(c);
    line(1050 + x, 650, 1050 + x, 650+gradientHeight);
    if ((x % labelStep == 0) || (x == gradientWidth-1)) {
      int labelValue = (int)(minPopYear + amt*(maxPopYear - minPopYear));
      text(labelValue, 1050 + x, 680);
    }
  }
}


void keyPressed() {
  if (key == ' ') {
    println("current scale: ", panZoomMap.scale, " current translation: ", panZoomMap.translateX, "x", panZoomMap.translateY);
  }
}


void mousePressed() {
  if (highlightedMunicipality != "") {
    selectedMunicipality = highlightedMunicipality;
    // print in the terminal
    println("Selected: " + selectedMunicipality + " State");

    // print info table of selectedMunicipality
    // show info of highlightedMunicipality
    //text(highlightedMunicipality, mouseX, mouseY + 10);
    String name = "Municipality Name: " + selectedMunicipality + "\n";
    String loc = "(Lat, Long): (" + getLatitude(selectedMunicipality) + "," + getLongitude(selectedMunicipality) + ") \n";
    String area = "Area: " + getArea(selectedMunicipality) + "\n";
    
    // get 4 years' pops
    float[] pops = getCensus(selectedMunicipality);
    String state = "State: " + getState(selectedMunicipality) + "\n";;
    String pops4 = "[1980, 1994, 2000, 2010] Census: [" + pops[0] + ", " + pops[1] + ", " + pops[2] + ", " + pops[3] + "] \n";
    info = name + state + loc + pops4 + area;
    
    infoTableX = mouseX + 5;
    infoTableY = mouseY + 20;

    infoText.setText(info);
    infoText.setColor(50);
    infoText.setColorBackground(color(87, 100));
    infoText.setColorForeground(color(255, 100));
    infoText.setPosition(infoTableX, infoTableY);
    imgPath = "./islandsImgs/" + selectedMunicipality + ".jpeg";
    //println(imgPath);
    islandImg = loadImage(imgPath);
    showIslandImg = true;
    imgX = infoTableX;
    imgY = infoTableY + 70;

  } else {
    infoText.setText("");
    showIslandImg = false;
    //infoText.setColor(50);
    infoText.disableColorBackground();
  }

  panZoomMap.mousePressed();
}


void mouseDragged() {
  panZoomMap.mouseDragged();
}


void mouseWheel(MouseEvent e) {
  panZoomMap.mouseWheel(e);
}


// === SOME HELPER ROUTINES FOR EASIER ACCESS TO FREQUENTLY NEEDED DATA IN THE TABLES ===

float getLatitude(String municipalityName) {
  TableRow r = locationTable.findRow(municipalityName, "Municipality");
  return r.getFloat("Latitude");
}

float getLongitude(String municipalityName) {
  TableRow r = locationTable.findRow(municipalityName, "Municipality");
  return r.getFloat("Longitude");
}

int getArea(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  int area = popRow.getInt("Area");
  return area;
}

float[] getCensus(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  float[] census = new float[4];
  census[0] = popRow.getFloat("Population 1980 Census");
  census[1] = popRow.getFloat("Population 1994 Census");
  census[2] = popRow.getFloat("Population 2000 Census");
  census[3] = popRow.getFloat("Population 2010 Census");
  return census;
}

String getState(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  String state = popRow.getString("State");
  return state;
}

float getArea01(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  int area = popRow.getInt("Area");
  float area_01 = (area - minArea) / (maxArea - minArea);
  return area_01;
}

//float getPopYear(String island, String year) {
//  // get row of islands
  
//}

// TODO: Update this based on your own radius calculation to make sure that the mouse selection
// routines work
float getRadius(String municipalityName) {
  float minRadius = 3;
  float maxRadius = 28;
  float amt = getArea01(municipalityName);
  return lerp(minRadius, maxRadius, amt);
}

// Returns the municipality currently under the mouse cursor so that it can be highlighted or selected
// with a mouse click.  If the municipalities overlap and more than one is under the cursor, the
// smallest municipality will be returned, since this is usually the hardest one to select.
String getMunicipalityUnderMouse() {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "";
  for (int i=0; i<locationTable.getRowCount(); i++) {
    TableRow rowData = locationTable.getRow(i);
    String municipality = rowData.getString("Municipality");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = getRadius(municipality);
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = municipality;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;
}

// === HELPER FUNCTIONS FOR CREATING PLOTS ===
// (w,h), position (1040, 110)
// 350, 200
void createPlots(String i1, String i2) {//float[] pops, float max, float min) {
  fill(255);
  
  float yrange = 200.0;
  
  float[] pops1 = TableUtils.getPops(populationTable, i1); // 1980, 1994, 2000, 2010, area
  float[] pops2 = TableUtils.getPops(populationTable, i2);
  
  float[] newpops1 = new float[5];
  float[] newpops2 = new float[5];
  
  float pop1max = max(max(pops1[0], pops1[1], pops1[2]), max(pops1[3], pops1[4]));
  float pop2max = max(max(pops2[0], pops2[1], pops2[2]), max(pops2[3], pops2[4]));
  float m = max(pop1max, pop2max);
  
  
  float pop1min = min(min(pops1[0], pops1[1], pops1[2]), min(pops1[3], pops1[4]));
  float pop2min = min(min(pops2[0], pops2[1], pops2[2]), min(pops2[3], pops2[4]));
  float mi = min(pop1min, pop2min);
  //float areaMax = max(pops1[4], pops2[4]);
  //float areaMin = min(pops1[4], pops2[4]);
  
  //println("m and mi is", m, mi);
  
  //normalize pops within [10, 200]
  for (int i = 0; i < 5; i++){
    if (pops1[i] > 0 && m != mi) {
      newpops1[i] = 10 + ((yrange - 10) / (m - mi)) * (pops1[i] - mi);
    }
    
    if (pops2[i]> 0 && m != mi) {
      newpops2[i] = 10 + ((yrange - 10) / (m - mi)) * (pops2[i] - mi);
    }
    
  }

  
  if (pops1[4] > 0 && pops2[4] > 0){

    stroke(126);
    line(1030, 300, 1030+350, 300); // 1380
    //line(1030, 300, 1030, 100); //200 height
  
    // print out 4 years census of two islands
    // get the h and multiply by 4 to increase the visibility
    
    // 1980 pop
    fill(chartColor1); // red
    rect(1040 + 0*10, 300 - newpops1[0], 10, newpops1[0]); // 1980
    text(pops1[0], 1040 + 0*10, 290 - newpops1[0]);
    point(1040 + 0*10+5, 300 - newpops1[0]);
    
    rect( 1040 + 7*10 , 300 - newpops1[1], 10, newpops1[1]); // 1990
    text(pops1[1], 1040 + 7*10, 290 - newpops1[1]); 
    point(1040 + 7*10+5, 300 - newpops1[1]);
    
    line(1040 + 0*10+5, 300 - newpops1[0], 1040 + 7*10+5, 300 - newpops1[1]);
    
    rect( 1040 + 14*10 , 300 - newpops1[2], 10, newpops1[2]); // 2000
    text(pops1[2], 1040 + 14*10, 290 - newpops1[2]); 
    point(1040 + 14*10+5, 300 - newpops1[2]);
    
    line(1040 + 7*10+5, 300 - newpops1[1], 1040 + 14*10+5, 300 - newpops1[2]);
    
    rect( 1040 + 21*10 , 300 - newpops1[3], 10, newpops1[3]); // 2010
    text(pops1[3], 1040 + 21*10, 290 - newpops1[3]); 
    point(1040 + 21*10+5, 300 - newpops1[3]);
    
    line(1040 + 14*10+5, 300 - newpops1[2], 1040 + 21*10+5, 300 - newpops1[3]);
    
    rect( 1040 + 28*10 , 300 - newpops1[4], 10, newpops1[4]); // area
    text(pops1[4], 1040 + 28*10 + 5, 290 - newpops1[4]); 
    //point(1040 + 28*10+5, 300 - newpops1[4]);
    
    
    
    
    fill(chartColor2); // blue
    rect( 1040 + 1*10, 300 - newpops2[0], 10, newpops2[0]); //1980
    text(pops2[0], 1040 + 3*10, 290 - newpops2[0]); 
    point(1040 + 1*10+5, 300 - newpops2[0]);
    
    
    rect( 1040 + 8*10, 300 - newpops2[1], 10, newpops2[1]); // 1990
    text(pops2[1], 1040 + 10*10, 290 - newpops2[1]); 
    point(1040 + 8*10+5, 300 - newpops2[1]);
    
    line(1040 + 1*10+5, 300 - newpops2[0], 1040 + 8*10+5, 300 - newpops2[1]);
    
    rect( 1040 + 15*10, 300 - newpops2[2], 10, newpops2[2]); // 2000
    text(pops2[2], 1040 + 17*10, 290 - newpops2[2]); 
    point(1040 + 15*10+5, 300 - newpops2[2]);
    
    line(1040 + 8*10+5, 300 - newpops2[1], 1040 + 15*10+5, 300 - newpops2[2]);
    
    rect( 1040 + 22*10, 300 - newpops2[3], 10, newpops2[3]); // 2010
    text(pops2[3], 1040 + 24*10, 290 - newpops2[3]); 
    point(1040 +22*10+5, 300 - newpops2[3]);
    
    line(1040 + 15*10+5, 300 - newpops2[2], 1040 +22*10+5, 300 - newpops2[3]);
    
    rect( 1040 + 29*10, 300 - newpops2[4], 10, newpops2[4]); // area
    text(pops2[4], 1055 + 31*10, 300 - newpops2[4]); 
    
    
    fill(0);
    text("1980 pop", 1050, 310); 
    text("1994 pop", 1120, 310);
    text("2000 pop", 1190, 310);
    text("2010 pop", 1260, 310);
    text("area", 1330, 310);
    
  }
  
  // add lengends for islands 
  fill(chartColor1); // red
  rect(1030, 330, 10, 10); // area
  text("Island1(left)", 1070, 332); 
  
  fill(chartColor2); // blue
  rect(1030, 340, 10, 10); // area
  text("Island2(right)",1072, 345); 

  // show trends of population
  
}



// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  locationTable = loadTable("FSM-municipality-locations.csv", "header");
  println("Location table:", locationTable.getRowCount(), "x", locationTable.getColumnCount());

  populationTable = loadTable("FSM-municipality-populations.csv", "header");
  println("Population table:", populationTable.getRowCount(), "x", populationTable.getColumnCount());
}

void computeDerivedData() {
  // lookup min/max data ranges for the variables we will want to depict
  minLatitude = TableUtils.findMinFloatInColumn(locationTable, "Latitude");
  maxLatitude = TableUtils.findMaxFloatInColumn(locationTable, "Latitude");
  println("Latitude range:", minLatitude, "to", maxLatitude);

  minLongitude = TableUtils.findMinFloatInColumn(locationTable, "Longitude");
  maxLongitude = TableUtils.findMaxFloatInColumn(locationTable, "Longitude");
  println("Longitude range:", minLongitude, "to", maxLongitude);

  minPop1980 = TableUtils.findMinFloatInColumn(populationTable, "Population 1980 Census");
  maxPop1980 = TableUtils.findMaxFloatInColumn(populationTable, "Population 1980 Census");
  println("Pop 1980 range:", minPop1980, "to", maxPop1980);

  minPop1994 = TableUtils.findMinFloatInColumn(populationTable, "Population 1994 Census");
  maxPop1994 = TableUtils.findMaxFloatInColumn(populationTable, "Population 1994 Census");
  println("Pop 1994 range:", minPop1994, "to", maxPop1994);

  minPop2000 = TableUtils.findMinFloatInColumn(populationTable, "Population 2000 Census");
  maxPop2000 = TableUtils.findMaxFloatInColumn(populationTable, "Population 2000 Census");
  println("Pop 2000 range:", minPop2000, "to", maxPop2000);

  minPop2010 = TableUtils.findMinFloatInColumn(populationTable, "Population 2010 Census");
  maxPop2010 = TableUtils.findMaxFloatInColumn(populationTable, "Population 2010 Census");
  println("Pop 2010 range:", minPop2010, "to", maxPop2010);

  minArea = TableUtils.findMinFloatInColumn(populationTable, "Area");
  maxArea = TableUtils.findMaxFloatInColumn(populationTable, "Area");
  println("Area range:", minArea, "to", maxArea);
}

// find min and max population density of 4 years
void computePopDensityData() {
  for(int i = 0;i<populationTable.getRowCount();i++){
    TableRow rowData = locationTable.getRow(i);
    float den1980 = rowData.getFloat("Population 1980 Census")/rowData.getFloat("Area");
    if (den1980<minPopYear1980Den){
      minPopYear1980Den = den1980;
    }else if (den1980>maxPopYear1980Den) {
      maxPopYear1980Den = den1980;
    }
    float den1994 = rowData.getFloat("Population 1994 Census")/rowData.getFloat("Area");
    if (den1994<minPopYear1994Den){
      minPopYear1994Den = den1994;
    }else if (den1994>maxPopYear1994Den) {
      maxPopYear1994Den = den1994;
    }
    float den2000 = rowData.getFloat("Population 2000 Census")/rowData.getFloat("Area");
    if (den2000<minPopYear2000Den){
      minPopYear2000Den = den2000;
    }else if (den2000>maxPopYear2000Den) {
      maxPopYear2000Den = den2000;
    }
    float den2010 = rowData.getFloat("Population 2010 Census")/rowData.getFloat("Area");
    if (den2010<minPopYear2010Den){
      minPopYear2010Den = den2010;
    }else if (den2010>maxPopYear2010Den) {
      maxPopYear2010Den = den2010;
    }
  }
  println(minPopYear1980Den, maxPopYear1980Den,
   minPopYear1994Den, maxPopYear1994Den,
   minPopYear2000Den, maxPopYear2000Den,
   minPopYear2010Den, maxPopYear2010Den);

  
}



// === NEW METHOD FOR USING ===
<T> ArrayList<T> getColumnData(Table data, String columnName, Class<T> columnType) {
    ArrayList<T> columnData = new ArrayList<T>();
    for (TableRow row : data.rows()) {
      T dataValue;
      if (columnType == String.class) {
        dataValue = columnType.cast(row.getString(columnName));
      } else if (columnType == Float.class) {
        dataValue = columnType.cast(row.getFloat(columnName));
      } else {
        throw new IllegalArgumentException("Invalid column type");
      }
      columnData.add(dataValue);
    }
    return columnData;
  }

String[] getColumnData(Table table, String columnName) {
  String[] columnData = new String[table.getRowCount()];
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    columnData[i] = row.getString(columnName);
  }
  return columnData;
}
