/* CSci-5609 Assignment 2: Visualization of Paafu Kinship Ties for the Islands of Micronesia
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

// Graphics and UI variables
PanZoomMap panZoomMap;
PFont labelFont;
String highlightedMunicipality = "";
String selectedMunicipality = "Romanum";


// for dropdown list
import controlP5.*;

//Table selectedInfoTable;
Textarea infoText;

ControlP5 controlP5;
DropdownList overview;
DropdownList stateDropdown;
DropdownList filter;

// Button Status after click 'Filter'
boolean unclickFilterButtons = true;
Button[] buttons = new Button[2];
DropdownList[] dropdowns = new DropdownList[3];

// 0 for button, 1 for dropdown list
int[] buttonOrDropList = new int[]{0,1,1,0,1};

String info = "";
float infoTableX = 0.0;
float infoTableY = 0.0;

// === PROCESSING BUILT-IN FUNCTIONS ===

void setup() {
  // size of the graphics window
  size(1400,800); // 1600, 900

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
  
  // these initial values provide a good view of Chuuk Lagoon, but you can
  // comment these out to start with all of the data on the screen
  panZoomMap.scale = 87430.2;
  panZoomMap.translateX = -47255.832;
  panZoomMap.translateY = -43944.914;
  
  labelFont = loadFont("Futura-Medium-18.vlw");
  
  
  // set the dropdown lists
  frameRate(30);
  controlP5 = new ControlP5(this);
  //overview = controlP5.addDropdownList("Micronesian Overview",50,50,100,150);
  
  controlP5.addButton("micronesianOverview")
     .setValue(0)
     .setPosition(50,50)
     .setSize(120,25)
     .activateBy(ControlP5.PRESSED)
  ;
  
  controlP5.addButton("Filter")
     .setValue(0)
     .setPosition(290,50)
     .setSize(120,25)
  ;
     
  stateDropdown = controlP5.addDropdownList("State",180,50,100,150);
  //filter = controlP5.addDropdownList("Filter",290,50,100,150);
  
  //customizeDropdown(overview, "overview");
  customizeDropdown(stateDropdown, "state");
  //customizeDropdown(filter, "filter");
  
  
  // set the table for selected municipality
  //selectedInfoTable = new Table();
  //customizeTable(selectedInfoTable);
  infoText = controlP5.addTextarea("txt")
                  .setPosition(0, 0)
                  .setSize(200,100)
                  .setFont(createFont("arial",12))
                  .setLineHeight(14)
                  .disableColorBackground();
                  //.setColor(0xffffffff);
                  //.setColorBackground(color(255,100))
                  //.setColorForeground(color(255,100));
                  ;
                  
  infoText.setText("");

}


void draw() {
  // clear the screen
  background(230);
  PImage img;
  img = loadImage("micro.jpeg");
  img.resize(1400, 800);
  background(img);
  
  overviewUI();
  filterclicked();
}

void filterclicked(){
  String[] years = {"1980", "1994", "2000","2010"};
  String[] orders = {"Ascending", "Descending"};
  String[] munData = getColumnData(populationTable, "Municipality");

  if (unclickFilterButtons) {
    if(buttons[0] == null){
      buttons[0] = controlP5.addButton("FilterBy")
                            .setPosition(290 + 0 * 120, 80)
                            .setSize(100,30);
    }

    if(buttons[1] == null){
      buttons[1] = controlP5.addButton("Area")
                            .setPosition(290 + 3 * 120, 80)
                            .setSize(100,30);
    }

    if(dropdowns[0] == null){
      dropdowns[0] = controlP5.addDropdownList("Municipality")
                            .setPosition(290 + 1 * 120, 80)
                            .setSize(100, 100)
                            .setBarHeight(30)
                            .setItemHeight(20);
      
      for (int k = 0; k < munData.length; k++) { 
        dropdowns[0].addItem(munData[k], k);
      }

    }

    if(dropdowns[1] == null){
      dropdowns[1] = controlP5.addDropdownList("Year")
                            .setPosition(290 + 2 * 120, 80)
                            .setSize(100, 100)
                            .setBarHeight(30)
                            .setItemHeight(20);

      for (int i = 0; i < years.length; i++) { 
        dropdowns[1].addItem(years[i], i);
      }

    }


    if(dropdowns[2] == null){
      dropdowns[2] = controlP5.addDropdownList("SortOrder")
                            .setPosition(290 + 4 * 120, 80)
                            .setSize(100, 100)
                            .setBarHeight(30)
                            .setItemHeight(20);
      
      for (int j = 0; j < orders.length; j++) { 
        dropdowns[2].addItem(orders[j], j);
      }
    }

    
  }

  else{
    if (buttons[0] != null){
      controlP5.remove("FilterBy");
      buttons[0] = null;
    }

    if (buttons[1] != null){
      controlP5.remove("Area");
      buttons[1] = null;
    }

    if (dropdowns[0] != null){ 
      controlP5.remove("Municipality");
      dropdowns[0] = null;
    }

    if (dropdowns[1] != null){
      controlP5.remove("Year");
      dropdowns[1] = null;
    }    
    
    if (dropdowns[2] != null){
      controlP5.remove("SortOrder");
      dropdowns[2] = null;
    }
  }
}

void Filter() {
  unclickFilterButtons = !unclickFilterButtons;
}

void Year(ControlEvent event){
  String[] years = {"1980", "1994", "2000", "2010"};
  if (event.isFrom("Year")) {
    println("Selected Year: " + years[(int)event.getController().getValue()]); 
  }
}

void Municipality(ControlEvent event){
  String[] munData = getColumnData(populationTable, "Municipality");
  if (event.isFrom("Municipality")) {
    println("Selected Municipality: " + munData[(int)event.getController().getValue()]);
  }
}

void SortOrder(ControlEvent event){
  String[] orders = {"Ascending", "Descending"};
  if (event.isFrom("SortOrder")) {
    println("Selected Sort Order: " + orders[(int)event.getController().getValue()]);
  }
}

// for cutomize the dropdown menu //<>//
void customizeDropdown(DropdownList ddl, String name) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(25);
  ddl.setBarHeight(25);

  if (name == "state") {
    ddl.addItem("YAP", 1); //<>//
    ddl.addItem("CHU", 2);
    ddl.addItem("KOS", 3);
    ddl.addItem("POH", 4);
  }
  
  if(name == "")

  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255,128));
}



// function colorA will receive changes from 
// controller with name Micronesian Overview
public void micronesianOverview(int theValue) {
  println("a button event from micronesianOverview: "+ theValue); // 0
}

void FilterOverview(int theValue) {
  println("a button event from Filter: "+ theValue); // 0
}
 //<>//
// when user clicks "Micronesia overview button"
void overviewUI() {
  
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
  
     
  // Example Solution to Assignment 1
     
  // defined in screen space, so the circles will be the same size regardless of zoom level
  float minRadius = 3;
  float maxRadius = 28;
  
  color lowestPopulationColor = color(255, 224, 121);
  color highestPopulationColor = color(232, 81, 21);
  
  for (int i=0; i<locationTable.getRowCount(); i++) {
    TableRow rowData = locationTable.getRow(i);
    String municipalityName = rowData.getString("Municipality");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    
    // lat,long code above is the same as part A.  if we also get the municipality name
    // for this row in the location table, then we can look up population data for the
    // municipality in the population table
    TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
    int pop2010 = popRow.getInt("Population 2010 Census");
    int area = popRow.getInt("Area");

    // normalize data values to a 0..1 range
    float pop2010_01 = (pop2010 - minPop2010) / (maxPop2010 - minPop2010);
    float area_01 = (area - minArea) / (maxArea - minArea);
    
    // two examples using lerp*() to map the data values to changes in visual attributes
    
    // 1. adjust the radius of the island in proportion to its area
    float radius = lerp(minRadius, maxRadius, area_01);
    
    // 2. adjust the fill color in proportion to the population
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, pop2010_01);
    fill(c);
    
    noStroke();
    ellipseMode(RADIUS);
    
    // highlight the circle if highlightedMunicipality == its name
    // also show detailed info of hovered municipality
    if (highlightedMunicipality == municipalityName) {
      fill(0,0,255);
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
   

  // DRAW THE LEGEND
  
  // block off the right side of the screen with a big rect
  fill(250);
  stroke(111, 87, 0);
  rect(1400, -10, 1210, 810);

  // colormap legend
  fill(111, 87, 0);
  textAlign(CENTER, CENTER);
  text("2010 Population", 1300, 50);

  strokeWeight(1);
  textAlign(RIGHT, CENTER);
  int gradientHeight = 200;
  int gradientWidth = 40;
  int labelStep = gradientHeight / 5;
  for (int y=0; y<gradientHeight; y++) {
    float amt = 1.0 - (float)y/(gradientHeight-1);
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, amt);
    stroke(c);
    line(1300, 70 + y, 1300+gradientWidth, 70 + y);
    if ((y % labelStep == 0) || (y == gradientHeight-1)) {
      int labelValue = (int)(minPop2010 + amt*(maxPop2010 - minPop2010));
      text(labelValue, 1290, 70 + y);
    }
  }
            
  // circle size legend
  fill(111, 87, 0);
  textAlign(CENTER, CENTER);
  text("Municipality Area", 1300, 300);

  noStroke();
  textAlign(RIGHT, CENTER);
  int nExamples = 6;
  float y = 340;
  for (int i=0; i<nExamples; i++) {
    float amt = 1.0 - (float)i/(nExamples - 1);
    float radius = lerp(minRadius, maxRadius, amt);
    
    ellipseMode(RADIUS);
    circle(1300 + radius, y, radius);
    int labelValue = (int)(minArea + amt*(maxArea - minArea));
    text(labelValue, 1290, y);
    y += 2 * radius;//maxIslandRadius;
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
    println("Selected: " + selectedMunicipality + "State: ");
    
    // print info table of selectedMunicipality
          // show info of highlightedMunicipality
    //text(highlightedMunicipality, mouseX, mouseY + 10);
    info = "Municipality Name: " + selectedMunicipality + "\n" + "(Lat, Long): (" + getLatitude(selectedMunicipality) + "," + getLongitude(selectedMunicipality) + ") \n";
    infoTableX = mouseX + 5;
    infoTableY = mouseY + 20;
    
    infoText.setText(info);
    infoText.setColor(50);
    infoText.setColorBackground(color(87,100));
    infoText.setColorForeground(color(255,100));
    infoText.setPosition(infoTableX, infoTableY);
    
  } else {
    infoText.setText("");
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

float getArea01(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  int area = popRow.getInt("Area");
  float area_01 = (area - minArea) / (maxArea - minArea);
  return area_01;
}

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



// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  locationTable = loadTable("FSM-municipality-locations.csv", "header");
  println("Location table:", locationTable.getRowCount(), "x", locationTable.getColumnCount()); 
  
  populationTable = loadTable("FSM-municipality-populations.csv", "header");
  println("Population table:", populationTable.getRowCount(), "x", populationTable.getColumnCount()); 
}


String[] getColumnData(Table table, String columnName) {
  String[] columnData = new String[table.getRowCount()];
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    columnData[i] = row.getString(columnName);
  }
  return columnData;
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
