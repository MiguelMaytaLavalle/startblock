class Constants {
  /* Micro:Bit BLE-services*/
  static const SERVICE_UART = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const CHARACTERISTIC_UART_RECIEVE = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"; //Read to micro:bit. RX
  static const CHARACTERISTIC_UART_SEND = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  //Send from micro:bit. TX

  static const IOPINSERVICE_SERVICE_UUID = "E95D127B251D470AA062FA1922DFA9A8";
  static const PINDATA_CHARACTERISTIC_UUID = "E95D8D00251D470AA062FA1922DFA9A8";
  static const PINADCONFIGURATION_CHARACTERISTIC_UUID = "E95D5899251D470AA062FA1922DFA9A8";
  static const PINIOCONFIGURATION_CHARACTERISTIC_UUID = "E95DB9FE251D470AA062FA1922DFA9A8";

  static const LEDSERVICE_SERVICE_UUID = "e95dd91d-251d-470a-a062-fa1922dfa9a8";
  static const LEDMATRIXSTATE_CHARACTERISTIC_UUID = "e95d7b77-251d-470a-a062-fa1922dfa9a8";
  static const LEDTEXT_CHARACTERISTIC_UUID = "e95d93ee-251d-470a-a062-fa1922dfa9a8";
  static const SCROLLINGDELAY_CHARACTERISTIC_UUID = "e95d0d2d-251d-470a-a062-fa1922dfa9a8";

  /* Movesense BLE-services */
  static const MOVESENSE_SERVICE = "34802252-7185-4d5d-b431-630e7050e8f0";
  static const MOVESENSE_SEND = "34800001-7185-4d5d-b431-630e7050e8f0";
  static const MOVESENSE_DATA = "34800002-7185-4d5d-b431-630e7050e8f0";

  /* Following constants can be changed */
  static const TARGET_DEVICE_NAME_TIZEZ = 'BBC micro:bit [tizez]';
  static const TARGET_DEVICE_NAME_ZIVIT = 'BBC micro:bit [zivit]';
  static const LIST_LEN = 100;
  static const ALPHA = 1; //EWMA alpha value
  static const MEAN_NOISE_THRESH = 0; //Threshold value for noise.
  static const MOVESENSE_DEVICE_NAME = 'Movesense 175130000971';
  static const DATABASE_NAME = 'test21';
  static const HISTORY_TABLE_NAME = 'test21';

}



