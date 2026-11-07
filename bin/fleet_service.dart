import 'package:fleet_service/data.dart';
import 'package:fleet_service/parser.dart';

void main() {
  final services = rawRecords.map(parseLine).nonNulls.toList();
  print('Розібрано записів: ${services.length} з ${rawRecords.length}');
}
