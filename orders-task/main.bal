import ballerina/task;
import ballerina/io;
import ballerina/time;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

configurable task:PostgresqlConfig databaseConfig = ?;
configurable int livenessCheckInterval = ?;
configurable int heartbeatFrequency = ?;
configurable string taskId = ?;
configurable string groupId = ?;

time:Utc currentUtc = time:utcNow();

final postgresql:Client dbClient = check new (username = databaseConfig.user, password = databaseConfig.password, database = "testdb");

listener task:Listener taskListener = new(
    trigger = {
        interval: 4,
        maxCount: 20,
        startTime: time:utcToCivil(time:utcAddSeconds(currentUtc, 5)),
        endTime: time:utcToCivil(time:utcAddSeconds(currentUtc, 60)),
        taskPolicy: {}
    }, 
    warmBackupConfig = {
        databaseConfig,
        livenessCheckInterval,
        taskId,
        groupId,
        heartbeatFrequency
    }
);

service "job-1" on taskListener {
    private int i = 1;

    isolated function execute() returns error? {
        lock {
            self.i += 1;
            io:println("Counter: ", self.i);
        }
    }
}
