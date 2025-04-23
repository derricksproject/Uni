/// Enum to calculate the AQI Index
/// 
/// **Author**: Krishnen Ganeshakumar
enum Aqi {
  good,
  moderate,
  sensitiveGroups,
  unhealthy,
  veryUnhealthy,
  hazardous
}

/// Returns an [Aqi] 'label' based on the [percentage] of oxygen
Aqi evalOxygen(double percentage) {
  if (percentage >= 20.1 && percentage < 21.7) {
    return Aqi.good;

  } else if (percentage > 19.3 && percentage <= 20.1 || percentage >= 21.7 && percentage < 22.5) {
    return Aqi.moderate;

  } else if (percentage > 18.4 && percentage <= 19.3 || percentage >= 22.5 && percentage < 23.4) {
    return Aqi.sensitiveGroups;

  } else if (percentage > 17.6  && percentage <= 18.4 || percentage >= 23.4 && percentage < 24.2) {
    return Aqi.unhealthy;

  } else if (percentage > 16  && percentage <= 17.6 || percentage >= 24.2 && percentage < 25.8) {
    return Aqi.veryUnhealthy;
  } else {
    return Aqi.hazardous;
  }
}

/// Returns an Aqi value  based on the [percentage] of oxygen
double aqiOxygen(double percentage) {
  if (percentage >= 20.1 && percentage < 21.7) { // 1.6 to GOOD
    double result = ((0-50)/(20.1-21.7))*(percentage-20.1)+0;
    return result;

  } else if (percentage > 19.3 && percentage <= 20.1 ) { // 0.8 to MODERATE
    double result = ((51-100)/(20.1-19.3))*(percentage-20.1)+51;
    return result;

  } else if ( percentage >= 21.7 && percentage < 22.5) { // 0.8 to MODERATE
    double result = ((51-100)/(21.7-22.5))*(percentage-21.7)+51;
    return result;

  } else if (percentage > 18.4 && percentage <= 19.3 ) { // 0.9 to SENSITIVE GROUPS
    double result = ((101-150)/(19.3-18.4))*(percentage-19.3)+101;
    return result;

  } else if ( percentage >= 22.5 && percentage < 23.4) { // 0.9 to SENSITIVE GROUPS
    double result = ((101-150)/(22.5-23.4))*(percentage-22.5)+101;
    return result;

  } else if (percentage > 17.6  && percentage <= 18.4) { // 0.8 to UNHEALTHY
    double result = ((151-200)/(18.4-17.6))*(percentage-18.4)+151;
    return result;

  } else if (percentage >= 23.4 && percentage < 24.2) { // 0.8 to UNHEALTHY
    double result = ((151-200)/(23.4-24.2))*(percentage-23.4)+151;
    return result;

  } else if (percentage > 16  && percentage <= 17.6) { // 1.6 to VERY_UNHEALTHY
    double result = ((201-300)/(17.6-16))*(percentage-17.6)+201;
    return result;

  } else if (percentage >= 24.2 && percentage < 25.8) { // 1.6 to VERY_UNHEALTHY
    double result = ((201-300)/(24.2-25.8))*(percentage-24.2)+201;
    return result;

  } else if (percentage <= 16) { // HAZARD
    double result = ((301-500)/(17.6-16))*(percentage-16)+301;
    return result > 500? 500 : result;
  } else {
    double result = ((301-500)/(24.2-25.8))*(percentage-25.8)+301;
    return result > 500? 500 : result;
  }
}




/// Returns an [Aqi] 'label' based on the [ppm] of co2
Aqi evalco2(double ppm) {
  if (ppm >= 0 && ppm < 600) {
    return Aqi.good;

  } else if (ppm >= 600 && ppm < 800) {
    return Aqi.moderate;

  } else if (ppm >= 800 && ppm < 1000) {
    return Aqi.sensitiveGroups;

  } else if (ppm >= 1000  && ppm < 1200) {
    return Aqi.unhealthy;

  } else if (ppm >= 1200  && ppm < 1500) {
    return Aqi.veryUnhealthy;

  } else {
    return Aqi.hazardous;
  }
}



