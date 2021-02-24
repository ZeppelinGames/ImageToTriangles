PImage img;

int outputScale=50; //Larger the scale, smaller the triangles

int fixedOutputScale=10;

boolean hardColor = true; //Change the output style
boolean outlineTris = false; //Outline the triangles?

int[] gridX;
int[] gridY;

void setup() {
  size(1000, 1000);
  try {
    img = loadImage("Mountains.jpeg"); //Case-sensitive. Image must be placed in /data/ folder

    if (!outlineTris) {
      noStroke();
    }

    CreateGrid();
    DrawImage();
  } 
  catch (NullPointerException e) {
    text("Unable to load image. Check spelling and directory", 25, 25);
  }
}

void CreateGrid() {
  //Find factors of width closest to outputScale
  int newScale = floor(width / outputScale);
  println(newScale);

  int[] gridPointsX = new int[(width*height)/newScale];
  int[] gridPointsY = new int[(width * height)/newScale];

  int i=0;

  for (int y=0; y < (height/newScale)+1; y++) {
    for (int x =0; x < (width/newScale)+1; x++) {
      gridPointsX[i] = x * newScale;
      gridPointsY[i] = y * newScale;
      i++;
    }
  }

  fixedOutputScale = newScale;
  gridX = gridPointsX;
  gridY = gridPointsY;
}

void DrawImage() 
{
  int imageWidth = img.width;
  int imageHeight = img.height;

  int largerSide = imageWidth > imageHeight ? imageWidth : imageHeight;
  float imgScale = float(width) / float(largerSide);

  image(img, 0, 0, imageWidth * imgScale, imageHeight * imgScale);

  for (int i =0; i <(width/fixedOutputScale) * (height/fixedOutputScale) + (width/fixedOutputScale); i++) {
    //DrawTriangles
    // get i, i+1 and i + (fixedOutputScale)
    int nextIndex = i+1;
    int nextLineIndex = nextIndex + (width/ fixedOutputScale);

    if (nextLineIndex < gridX.length-1) {
      if (nextIndex % ((width/fixedOutputScale)+1) != 0) {

        color fillColor = color(255);
        if (hardColor) {
          PVector center = centroid(new PVector[] { new PVector(gridX[i], gridY[i]), 
            new PVector(gridX[nextIndex], gridY[nextIndex]), 
            new PVector(gridX[nextLineIndex], gridY[nextLineIndex])});

          fillColor = get(int(center.x), int(center.y));
        } else {
          color avgColor = calcAVGTriangleColor(
            new PVector(gridX[i], gridY[i]), 
            new PVector(gridX[nextIndex], gridY[nextIndex]), 
            new PVector(gridX[nextLineIndex], gridY[nextLineIndex]));

          fillColor = avgColor;
        }

        fill(fillColor);
        triangle(gridX[i], gridY[i], 
          gridX[nextIndex], gridY[nextIndex], 
          gridX[nextLineIndex], gridY[nextLineIndex]);
      }

      int nextLineIndex1 = nextLineIndex +1;
      if (nextLineIndex1 < gridX.length-1) {
        if (nextIndex % ((width/fixedOutputScale)+1) != 0) {

          color fillColor = color(255);
          if (hardColor) {
            PVector center = centroid(new PVector[] { new PVector(gridX[nextLineIndex1], gridY[nextLineIndex1]), 
              new PVector(gridX[nextIndex], gridY[nextIndex]), 
              new PVector(gridX[nextLineIndex], gridY[nextLineIndex])});

            fillColor = get(int(center.x), int(center.y));
          } else {
            color avgColor = calcAVGTriangleColor(
              new PVector(gridX[nextLineIndex1], gridY[nextLineIndex1]), 
              new PVector(gridX[nextIndex], gridY[nextIndex]), 
              new PVector(gridX[nextLineIndex], gridY[nextLineIndex]));

            fillColor = avgColor;
          }

          fill(fillColor);
          triangle(gridX[nextLineIndex1], gridY[nextLineIndex1], 
            gridX[nextIndex], gridY[nextIndex], 
            gridX[nextLineIndex], gridY[nextLineIndex]);
        }
      }
    }
  }

  println("Done");
}

color calcAVGTriangleColor(PVector p1, PVector p2, PVector p3) {
  PVector[] samplePoints = getPointsOnLine(
    new PVector(p1.x, p1.y), 
    new PVector(p2.x, p2.y));

  PVector[] line2SamplePoints = getPointsOnLine(
    new PVector(p2.x, p2.y), 
    new PVector(p3.x, p3.x));

  PVector[] line3SamplePoints = getPointsOnLine(
    new PVector(p1.x, p1.y), 
    new PVector(p3.x, p3.y));

  samplePoints = pVecArrayAppend(samplePoints, line2SamplePoints);
  samplePoints = pVecArrayAppend(samplePoints, line3SamplePoints);

  color[] sampleColors = new color[samplePoints.length];
  for (int n =0; n< samplePoints.length; n++) {
    sampleColors[n] = get(int(samplePoints[n].x), int(samplePoints[n].y));
  }
  color avgColor = getAverageColor(sampleColors);
  return avgColor;
}

PVector[] pVecArrayAppend(PVector[] base, PVector[] appendArray) {
  PVector[] appendedArray = new PVector[base.length + appendArray.length];
  for (int n=0; n < base.length; n++) {
    appendedArray[n] = base[n];
  }
  for (int n=base.length; n < base.length + appendArray.length; n++) {
    appendedArray[n] = appendArray[n -base.length];
  }
  return appendedArray;
}

PVector centroid(PVector[] points) {
  PVector center = new PVector(0, 0, 0);

  for (int n =0; n< points.length; n++) {
    center.add(points[n]);
  }
  center.div(points.length);
  return center;
}

color getAverageColor(color[] colors) {
  PVector avgColor = new PVector(0, 0, 0);

  for (int n=0; n < colors.length; n++) {
    avgColor = new PVector(
      avgColor.x + red(colors[n]), 
      avgColor.y + green(colors[n]), 
      avgColor.z + blue(colors[n]));
  }
  avgColor = new PVector(
    avgColor.x / colors.length, 
    avgColor.y / colors.length, 
    avgColor.z / colors.length);

  return color(avgColor.x, avgColor.y, avgColor.z);
}

PVector[] getPointsOnLine(PVector p1, PVector p2) {
  float gradient = (p2.y / p1.y) - (p2.x / p1.x);
  float c = p1.y - p1.x * gradient;

  int xFrom = p1.x < p2.x ? int(p1.x) : int(p2.x);
  int xTo = xFrom == p1.x ? int(p2.x) : int(p1.x);

  PVector[] points = new PVector[xTo - xFrom];
  int i=0;
  for (int n=(xFrom); n < (xTo); n++) {
    points[i] = new PVector(n, (gradient*n)+c);
    i++;
  }

  return points;
}
