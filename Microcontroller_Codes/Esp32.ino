#include <WiFi.h>
#include <WebServer.h>

// Pin definitions
const int redPin = 3;
const int greenPin = 4;
const int bluePin = 5;
const int coldLightPin = 19;

WebServer server(80); // HTTP server on port 80

#define RXp2 18  // ESP32-WROOM-32D UART2 RX pin
#define TXp2 19  // ESP32-WROOM-32D UART2 TX pin

String DataToRead = "";  // String to store incoming data

void setup() {
  Serial.begin(115200);                           // Start UART0
  Serial1.begin(115200, SERIAL_8N1, RXp2, TXp2);  // Start UART2 with RX and TX

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(coldLightPin, OUTPUT);

  // Set up access point
  if (WiFi.softAP("ESP32-AP", "12345678")) {
    Serial.println("Access Point Started");
    Serial.print("IP Address: ");
    Serial.println(WiFi.softAPIP());
  } else {
    Serial.println("Error starting Access Point");
  }

  // Initial state: turn off all LEDs
  turnOffLED(redPin);
  turnOffLED(greenPin);
  turnOffLED(bluePin);
  turnOffLED(coldLightPin);

  // Define HTTP routes
  server.on("/toggleRed", HTTP_GET, []() { handleToggleLED(redPin, "Red LED"); });
  server.on("/toggleGreen", HTTP_GET, []() { handleToggleLED(greenPin, "Green LED"); });
  server.on("/toggleBlue", HTTP_GET, []() { handleToggleLED(bluePin, "Blue LED"); });
  server.on("/toggleColdLight", HTTP_GET, []() { handleToggleLED(coldLightPin, "Cold Light"); });

  server.on("/turnOffRed", HTTP_GET, []() { handleTurnOffLED(redPin, "Red LED"); });
  server.on("/turnOffGreen", HTTP_GET, []() { handleTurnOffLED(greenPin, "Green LED"); });
  server.on("/turnOffBlue", HTTP_GET, []() { handleTurnOffLED(bluePin, "Blue LED"); });
  server.on("/turnOffColdLight", HTTP_GET, []() { handleTurnOffLED(coldLightPin, "Cold Light"); });

  server.on("/uartData", HTTP_GET, handleUARTData);

  // Start server
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}

void handleToggleLED(int pin, const char* name) {
  int state = digitalRead(pin);
  digitalWrite(pin, !state);
  Serial.print(name);
  Serial.print(" toggled to ");
  Serial.println(state == LOW ? "ON" : "OFF");
  server.send(200, "text/plain", String(name) + " toggled");
}

void handleTurnOffLED(int pin, const char* name) {
  digitalWrite(pin, LOW);
  Serial.print(name);
  Serial.println(" turned OFF");
  server.send(200, "text/plain", String(name) + " turned OFF");
}

void turnOffLED(int pin) {
  digitalWrite(pin, LOW);
  Serial.print("LED on pin ");
  Serial.print(pin);
  Serial.println(" turned OFF");
}

void handleUARTData() {
  if (Serial1.available()) { // Check if there's data on UART2
    DataToRead = Serial1.readString(); // Read the incoming data
    Serial.print("Message Received: ");
    Serial.println(DataToRead);

    // Parse temperature and humidity values
    int temperatureIndex = DataToRead.indexOf("Temperature: ") + 13;
    int humidityIndex = DataToRead.indexOf("Humidity: ") + 10;
    String temperatureString = DataToRead.substring(temperatureIndex, DataToRead.indexOf(" *C", temperatureIndex));
    String humidityString = DataToRead.substring(humidityIndex, DataToRead.indexOf(" %RH", humidityIndex));

    // Convert strings to float
    float temperature = temperatureString.toFloat();
    float humidity = humidityString.toFloat();

    // Send data to client
    server.send(200, "text/plain", "Temperature: " + String(temperature) + " °C\nHumidity: " + String(humidity) + " %RH");
  } else {
    server.send(200, "text/plain", "No UART data available");
  }
}
