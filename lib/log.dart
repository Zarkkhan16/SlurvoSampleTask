import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
class LogScreen extends StatelessWidget {
  final List<DiscoveredService> services;
  final List<String> logs;

  LogScreen({required this.services, required this.logs});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Device Inspector"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Services"),
              Tab(text: "Logs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Services tab
            services.isEmpty
                ? Center(child: Text("No services discovered"))
                : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, i) {
                final s = services[i];
                return ExpansionTile(
                  title: Text("Service: ${s.serviceId}"),
                  children: s.characteristics.map((c) {
                    return ListTile(
                      title: Text("Char: ${c.characteristicId}"),
                      subtitle: Text(
                        "props: ${c.isReadable ? "R " : ""}${c.isWritableWithoutResponse ? "W " : ""}${c.isNotifiable ? "N " : ""}",
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Logs tab
            logs.isEmpty
                ? Center(child: Text("No logs yet"))
                : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Text(
                  logs[index],
                  style: TextStyle(fontFamily: "monospace"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
