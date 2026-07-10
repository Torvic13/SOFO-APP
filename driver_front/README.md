# SOFO Driver Front

Aplicación Flutter del conductor conectada a `driver_back`.

## Ejecución local

Primero inicia el backend desde otra terminal:

```powershell
cd ..\driver_back
npm run dev
```

Después inicia Flutter. El valor predeterminado usa `10.0.2.2:3000` en el
emulador Android y `localhost:3000` en web/escritorio:

```powershell
flutter run
```

Para un teléfono físico o un backend desplegado, indica una URL accesible desde
el dispositivo:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

En producción se debe utilizar una URL HTTPS.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
