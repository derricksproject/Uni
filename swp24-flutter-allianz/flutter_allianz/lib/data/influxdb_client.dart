import 'package:flutter_allianz/config/params.dart';
import 'package:http/http.dart';


/// This class represents a client for interacting with an InfluxDB instance, specifically for version 1.x.
/// It provides methods to query data from the database using InfluxQL and retrieve data in a specific format.
/// 
/// **Author**: Steffen Gebhard
class InfluxdbV1 {

  late String hostname;
  late int port;
  late String username;
  late String password;
  late String database;

  /// Constructs an InfluxdbV1 client with the provided connection details.
  ///
  /// [hostname] - The hostname of the InfluxDB instance (e.g., "localhost").
  /// [port] - The port number on which InfluxDB is listening (e.g., 8086).
  /// [username] - The username for authentication to the InfluxDB instance.
  /// [password] - The password associated with the [username] for authentication.
  /// [database] - The name of the InfluxDB database you wish to query.
  InfluxdbV1({
    required hostname,
    required port,
    required username,
    required password,
    required database,
  });

  /// Queries the last 1000 recorded values of a specified [measurement].
  ///
  /// This method constructs an InfluxQL query to fetch the last 1000 entries from a given measurement
  /// in the InfluxDB database and returns the response.
  ///
  /// [measurement] - The measurement to query for in the InfluxDB database (e.g., "temperature").
  ///
  /// Returns a [Response] from InfluxDB on success, or a [Future.error] if the query fails.
  Future<Response> query1000(String measurement) async {
    String fluxQuery = "SELECT * FROM $measurement ORDER BY time DESC LIMIT 1000";
    return query(fluxQuery);
  }

  /// Sends a plain query using InfluxQL to the InfluxDB instance.
  ///
  /// This method allows sending raw InfluxQL queries to the database.
  ///
  /// [influxQL] - A valid InfluxQL query string to be executed (e.g., "SELECT * FROM temperature").
  ///
  /// Returns a [Response] from InfluxDB on success, or a [Future.error] if the query fails.
  Future<Response> query(String influxQL) async {
    String username = "&u=$this.username";
    String password = "&p=$this.password";
    String unsanatized = "http://${Params.influxAddress}:${Params.influxPort}/query?q=$influxQL$username$password&db=openhab_db";
    String uriAdress = Uri.encodeFull(unsanatized);
    late Uri uri;
    uri = Uri.parse(uriAdress);

    try {
      Response toReturn = await get(uri);
      if (toReturn.statusCode >= 400 && toReturn.statusCode <=499) {
        return Future.error("Bad Request");
      }
      if (toReturn.statusCode >= 500 && toReturn.statusCode <=599) {
        return Future.error("Server error");
      }
      return toReturn;
    } catch (e) {
      return Future.error(e);
    }
  }
}


