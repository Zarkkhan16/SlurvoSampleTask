// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//
// class LogScreen extends StatelessWidget {
//   final List<DiscoveredService> services;
//   final List<String> logs;
//
//   const LogScreen({
//     super.key,
//     required this.services,
//     required this.logs,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Device Inspector"),
//           bottom: const TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.memory), text: "Services"),
//               Tab(icon: Icon(Icons.list_alt), text: "Logs"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // -------- Services tab --------
//             services.isEmpty
//                 ? const Center(child: Text("No services discovered"))
//                 : ListView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: services.length,
//               itemBuilder: (context, i) {
//                 final service = services[i];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   child: ExpansionTile(
//                     title: Text(
//                       "Service: ${service.serviceId}",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     children: service.characteristics.map((c) {
//                       return ExpansionTile(
//                         leading: const Icon(Icons.extension),
//                         title: Text("Char: ${c.characteristicId}"),
//                         children: [
//                           if (c.isReadable)
//                             ListTile(
//                               leading: _buildIcon(Icons.visibility, Colors.blue),
//                               title: const Text("Readable"),
//                             ),
//                           if (c.isWritableWithoutResponse)
//                             ListTile(
//                               leading: _buildIcon(Icons.edit, Colors.green),
//                               title: const Text("Writable (No Response)"),
//                             ),
//                           if (c.isNotifiable)
//                             ListTile(
//                               leading: _buildIcon(Icons.notifications, Colors.orange),
//                               title: const Text("Notifiable"),
//                             ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 );
//               },
//             ),
//
//             // -------- Logs tab --------
//             logs.isEmpty
//                 ? const Center(child: Text("No logs yet"))
//                 : Container(
//               color: Colors.black,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(8),
//                 itemCount: logs.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2),
//                     child: Text(
//                       logs[index],
//                       style: const TextStyle(
//                         fontFamily: "monospace",
//                         fontSize: 14,
//                         color: Colors.greenAccent,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIcon(IconData icon, Color color) {
//     return CircleAvatar(
//       backgroundColor: color.withOpacity(0.15),
//       child: Icon(icon, color: color),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class LogScreen extends StatelessWidget {
  final List<DiscoveredService> services;
  final List<String> logs;

  const LogScreen({
    super.key,
    required this.services,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Device Inspector"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.memory), text: "Services"),
              Tab(icon: Icon(Icons.list_alt), text: "Logs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // -------- Services tab --------
            services.isEmpty
                ? const Center(child: Text("No services discovered"))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: services.length,
              itemBuilder: (context, i) {
                final service = services[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.indigo.shade50,
                  child: ExpansionTile(
                    collapsedIconColor: Colors.indigo,
                    iconColor: Colors.indigo,
                    title: Text(
                      "Service: ${service.serviceId}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    children: service.characteristics.map((c) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ExpansionTile(
                          collapsedIconColor: Colors.teal,
                          iconColor: Colors.teal,
                          leading: const Icon(Icons.extension,
                              color: Colors.teal),
                          title: Text(
                            "Char: ${c.characteristicId}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          children: [
                            if (c.isReadable)
                              _buildPropertyTile(
                                "Readable",
                                Icons.visibility,
                                Colors.blue,
                              ),
                            if (c.isWritableWithoutResponse)
                              _buildPropertyTile(
                                "Writable (No Response)",
                                Icons.edit,
                                Colors.green,
                              ),
                            if (c.isWritableWithResponse)
                              _buildPropertyTile(
                                "Writable (With Response)",
                                Icons.edit_note,
                                Colors.teal,
                              ),
                            if (c.isNotifiable)
                              _buildPropertyTile(
                                "Notifiable",
                                Icons.notifications,
                                Colors.deepOrange,
                              ),
                            if (c.isIndicatable)
                              _buildPropertyTile(
                                "Indicatable",
                                Icons.info,
                                Colors.purple,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // -------- Logs tab --------
            logs.isEmpty
                ? const Center(child: Text("No logs yet"))
                : Container(
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final isError = log.toLowerCase().contains("error");
                  final isNotify = log.toLowerCase().contains("notify");
                  final isWrite = log.toLowerCase().contains("write");

                  Color logColor = Colors.greenAccent;
                  if (isError) {
                    logColor = Colors.redAccent;
                  } else if (isNotify) {
                    logColor = Colors.orangeAccent;
                  } else if (isWrite) {
                    logColor = Colors.lightBlueAccent;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isError
                              ? Icons.error
                              : isNotify
                              ? Icons.notifications
                              : isWrite
                              ? Icons.edit
                              : Icons.info,
                          color: logColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "[${DateTime.now().toIso8601String().substring(11, 19)}] $log",
                            style: TextStyle(
                              fontFamily: "monospace",
                              fontSize: 13,
                              color: logColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTile(String title, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
