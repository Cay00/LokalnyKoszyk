/// Jednolity klucz dla UUID z PostgREST/Darta — porównania i mapy są wtedy stabilne.
String normalizeUuidKey(String raw) => raw.trim().toLowerCase();
