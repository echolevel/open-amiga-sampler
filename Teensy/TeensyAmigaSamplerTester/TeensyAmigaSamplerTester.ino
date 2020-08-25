/*
   http://github.com/echolevel/open-amiga-sampler
   
   Tested on Teensy 3.5 with microSD card
   USB type: 'Serial'
   CPU speed: '120Mhz'
   
   Everything else Arduino/Teensy default.
   
   This Teensy-based sampler tester mimics the behaviour of an Amiga parallel port during a 
   sampling operation (bytes are read and a a STROBE signal is emitted, as per the Amiga CIA 
   chip's behaviour). This is to reduce the risk of frying real Amigas' CIA chips during testing. 

   8 digital input pins connect straight to a DB25 connector's data pins, while three digital output pins 
   are converted from 3.3v to 5v before being connected to the DB25's STROBE, SELECT and PAPER_OUT pins.
   The DB25 connector also takes 5v directly from the Teensy's USB 5v input (this may need to be soldered 
   to the Teensy for a decent contact). See the OAS github for full docs/wiring diagrams.
   
   To convert raw: sox -t raw -r 16574.2757 -b 8 -c 1 -L -e signed-integer .\audio.raw .\audio.wav
   This tells sox to assume a samplerate that matches Protracker note C-3, and is calculated by 
   working out a PAL Amiga's clock speed divided by the note period from a LUT (214, in this case).
   -c is channel count 
   -L is endianness (irrelevant with 8bit values)
   -e is encoding, signed int

   Notes: the STROBE is sent by the Amiga's CIA chip at a fixed rate - ie the sample rate - after every
   data byte is read. On an Amiga this process is discrete/automatic, so from a programmer's perspective 
   the speed at which bytes are read (usually with an interrupt request - $DFF01E) is the desired sample 
   rate. But here we're doing it manually, sorta back to front. 

   The rate of that custom interrupt on the Amiga isn't actually the sample rate, it's the note period - 
   in other words, a value from a lookup table by which you divide the Amiga's PAL or NTSC clock frequency
   to get a sample rate. 

   5512.5 samplerate with 5 and 40 delays is roughly F-1 note

   Amiga clock: 3546895   
   B-3 period: 113
   F-1 period: 640

   B-3 samplerate: 31388.45
*/

#include <SPI.h>
#include <SD.h>
#include <SD_t3.h>

int strobePin = 9;
int paperPin = 10;
int selectPin = 11;
int speakerPin = 35;
int paperState = HIGH;
int selectState = LOW;

uint8_t inChar = 0;
int aBufferSize = 128000;
int bufferCount = 0;
int buffersWritten = 0;
uint8_t audioBuffer[128000];
const int chipSelect = BUILTIN_SDCARD;

// the setup routine runs once when you press reset:
void setup() {
    
  // 8 contiguous bits on Teensy 3.5:
  /*
     D0 2
     D1 14
     D2 7
     D3 8
     D4 6
     D5 20
     D6 21
     D7 5
  */
  pinMode(2, INPUT_PULLUP);
  pinMode(14, INPUT_PULLUP);
  pinMode(7, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
  pinMode(6, INPUT_PULLUP);
  pinMode(20, INPUT_PULLUP);
  pinMode(21, INPUT_PULLUP);
  pinMode(5, INPUT_PULLUP);  

  // These 3 control pins' logic output has to be converted to 5v 
  pinMode(strobePin, OUTPUT);
  // selectPin and paperPin control switching between left and right - tbc, but I think 
  // you alternate one high vs one low per read
  pinMode(selectPin, OUTPUT);
  pinMode(paperPin, OUTPUT);
  pinMode(speakerPin, OUTPUT);

  Serial.begin(9600);
  while (!Serial) {
    ; //wait for serial port to connect
  }


  Serial.print("Initialising SD card...");

  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    return;
  }
  Serial.println("card initialised");
  
}



// the loop routine runs over and over again forever:
void loop() {

  /*
   * In case you need to test each individual bit (can help diagnose continuity problems)
   * 
  String out;
  for (int i = 0; i < 8; i++) {
    out += digitalRead(i);
  }
  Serial.println(out);*/
  

  inChar = GPIOD_PDIR & 0xFF;


  if (bufferCount < aBufferSize) {

    

    audioBuffer[bufferCount] = inChar;

  } else {

    bufferCount = 0;
    
    File dataFile = SD.open("audio.raw", FILE_WRITE);
    
    if (buffersWritten == 0) {
      
      /* 
       * Unclear whether file seeking/overwriting works, so it's probably best to delete audio.raw from 
       * the SD card and touch a new one before each test (otherwise you might end up with multiple test
       * sessions being appended to the same file).
       * Linux/MacOS: rm audio.raw && touch audio.raw
       * Windows PowerShell: delete audio.raw; New-Item audio.raw -ItemType file
       */
       
      dataFile.seek(0);
      
    }
    
    if (dataFile) {
      Serial.println("Writing buffer to file");
      for (int i = 0; i < aBufferSize; i++) {
        
        dataFile.write( (int8_t)((int16_t) audioBuffer[i] - 128) );
        
      }
      
      dataFile.close();
      Serial.println("Done");
      buffersWritten++;
      
    } else {
      
      Serial.println("Error opening audio.raw");
      
    }


  }

  bufferCount++;  

  // For mono, don't switch these per cycle
  /*
  int tmp = paperState;
  paperState = selectState;
  selectState = tmp;
  */
  
  digitalWrite(selectPin, selectState); 
  digitalWrite(paperPin, paperState);

  digitalWrite(strobePin, LOW);
  delayMicroseconds(5);

  digitalWrite(strobePin, HIGH);
  delayMicroseconds(40);
  

}
