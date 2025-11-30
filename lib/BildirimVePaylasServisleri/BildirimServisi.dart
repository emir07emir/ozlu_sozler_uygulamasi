import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BildirimServisi{
  var bildirim = FlutterLocalNotificationsPlugin();

  //todo 1.KURULUM

Future<void> kurulumuYap() async{
  tz.initializeTimeZones(); // saat ayarlarını yükledim burada

  var istanbul = tz.getLocation("Europe/Istanbul");
  tz.setLocalLocation(istanbul);
  // Android ve iOS ayarlarını yaptım
  var androidAyarlari = AndroidInitializationSettings("@mipmap/ic_launcher");
  var iosAyarlari = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
  );
  // birleştiriyoruz(Android&iOS)
  var genelAyarlar = InitializationSettings(android: androidAyarlari,iOS: iosAyarlari);

  // eklentiyi başlatıyoruz
  await bildirim.initialize(genelAyarlar,onDidReceiveNotificationResponse: (response){
    print("Bildirime tıklandı: ${response.payload}");
  });
  }

  //todo 2. İZİN İSTEME
  Future<void> IzinIste() async {
    if (Platform.isAndroid) {
      final androidPlugin = bildirim.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }
  //todo 3.GÜNLÜK BİLDİRİM KURMA

Future<void> bildirimZamanla(String baslik,String icerik, TimeOfDay secilenSaat) async{
  
  var androidDetay = const AndroidNotificationDetails("kanal_id_1",
      "Günlük Hatırlatma",
      channelDescription: "Günlük özlü söz bildirimleri",
      importance: Importance.max,
      priority: Priority.high,
  );
  
  var iosDetay = const DarwinNotificationDetails();
  
  var bildirimDetaylari = NotificationDetails(android: androidDetay,iOS: iosDetay);

  
  var tarih = tarihHesapla(secilenSaat);
  print("Bildirim Şu saate kuruldu (TR Saati): $tarih");

  try{
    await bildirim.zonedSchedule(
        0,
        baslik,
        icerik,
        tarih,
        bildirimDetaylari,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrar etmesi için
        payload: "GunlukSozPayload"
    );
    print("BAŞARILI: Bildirim başarıyla oluşturuldu");
  }catch(e){
    print("HATA: bildirim kurulamadı! Sebebi: $e");
  }
  


}

tz.TZDateTime tarihHesapla(TimeOfDay saat) {
  final tz.TZDateTime simdi = tz.TZDateTime.now(tz.local);

  tz.TZDateTime planlananZaman = tz.TZDateTime(
    tz.local, simdi.year, simdi.month, simdi.day, saat.hour, saat.minute);

  if(planlananZaman.isBefore(simdi)){
    planlananZaman = planlananZaman.add(Duration(days: 1));
  }
  return planlananZaman;
}





}