/// Returns an Aqi value  based on the [ppm] of co2
double aqico2(double ppm) {
  if (ppm >= 0 && ppm < 600) {
    double result = ((0-50)/(600-0))*(ppm-0)+0;
    return result;

  } else if (ppm >= 600 && ppm < 800) {
    double result = ((51-100)/(600-800))*(ppm-600)+51;
    return result;

  } else if (ppm >= 800 && ppm < 1000) {
    double result = ((101-150)/(800-1000))*(ppm-800)+101;
    return result;

  } else if (ppm >= 1000  && ppm < 1200) {
    double result = ((151-200)/(1000-1200))*(ppm-1000)+151;
    return result;

  } else if (ppm >= 1200  && ppm < 1500) {
    double result = ((201-300)/(1200-1500))*(ppm-1200)+201;
    return result;

  } else {
    double result = ((301-500)/(1200-1500))*(ppm-1500)+301;
    return result > 500? 500 : result;
  }
}




/// Returns an [Aqi] 'label' based on the [ppm] of co
Aqi evalco(double ppm) {
  if (ppm >= 0 && ppm <= 9) {
    return Aqi.good;

  } else if (ppm >= 10 && ppm <= 24) {
    return Aqi.moderate;

  } else if (ppm >= 25 && ppm <= 50) {
    return Aqi.sensitiveGroups;

  } else if (ppm >= 51  && ppm <= 70) {
    return Aqi.unhealthy;

  } else if (ppm > 71  && ppm <= 100) {
    return Aqi.veryUnhealthy;

  } else {
    return Aqi.hazardous;
  }
}


/// Returns an Aqi value  based on the [ppm] of co
double aqiCo(double ppm) {
  if (ppm >= 0 && ppm <= 9) {
    double result = ((0-50)/(9-0))*(ppm-0)+0;
    return result;

  } else if (ppm >= 10 && ppm <= 24) {
    double result = ((51-100)/(10-24))*(ppm-10)+51;
    return result;

  } else if (ppm >= 25 && ppm <= 50) {
    double result = ((101-150)/(25-50))*(ppm-25)+101;
    return result;

  } else if (ppm >= 51  && ppm <= 70) {
    double result = ((151-200)/(51-70))*(ppm-51)+151;
    return result;

  } else if (ppm > 71  && ppm <= 100) {
    double result = ((201-300)/(71-100))*(ppm-71)+201;
    return result;

  } else {
    double result = ((301-500)/(71-100))*(ppm-1500)+301;
    return result > 500? 500 : result;
  }
}


/// Returns an [Aqi] 'label' based on the [percentage] of humidity
Aqi evalHumid(double percentage) {
  if (percentage >= 0 && percentage <=50) {
    return Aqi.good;
  }
  if (percentage >= 51 && percentage <= 100) {
    return Aqi.moderate;
  } else {
    return Aqi.moderate;
  }
}


/// Returns an Aqi value  based on the [percentage] of humidity
double aqiHumid(double percentage) {
  if (percentage >= 0 && percentage <=50) {
    double result = ((0-50)/(0-50))*(percentage-0)+0;
    return result;
  }
  if (percentage >= 51 && percentage <= 100) {
    double result = ((51-100)/(51-100))*(percentage-0)+51;
    return result;
  } else {
    return 100;
  }
}



/// Returns an [Aqi] 'label' based on the [ppb] of ozone
Aqi evalOzone(double ppb) {
  if (ppb >= 0 && ppb <= 50) {
    return Aqi.good;

  } else if (ppb >= 51 && ppb <= 100) {
    return Aqi.moderate;

  } else if (ppb >= 101 && ppb <= 150) {
    return Aqi.sensitiveGroups;

  } else if (ppb >= 151  && ppb <= 200) {
    return Aqi.unhealthy;

  } else if (ppb > 201  && ppb <= 300) {
    return Aqi.veryUnhealthy;

  } else {
    return Aqi.hazardous;
  }
}

/// Returns an Aqi value  based on the [ppb] of ozone
double aqiOzone(double ppb) {
  if (ppb >= 0 && ppb <= 50) {
    double result = ((0-50)/(0-50))*(ppb-0)+0;
    return result;

  } else if (ppb >= 51 && ppb <= 100) {
    double result = ((51-100)/(51-100))*(ppb-51)+51;
    return result;

  } else if (ppb >= 101 && ppb <= 150) {
    double result = ((101-150)/(101-150))*(ppb-101)+101;
    return result;

  } else if (ppb >= 151  && ppb <= 200) {
    double result = ((151-200)/(151-200))*(ppb-151)+151;
    return result;

  } else if (ppb >= 201  && ppb <= 300) {
    double result = ((201-300)/(201-300))*(ppb-201)+201;
    return result;

  } else {
    double result = ((301-500)/(201-300))*(ppb-301)+301;
    return result > 500? 500 : result;
  }
}
