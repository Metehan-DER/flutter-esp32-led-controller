#include <Arduino.h>
#include <Wire.h>
#include <ArtronShop_SHT3x.h>

ArtronShop_SHT3x sht3x(0x44, &Wire);  // ADDR: 0 => 0x44, ADDR: 1 => 0x45

void setup() {

  // Seri haberleşmeyi başlat
  Serial.begin(115200);
  
  
  // I2C haberleşmeyi başlat
  Wire.begin();

  // SHT3x sensörünü başlat, eğer bulunamazsa uyarı ver ve 1 saniye bekle
  while (!sht3x.begin()) {
    Serial.println("SHT3x not found !");
    delay(1000);
  }
}

void loop() {
  // Sıcaklık ve nem ölçümü yap
  if (sht3x.measure()) {
    // Sıcaklık değerini seri monitöre yazdır, 1 ondalık hassasiyet
    Serial.print("Temperature: ");
    Serial.print(sht3x.temperature(), 1);
    Serial.print(" *C\tHumidity: ");
    // Nem değerini seri monitöre yazdır, 1 ondalık hassasiyet
    Serial.print(sht3x.humidity(), 1);
    Serial.print(" %RH");
    Serial.println();
  } else {
    // Ölçüm hatası durumunda uyarı ver
    Serial.println("SHT3x read error");
  }
  delay(1000);
}
