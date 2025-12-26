GOLF-CLUB
GOLF-CLUB is a Flutter-based mobile application developed to interface with sensor-equipped Bluetooth Low Energy (BLE) hardware. The app acts as a digital caddie, capturing real-time ball and swing metrics directly from the device to provide golfers with immediate performance feedback.

It features a robust communication layer for hardware interaction and a built-in simulation mode that provides high-fidelity mock data when a physical sensor is not detected.

Core Features
Real-Time Data Acquisition: Synchronizes with the GOLF-CLUB sensor to retrieve critical ball metrics including Ball Speed, Flight Time, Launch Angle, and Smash Factor.

Seamless BLE Integration: Handles complex Bluetooth lifecycles, including device discovery, secure pairing, and continuous characteristic notifications.

Intelligent Scanning: Filters for specific hardware UUIDs to ensure quick connection to the correct club or sensor module.

Hardware Simulation: An automated fallback system that generates synthetic sensor data, allowing for full application testing and UI demonstration in the absence of physical hardware.

Customized UX: Includes a dedicated splash screen and platform-specific assets for a professional, performance-oriented feel.

Technical Specifications
Framework: Flutter (Stable)

Language: Dart

Protocol: Bluetooth Low Energy (GATT Service/Characteristic model)

Metrics Tracked: Velocity (mph/kph), Time (ms), Launch Dynamics, and Power Efficiency.
