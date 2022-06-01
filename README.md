## Documents
Documents used in this project can be found under the directory /documents

The report for this thesis can be found at https://www.diva-portal.org/smash/search.jsf?dswid=-9636

In the search field, please search the following: Visualisering av tidssynkroniserade kraftdata vid sprintstarter på en mobil enhet

The report can also be found under the directory /documents
## Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

For installation guidance, please read the Appendix 8 in the thesis report.
## Micro:bit code
Code for micro:bit can be found under directory /microbit_code
Download the file and load it into your micro:bit.
Make sure that you enable Bluetooth on the micro:bit. See these instructions on how to do it: https://support.microbit.org/support/solutions/articles/19000051025

If you want to edit the source code. Please visit https://makecode.microbit.org and import the file into MakeCode.

Following constants kan be changed in the micro:bit code:
k_LF = 1.8379
m_LF = -901
k_RF = 2.0824
m_RF = -1026
invers = 1023
g = 9.82
pauseTime = 4.741
frequency = 200
// sampleTotalTime 3 seconds for 200Hz
sampleTotalTime = 3
threshold = 200
## Constants in Flutter application
Following constants can be manipulated in the file constants/constants.dart:
static const TARGET_DEVICE_NAME_TIZEZ = 'BBC micro:bit [tizez]';
static const LIST_LEN = 100;
static const ALPHA = 0.1; //EWMA alpha value
static const MEAN_NOISE_THRESH =200; //Threshold value for noise.
static const MOVESENSE_DEVICE_NAME = 'Movesense 175130000971';
static const DATABASE_NAME = 'test21';
static const HISTORY_TABLE_NAME = 'test21';
