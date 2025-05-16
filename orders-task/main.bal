import ballerina/task;
import ballerina/io;
import ballerina/time;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

configurable task:PostgresqlConfig databaseConfig = ?;
configurable int livenessCheckInterval = ?;
configurable int heartbeatFrequency = ?;
configurable string taskId = ?;
configurable string groupId = ?;

time:Utc currentUtc = time:utcNow();
time:Utc newTime = time:utcAddSeconds(currentUtc, 8);
time:Civil time = time:utcToCivil(newTime);

final postgresql:Client dbClient = check new (username = databaseConfig.user, password = databaseConfig.password, database = "testdb");

listener task:Listener taskListener = new(
    trigger = {
        interval: 4,
        maxCount: 20,
        startTime: time,
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

    isolated function execute() {
        do {
            sql:ExecutionResult executeResult;
            lock {
                executeResult = check dbClient->execute(`INSERT INTO orders (message) VALUES ('ordered')`);
            }
            io:println("Query executed in Orders table: ", executeResult);
        } on fail error err {
            io:println("Error occurred while executing the job: ", err);
        }
    }
}
